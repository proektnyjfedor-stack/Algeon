import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/main.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/router/app_router.dart';
import 'package:math_pilot/services/bookmark_service.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/study_session_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/achievements_service.dart';
import 'package:math_pilot/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Bookmarks persist, validate and round-trip with backups', () async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await ProgressService.init();
    await LearningService.instance.init();
    await BookmarkService.instance.init();
    final service = BookmarkService.instance;
    final task = getAllTasks().first;
    expect(BookmarkService.validId('topic:7:Геометрия: треугольники'), isTrue);
    final ids = [
      'task:${task.id}',
      'topic:${task.grade}:${task.topic}',
      'exam:profile-1:1',
    ];
    for (final id in ids) {
      await service.toggle(id);
    }
    await service.init();
    expect(service.items, ids.toSet());
    final backup = await BackupService.export();
    expect(
      BackupService.validate(backup)[BookmarkService.key],
      containsAll(ids),
    );
    await service.toggle(ids.first);
    await BackupService.restore(backup);
    expect(service.items, ids.toSet());
    final invalid = jsonDecode(backup) as Map<String, dynamic>;
    (invalid['data'] as Map)[BookmarkService.key] = ['exam:profile-1:999'];
    expect(
      () => BackupService.validate(jsonEncode(invalid)),
      throwsFormatException,
    );
    expect(service.items, ids.toSet());
    await ProgressService.resetProgress();
    expect(
      service.items,
      ids.toSet(),
    ); // Studying again must preserve saved references.
    await ProgressService.resetAll();
    expect(service.items, isEmpty);
  });
  testWidgets('Search finds topics across grades and saved tasks open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'sound_enabled': false,
    });
    await tester.runAsync(() async {
      await ProgressService.init();
      await BookmarkService.instance.init();
      await StudySessionService.init();
      await LanguageService.instance.init();
      await AchievementsService.init();
      await SoundService.init();
    });
    appRouter.go('/library');
    await tester.pumpWidget(const AlgeonApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('library_search')),
      'тригонометрические функции',
    );
    await tester.pumpAndSettle();
    expect(find.text('Тригонометрические функции'), findsOneWidget);
    expect(find.text('10 класс · 20 заданий'), findsOneWidget);
    await tester.tap(
      find.byKey(
        const ValueKey('bookmark_topic:10:Тригонометрические функции'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      BookmarkService.instance.contains('topic:10:Тригонометрические функции'),
      isTrue,
    );
    await tester.tap(find.text('Закладки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Тригонометрические функции'));
    await tester.pumpAndSettle();
    expect(find.text('Наглядный пример'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
