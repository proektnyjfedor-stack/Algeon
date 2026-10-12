import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/router/route_extra_codec.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/study_session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Concurrent attempts preserve all counters and unique solved IDs',
      () async {
    SharedPreferences.setMockInitialValues({});
    await ProgressService.init(clock: () => DateTime(2026, 10, 3));
    await Future.wait([
      for (var i = 0; i < 20; i++) ProgressService.markSolved('task-$i'),
      for (var i = 0; i < 10; i++) ProgressService.recordAttempt(false),
    ]);
    expect(ProgressService.getTotalSolved(), 20);
    expect(ProgressService.getTotalAttempts(), 30);
    expect(ProgressService.getTotalCorrect(), 20);
    expect(ProgressService.getTodayCompletedCount(), 20);
    expect(ProgressService.getStreakDays(), 1);
  });

  test('Study streak is earned by attempts and follows calendar days',
      () async {
    var now = DateTime(2026, 10, 3, 23, 59);
    SharedPreferences.setMockInitialValues({});
    await ProgressService.init(clock: () => now);
    expect(ProgressService.getStreakDays(), 0);
    await ProgressService.recordAttempt(false);
    expect(ProgressService.getStreakDays(), 1);
    now = DateTime(2026, 10, 4, 0, 1);
    await ProgressService.init(clock: () => now);
    expect(ProgressService.getStreakDays(), 1);
    await ProgressService.markSolved('next');
    expect(ProgressService.getStreakDays(), 2);
    expect(ProgressService.getTodayCompletedCount(), 1);
    now = DateTime(2026, 10, 6);
    expect(ProgressService.getStreakDays(), 0);
    expect(ProgressService.getTodayCompletedCount(), 0);
    await ProgressService.recordAttempt(false);
    expect(ProgressService.getStreakDays(), 1);
  });

  test('Backup round trip replaces profile and preserves unrelated preferences',
      () async {
    SharedPreferences.setMockInitialValues(
        {'user_name': 'Фёдор', 'current_grade': 7, 'external': 'keep'});
    await ProgressService.init();
    await StudySessionService.init();
    await ProgressService.markSolved('first');
    final backup = await BackupService.export();
    await ProgressService.setUserName('Changed');
    await ProgressService.markSolved('second');
    await BackupService.restore(backup);
    expect(ProgressService.getUserName(), 'Фёдор');
    expect(ProgressService.getTotalSolved(), 1);
    expect(ProgressService.isSolved('first'), isTrue);
    expect(ProgressService.isSolved('second'), isFalse);
    expect(ProgressService.getTotalAttempts(), 1);
    expect(
        (await SharedPreferences.getInstance()).getString('external'), 'keep');
    expect(StudySessionService.current, isNull);
  });

  test('Malformed backups do not mutate current progress', () async {
    SharedPreferences.setMockInitialValues({'user_name': 'Keep'});
    await ProgressService.init();
    for (final data in [
      {'current_grade': 12},
      {
        'solved_tasks': ['same', 'same']
      },
      {'total_attempts': 1, 'correct_attempts': 2},
      {'sound_enabled': 'true'},
      {'unknown': 1},
      {'theme_mode': 'invalid'},
    ]) {
      final invalid =
          jsonEncode({'format': 'algeon-progress', 'version': 1, 'data': data});
      await expectLater(BackupService.restore(invalid), throwsFormatException);
      expect(ProgressService.getUserName(), 'Keep');
    }
  });

  test('Unfinished session restores task, input, and elapsed time', () async {
    SharedPreferences.setMockInitialValues({});
    await StudySessionService.init();
    final task = getAllTasks().first;
    final data = <String, dynamic>{
      'topic': task.topic,
      'ids': [task.id],
      'index': 0,
      'correct': 0,
      'wrong': 0,
      'skipped': 0,
      'elapsed': 12000,
      'checked': false,
      'isCorrect': false,
      'answer': '1/2',
      'selected': null,
      'wrongIds': <String>[],
    };
    await StudySessionService.save(data);
    await StudySessionService.init();
    expect(StudySessionService.forLesson(task.topic, [task])?['answer'], '1/2');
    expect(StudySessionService.current?['elapsed'], 12000);
    expect(StudySessionService.tasks.single.id, task.id);
    await StudySessionService.clear();
    await StudySessionService.init();
    expect(StudySessionService.current, isNull);
  });

  test('Broken session cannot prevent the app from starting', () async {
    SharedPreferences.setMockInitialValues(
        {'unfinished_study_session': '{broken'});
    await StudySessionService.init();
    expect(StudySessionService.current, isNull);
  });

  test('Browser history extras survive JSON serialization', () {
    const codec = RouteExtraCodec();
    final task = getAllTasks().first;
    final encoded = codec.encode({
      'tasks': [task],
      'elapsedTime': const Duration(seconds: 42)
    });
    final restored = codec.decode(jsonDecode(jsonEncode(encoded))) as Map;
    expect((restored['tasks'] as List).single, same(task));
    expect(restored['elapsedTime'], const Duration(seconds: 42));
  });
}
