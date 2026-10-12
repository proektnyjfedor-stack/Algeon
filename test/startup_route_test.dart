import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/screens/profile_tab.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/sound_service.dart';

void main() {
  testWidgets('Startup keeps a profile deep link captured before the splash', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'sound_enabled': false,
    });
    configureStartupLocation('/profile');
    await ProgressService.init();
    await AchievementsService.init();
    await SoundService.init();
    await LanguageService.instance.init();
    await tester.pumpWidget(const AlgeonApp());
    await tester.pumpAndSettle();
    expect(find.byType(ProfileTab), findsOneWidget);
    expect(appRouter.routeInformationProvider.value.uri.path, '/profile');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
