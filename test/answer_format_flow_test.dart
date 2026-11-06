import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/screens/diagnostic_screen.dart';
import 'package:math_pilot/widgets/topic_quick_check.dart';
import 'package:math_pilot/widgets/math_text.dart';
import 'package:math_pilot/widgets/math_keyboard.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/bookmark_service.dart';
import 'package:math_pilot/services/study_session_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'design_layout_test.dart' show loadDesignFonts;

void main() {
  final task = getTaskById('g5_frac_18')!;
  Future<void> prepare() async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'sound_enabled': false,
      'install_app_banner_dismissed': true,
    });
    await ProgressService.init();
    await LearningService.instance.init();
    await BookmarkService.instance.init();
    await StudySessionService.init();
    await LanguageService.instance.init();
    await AchievementsService.init();
    await SoundService.init();
  }

  testWidgets(
    'Lesson, warmup and diagnostic allow notation corrections without penalties',
    (tester) async {
      await prepare();
      await tester.runAsync(loadDesignFonts);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      appRouter.go('/learn');
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: boundary, child: const AlgeonApp()),
      );
      await tester.pumpAndSettle();
      appRouter.push(
        '/learn/topic',
        extra: {
          'name': task.topic,
          'tasks': [task],
          'restart': true,
        },
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate((w) => w is MathText && w.text == 'Введи ответ'),
      );
      await tester.pumpAndSettle();
      final keyboard = tester.widget<MathKeyboard>(find.byType(MathKeyboard));
      keyboard.controller.text = '2/3';
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('primary_check')));
      await tester.pumpAndSettle();
      expect(find.text(task.answerFormatIssue('2/3')!), findsOneWidget);
      expect(ProgressService.getTotalAttempts(), 0);
      expect(LearningService.instance.stats, isEmpty);
      expect(keyboard.controller.text, '2/3');
      if (Platform.environment['ALGEON_CAPTURE_FORM'] == '1') {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/algeon-answer-form.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.text('Исправить'));
      await tester.pumpAndSettle();
      keyboard.controller.text = '8/12';
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('primary_check')));
      await tester.pumpAndSettle();
      expect(ProgressService.getTotalAttempts(), 1);
      expect(ProgressService.getTotalCorrect(), 1);
      expect(LearningService.instance.stats[task.id]['correct'], 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // Warmup permits a notation correction before revealing the solution.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: TopicQuickCheck(tasks: [task])),
          ),
        ),
      );
      await tester.tap(find.text('Проверить понимание · 1 вопрос'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2/3');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Проверить ответ'));
      await tester.pumpAndSettle();
      expect(find.text(task.answerFormatIssue('2/3')!), findsOneWidget);
      expect(find.text('Верно'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).readOnly,
        isFalse,
      );
      await tester.tap(find.text('Исправить'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '8/12');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Проверить ответ'));
      await tester.pumpAndSettle();
      expect(find.text('Верно'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      // Diagnostic does not advance or record an error for a notation correction.
      final history = LearningService.instance;
      await history.clear();
      await history.saveDiagnostic({
        'startedAt': '2026-11-06T12:00:00',
        'grade': 5,
        'ids': [task.id],
        'answers': <String, dynamic>{},
      });
      await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2/3');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Посмотреть результат'));
      await tester.pumpAndSettle();
      expect(history.stats, isEmpty);
      expect(history.diagnostic['answers'], isEmpty);
      expect(find.text(task.answerFormatIssue('2/3')!), findsOneWidget);
      await tester.tap(find.text('Исправить'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '8/12');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Посмотреть результат'));
      await tester.pumpAndSettle();
      expect(history.stats[task.id]['correct'], 1);
      expect(history.diagnostic['answers'][task.id]['correct'], isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
