import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/screens/summary_screen.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'package:math_pilot/services/study_session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('One lesson counts an answer once and clears its saved session', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'sound_enabled': false,
      'install_app_banner_dismissed': true,
      'achievement_firstTask': DateTime.now().millisecondsSinceEpoch,
    });
    await ProgressService.init();
    await StudySessionService.init();
    await AchievementsService.init();
    await SoundService.init();
    await LanguageService.instance.init();
    final task = getAllTasks().firstWhere(
      (task) => task.type == TaskType.multipleChoice,
    );
    appRouter.go('/learn');
    await tester.pumpWidget(const AlgeonApp());
    await tester.pumpAndSettle();
    appRouter.push(
      '/learn/topic',
      extra: {
        'name': task.topic,
        'tasks': [task],
      },
    );
    await tester.pumpAndSettle();
    final answer = find.byKey(ValueKey('answer_${task.id}_${task.answer}'));
    expect(answer, findsOneWidget);
    final wrong = task.options!.firstWhere((option) => option != task.answer);
    await tester.tap(find.byKey(ValueKey('answer_${task.id}_$wrong')));
    await tester.pumpAndSettle();
    expect(ProgressService.getTotalAttempts(), 0);
    await tester.tap(answer);
    await tester.pumpAndSettle();
    expect(ProgressService.getTotalAttempts(), 0);
    final check = find.byKey(const ValueKey('primary_check'));
    await tester.tap(check);
    await tester.tap(check);
    await tester.pumpAndSettle();
    expect(ProgressService.getTotalAttempts(), 1);
    expect(ProgressService.getTotalCorrect(), 1);
    await tester.tap(find.byKey(const ValueKey('primary_continue')));
    await tester.pumpAndSettle();
    expect(find.byType(SummaryScreen), findsOneWidget);
    expect(StudySessionService.current, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
