import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'package:math_pilot/services/study_session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Main sections fit narrow, tablet, and desktop screens', (
    tester,
  ) async {
    await tester.runAsync(() => ExamCatalog.load());
    final originalError = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint(details.toString());
      originalError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalError);
    for (final width in [320.0, 768.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'sound_enabled': false,
        'user_name': 'Очень длинное имя пользователя для проверки интерфейса',
      });
      await ProgressService.init();
      await StudySessionService.init();
      await AchievementsService.init();
      await SoundService.init();
      await LanguageService.instance.init();
      appRouter.go('/learn');
      await tester.pumpWidget(const AlgeonApp());
      for (final language in AppLanguage.values) {
        await LanguageService.instance.setLanguage(language);
        for (final path in [
          '/learn',
          '/practice',
          '/exams',
          '/profile',
          '/achievements',
        ]) {
          appRouter.go(path);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: path);
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
