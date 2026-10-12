import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/screens/task_screen.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'package:math_pilot/services/study_session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Mobile navigation, practice launch, and persistent progress', (
    tester,
  ) async {
    final previousErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint(details.toString());
      previousErrorHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousErrorHandler);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'sound_enabled': false,
      'install_app_banner_dismissed': true,
      'current_grade': 5,
    });
    await ProgressService.init();
    await StudySessionService.init();
    await AchievementsService.init();
    await SoundService.init();
    await LanguageService.instance.init();
    await tester.pumpWidget(const AlgeonApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    appRouter.go('/learn/topic');
    await tester.pumpAndSettle();
    expect(find.byType(TaskScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Практика').last);
    await tester.pumpAndSettle();
    expect(find.text('Быстрый тест'), findsOneWidget);
    await tester.ensureVisible(find.text('Начать быстрый тест'));
    await tester.tap(find.text('Начать быстрый тест'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    appRouter.go('/profile');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    appRouter.go('/achievements');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await ProgressService.markSolved('persisted-task');
    await ProgressService.init();
    expect(ProgressService.isSolved('persisted-task'), isTrue);
    expect(ProgressService.getTodayCompletedCount(), 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
