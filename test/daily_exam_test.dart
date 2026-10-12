import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'design_layout_test.dart' show loadDesignFonts;
import 'package:math_pilot/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:math_pilot/screens/exam_session_screen.dart';
import 'package:math_pilot/screens/study_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/models/exam_answer.dart';
import 'package:math_pilot/screens/daily_exam_screen.dart';
import 'package:math_pilot/services/exam_progress.dart';
import 'package:math_pilot/services/learning_service.dart';

void main() {
  final history = LearningService.instance;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    history.clock = () => DateTime(2026, 10, 13, 12);
    await history.init();
  });
  tearDown(() => history.clock = DateTime.now);

  testWidgets(
    'Daily series follows tasks across variants, resumes and preserves other answers',
    (tester) async {
      await tester.runAsync(loadDesignFonts);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final captureKey = GlobalKey();
      Future<void> capture(String name) async {
        if (Platform.environment['ALGEON_CAPTURE_DAILY'] != '1') return;
        await tester.runAsync(() async {
          final boundary =
              captureKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/algeon-daily-$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      final catalog = (await tester.runAsync(ExamCatalog.load))!;
      final variants = catalog.variants
          .where((v) => v['track'] == 'profile')
          .take(2)
          .toList();
      final refs = <Map<String, dynamic>>[];
      for (final v in variants) {
        final q = (v['questionIds'] as List)
            .map((id) => catalog.questions[id] as Map<String, dynamic>)
            .firstWhere(
              (q) =>
                  ExamAnswer.canCheck(q) &&
                  !refs.any((ref) => ref['id'] == q['id']),
            );
        refs.add(LearningService.examRef(q, v['id'] as String));
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        LearningService.key,
        jsonEncode({
          ...LearningService.empty(),
          'plan': {
            'track': 'profile',
            'grade': 11,
            'daily': 5,
            'goal': 'Профиль',
            'target': '2027-06-01',
          },
          'dailyPlan': {'day': history.today, 'items': refs},
        }),
      );
      await history.init();
      await ExamProgress.save(refs.first['variant'], {
        'index': 19,
        'records': {
          '19': {'input': 'previous work', 'status': 'reviewed'},
        },
      });
      await ExamProgress.save(refs.last['variant'], {
        'index': (refs.last['slot'] as int) - 1,
        'records': {
          '${(refs.last['slot'] as int) - 1}': {'input': 'draft'},
        },
      });
      Future<void> open() async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildDarkTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.2)),
                child: child!,
              ),
              home: const DailyExamScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> answer(Map ref, {required bool correct}) async {
        await tester.ensureVisible(find.text('К заданию'));
        await tester.tap(find.text('К заданию'));
        await tester.pumpAndSettle();
        final q = catalog.questions[ref['id']];
        await tester.scrollUntilVisible(
          find.byType(TextField),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        if (ref['id'] == refs.last['id']) {
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'draft',
          );
        }
        await tester.enterText(
          find.byType(TextField),
          correct
              ? q['answer']
              : q['answer'] == '0'
              ? '1'
              : '0',
        );
        await tester.pump();
        await tester.scrollUntilVisible(
          find.text('Проверить ответ'),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Проверить ответ'));
        await tester.pumpAndSettle();
      }

      await open();
      expect(find.text('Задание 1 из 2'), findsOneWidget);
      await capture('start');
      expect(find.text('Результаты'), findsNothing);
      await answer(refs.first, correct: true);
      expect(history.completedToday(refs.first), true);
      await tester.scrollUntilVisible(
        find.text('Следующее задание плана'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Следующее задание плана'));
      await tester.pumpAndSettle();
      expect(find.text('Задание 2 из 2'), findsOneWidget);
      expect(find.text('К заданию'), findsOneWidget);
      expect(
        (await ExamProgress.read(
          refs.first['variant'],
        ))['records']['19']['input'],
        'previous work',
      );
      // Simulate leaving the route and opening it again; the completed first task
      // must not be retried, and the series must resume at its original position.
      await tester.pumpWidget(const SizedBox());
      await open();
      expect(find.text('Задание 2 из 2'), findsOneWidget);
      await answer(refs.last, correct: false);
      await tester.scrollUntilVisible(
        find.text('Завершить план'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Завершить план'));
      await tester.pumpAndSettle();
      expect(find.text('План на сегодня выполнен'), findsOneWidget);
      await capture('complete');
      expect(history.mistakes.containsKey('exam:${refs.last['id']}'), true);
      expect(history.stats['exam:${refs.first['id']}']['attempts'], 1);
      await tester.pumpWidget(const SizedBox());
      await open();
      expect(find.text('План на сегодня выполнен'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'An extended daily task requires self assessment before continuing',
    (tester) async {
      final catalog = (await tester.runAsync(ExamCatalog.load))!;
      final v = catalog.variants.firstWhere((v) => v['id'] == 'profile-1');
      final ids = v['questionIds'] as List;
      final slot =
          ids.indexWhere((id) => !ExamAnswer.canCheck(catalog.questions[id])) +
          1;
      var advanced = 0;
      tester.view.physicalSize = const Size(1280, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ExamSessionScreen(
            variantId: 'profile-1',
            initialQuestion: slot,
            onPracticeContinue: () => advanced++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('К заданию'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Перейти к сверке решения'));
      await tester.tap(find.text('Перейти к сверке решения'));
      await tester.pumpAndSettle();
      final finish = find.widgetWithText(FilledButton, 'Завершить план');
      await tester.ensureVisible(finish);
      expect(tester.widget<FilledButton>(finish).onPressed, isNull);
      await tester.ensureVisible(find.text('Отметить как разобранное'));
      await tester.tap(find.text('Отметить как разобранное'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(finish).onPressed, isNull);
      await tester.ensureVisible(find.text('В мои ошибки'));
      await tester.tap(find.text('В мои ошибки'));
      // Persistence can outlive a frame; wait for the visible saving state
      // using the widget clock, rather than moving fake-zone futures to runAsync.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (tester.widget<FilledButton>(finish).onPressed != null) break;
      }
      await tester.ensureVisible(finish);
      expect(tester.widget<FilledButton>(finish).onPressed, isNotNull);
      await tester.tap(finish);
      await tester.pumpAndSettle();
      expect(advanced, 1);
      expect(history.stats['exam:${ids[slot - 1]}']['attempts'], 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Starting an exam plan opens its daily route instead of the first source variant',
    (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: FilledButton(
                onPressed: () => openDailyPractice(context, [
                  {
                    'kind': 'exam',
                    'id': 'example',
                    'variant': 'profile-1',
                    'slot': 2,
                  },
                ]),
                child: const Text('Начать'),
              ),
            ),
          ),
          GoRoute(
            path: '/study/run',
            builder: (context, state) =>
                const Scaffold(body: Text('Дневная серия')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Начать'));
      await tester.pumpAndSettle();
      expect(find.text('Дневная серия'), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/study/run',
      );
    },
  );

  testWidgets('An empty plan has a useful return screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DailyExamScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Нет экзаменационных заданий в плане'), findsOneWidget);
    expect(find.text('К плану подготовки'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
