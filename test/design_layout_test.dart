import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'package:math_pilot/services/study_session_service.dart';
import 'package:math_pilot/services/learning_service.dart';

Future<void> loadDesignFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in entry['fonts'] as List) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  // Local visual QA uses real Cyrillic glyphs; CI can use its test font.
  final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
  if (Platform.environment['ALGEON_TEST_FALLBACK_FONT'] != '1' &&
      await font.exists()) {
    await (FontLoader('Inter')..addFont(
          Future.value(ByteData.sublistView(await font.readAsBytes())),
        ))
        .load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('All screens fit four widths and both themes with real fonts', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await ExamCatalog.load();
      await loadDesignFonts();
    });
    for (final width in [320.0, 640.0, 900.0, 1280.0]) {
      for (final mode in ['light', 'dark']) {
        tester.platformDispatcher.textScaleFactorTestValue =
            width == 320 && mode == 'dark' ? 1.4 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({
          'onboarding_complete': true,
          'current_grade': 7,
          'sound_enabled': false,
          'install_app_banner_dismissed': true,
          'theme_mode': mode,
        });
        await ProgressService.init();
        await AchievementsService.init();
        await StudySessionService.init();
        await LanguageService.instance.init();
        await SoundService.init();
        final history = LearningService.instance;
        await history.init();
        final task = getTasksByGrade(7).first;
        await history.record(
          attemptId: 'design',
          id: task.id,
          topic: LearningService.taskTopic(task),
          ref: LearningService.taskRef(task),
          correct: false,
          input: '1/2',
        );
        await history.configurePlan({
          'track': 'school',
          'grade': 7,
          'daily': 10,
          'goal': 'Уверенно решать задачи',
          'target': '2027-06-01',
        });
        final boundaryKey = GlobalKey();
        appRouter.go('/learn');
        await tester.pumpWidget(
          RepaintBoundary(key: boundaryKey, child: const AlgeonApp()),
        );
        for (final path in [
          '/learn',
          '/practice',
          '/library',
          '/library?saved=1',
          '/exams',
          '/achievements',
          '/profile',
          '/study',
          '/diagnostic',
          '/study?tab=1',
          '/exams/profile-1',
          '/study?tab=2',
          '/exams/profile-1/run',
        ]) {
          appRouter.go(path);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$path at $width ($mode)',
          );
          if (path == '/exams') {
            final buttons = find.widgetWithText(FilledButton, 'Разбор');
            expect(buttons, findsWidgets);
            final size = tester.getSize(buttons.first);
            expect(
              size.height,
              lessThan(65),
              reason: 'Action labels must stay compact',
            );
            final meta = find.text('25 заданий · 3 ч 55 мин');
            expect(meta, findsWidgets);
            if (width == 640 && mode == 'light') {
              await tester.tap(
                find.widgetWithText(FilledButton, 'Разбор').first,
              );
              await tester.pumpAndSettle();
              expect(
                appRouter.routeInformationProvider.value.uri.path,
                '/exams/oge-1',
              );
              appRouter.go('/exams');
              await tester.pumpAndSettle();
              await tester.tap(
                find.widgetWithText(OutlinedButton, 'Экзамен').first,
              );
              await tester.pumpAndSettle();
              expect(
                appRouter.routeInformationProvider.value.uri.path,
                '/exams/oge-1/run',
              );
              appRouter.go('/exams');
              await tester.pumpAndSettle();
            }
          }
          if (Platform.environment['ALGEON_CAPTURE_DESIGN'] == '1' &&
              (width == 640 || width == 1280)) {
            await tester.runAsync(() async {
              final boundary =
                  boundaryKey.currentContext!.findRenderObject()
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final name = path.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
              await File(
                '/tmp/algeon-design-${width.toInt()}-$mode-$name.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
    }
  });
}
