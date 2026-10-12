import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/screens/study_hub_screen.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/progress_service.dart';

void main() {
  final h = LearningService.instance;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    h.clock = () => DateTime(2026, 10, 12, 23, 50);
    await h.init();
    await ProgressService.init();
    await h.configurePlan({
      'track': 'school',
      'grade': 7,
      'daily': 5,
      'goal': 'Математика',
      'target': '2027-06-01',
    });
  });
  tearDown(() => h.clock = DateTime.now);
  Future<void> completeToday(WidgetTester tester) async {
    final catalog = (await tester.runAsync(ExamCatalog.load))!;
    for (final ref in await h.dailyTasks(catalog)) {
      final task = getTaskById(ref['id'])!;
      await h.record(
        attemptId: 'day:${task.id}',
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: ref,
        correct: true,
        input: task.answer,
      );
    }
  }

  Future<String> cachedDay() async => jsonDecode(
    (await SharedPreferences.getInstance()).getString(LearningService.key)!,
  )['dailyPlan']['day'];

  testWidgets('Returning from a training after midnight refreshes the plan', (
    tester,
  ) async {
    await tester.runAsync(ExamCatalog.load);
    final router = GoRouter(
      initialLocation: '/study',
      routes: [
        GoRoute(
          path: '/study',
          builder: (context, state) => const StudyHubScreen(),
        ),
        GoRoute(
          path: '/learn/topic',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Вернуться'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Продолжить план'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Продолжить план'));
    await tester.pumpAndSettle();
    await completeToday(tester);
    h.clock = () => DateTime(2026, 10, 13, 0, 10);
    await tester.tap(find.text('Вернуться'));
    await tester.pumpAndSettle();
    expect(await cachedDay(), '2026-10-13');
    await tester.scrollUntilVisible(
      find.text('1. Новая практика'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1. Новая практика'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Resuming an open plan on a new day refreshes its daily tasks', (
    tester,
  ) async {
    await tester.runAsync(ExamCatalog.load);
    await tester.pumpWidget(const MaterialApp(home: StudyHubScreen()));
    await tester.pumpAndSettle();
    await completeToday(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    h.clock = () => DateTime(2026, 10, 13, 8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(await cachedDay(), '2026-10-13');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Returning from one plan task also refreshes the daily set', (
    tester,
  ) async {
    await tester.runAsync(ExamCatalog.load);
    final router = GoRouter(
      initialLocation: '/study',
      routes: [
        GoRoute(
          path: '/study',
          builder: (context, state) => const StudyHubScreen(),
        ),
        GoRoute(
          path: '/learn/intro',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Вернуться'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('1. Новая практика'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('1. Новая практика'));
    await tester.pumpAndSettle();
    await completeToday(tester);
    h.clock = () => DateTime(2026, 10, 13, 0, 10);
    await tester.tap(find.text('Вернуться'));
    await tester.pumpAndSettle();
    expect(await cachedDay(), '2026-10-13');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Practice overview refreshes after a new day and stops observing when closed',
    (tester) async {
      await tester.runAsync(ExamCatalog.load);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: StudyLinks())),
        ),
      );
      await tester.pumpAndSettle();
      await completeToday(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      h.clock = () => DateTime(2026, 10, 13, 8);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(await cachedDay(), '2026-10-13');
      await tester.pumpWidget(const SizedBox());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      h.clock = () => DateTime(2026, 10, 14, 8);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(await cachedDay(), '2026-10-13');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'A new-day resume leaves an active solution and its input untouched',
    (tester) async {
      await tester.runAsync(ExamCatalog.load);
      final router = GoRouter(
        initialLocation: '/study',
        routes: [
          GoRoute(
            path: '/study',
            builder: (context, state) => const StudyHubScreen(),
          ),
          GoRoute(
            path: '/learn/topic',
            builder: (context, state) => const Scaffold(
              body: Column(children: [Text('Решение'), TextField()]),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Продолжить план'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Продолжить план'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'x = 1/2');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      h.clock = () => DateTime(2026, 10, 13, 8);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(await cachedDay(), '2026-10-13');
      expect(find.text('Решение'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'x = 1/2',
      );
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/learn/topic',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
