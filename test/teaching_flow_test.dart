import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/services/bookmark_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/study_session_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'package:math_pilot/services/task_teaching.dart';
import 'package:math_pilot/widgets/math_text.dart';
import 'package:math_pilot/widgets/math_keyboard.dart';
import 'design_layout_test.dart' show loadDesignFonts;

void main() {
  testWidgets(
    'Hints progress to a solution and keyboard answers can be checked without hiding it',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'sound_enabled': false,
        'install_app_banner_dismissed': true,
      });
      await tester.runAsync(loadDesignFonts);
      await ProgressService.init();
      await LearningService.instance.init();
      await BookmarkService.instance.init();
      await StudySessionService.init();
      await LanguageService.instance.init();
      await AchievementsService.init();
      await SoundService.init();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      appRouter.go('/learn');
      await tester.pumpWidget(
        RepaintBoundary(key: boundary, child: const AlgeonApp()),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        expect(tester.takeException(), isNull);
        if (Platform.environment['ALGEON_CAPTURE_TEACHING'] != '1') return;
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/algeon-teaching-$name.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      final trig = getTaskById('g10_trig_1')!;
      appRouter.push(
        '/learn/topic',
        extra: {
          'name': trig.topic,
          'tasks': [trig],
          'restart': true,
        },
      );
      await tester.pumpAndSettle();
      await capture('task');
      await tester.tap(find.text('Подсказка'));
      await tester.pumpAndSettle();
      expect(find.text('Показать правило'), findsOneWidget);
      expect(ProgressService.getTotalAttempts(), 0);
      await tester.tap(find.text('Показать правило'));
      await tester.pumpAndSettle();
      await capture('hint');
      await tester.ensureVisible(find.text('Показать разбор'));
      await tester.tap(find.text('Показать разбор'));
      await tester.pumpAndSettle();
      expect(ProgressService.getTotalAttempts(), 1);
      expect(ProgressService.getTotalCorrect(), 0);
      await capture('solution');
      appRouter.pop();
      await tester.pumpAndSettle();
      appRouter.push(
        '/learn/intro',
        extra: {
          'name': trig.topic,
          'tasks': [trig],
        },
      );
      await tester.pumpAndSettle();
      await capture('graph');
      appRouter.pop();
      await tester.pumpAndSettle();
      final numeric = getAllTasks().firstWhere(
        (t) =>
            t.type == TaskType.textInput && TaskTeaching.calculation(t) != null,
      );
      appRouter.push(
        '/learn/topic',
        extra: {
          'name': numeric.topic,
          'tasks': [numeric],
          'restart': true,
        },
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate((w) => w is MathText && w.text == 'Введи ответ'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MathKeyboard), findsOneWidget);
      final keyboard = tester.widget<MathKeyboard>(find.byType(MathKeyboard));
      keyboard.controller.text = numeric.answer;
      await tester.pumpAndSettle();
      await capture('keyboard');
      await tester.tap(find.byKey(const ValueKey('primary_check')));
      await tester.pumpAndSettle();
      expect(ProgressService.getTotalAttempts(), 2);
      expect(ProgressService.getTotalCorrect(), 1);
      appRouter.go('/library');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('library_search')),
        'дроби',
      );
      await tester.pumpAndSettle();
      await capture('search');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
