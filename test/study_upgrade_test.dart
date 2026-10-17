import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/study_report.dart';
import 'package:math_pilot/services/task_teaching.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final h = LearningService.instance;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    h.clock = () => DateTime(2026, 10, 17, 12);
    await h.init();
  });
  tearDown(() => h.clock = DateTime.now);
  Future<void> plan({
    String track = 'school',
    List<String> topics = const [],
  }) => h.configurePlan({
    'track': track,
    'grade': 5,
    'daily': 5,
    'minutes': 10,
    'target': '2027-06-01',
    'goal': 'Подготовка',
    'topics': topics,
  });
  test('Selected topics constrain daily school and exam tasks', () async {
    final catalog = await ExamCatalog.load();
    await plan(topics: ['Обыкновенные дроби']);
    final school = await h.dailyTasks(catalog);
    expect(school, hasLength(5));
    expect(
      school.every((r) => getTaskById(r['id'])!.topic == 'Обыкновенные дроби'),
      isTrue,
    );
    await plan(track: 'profile', topics: ['2']);
    final exam = await h.dailyTasks(catalog);
    expect(exam, hasLength(5));
    expect(
      exam.every((r) => r['track'] == 'profile' && r['slot'] == 2),
      isTrue,
    );
  });
  test(
    'Postponed tasks survive reload and reconfiguration, return tomorrow without marking attempts',
    () async {
      final catalog = await ExamCatalog.load();
      await plan();
      final first = (await h.dailyTasks(catalog)).first;
      await h.postpone(first);
      expect(h.postponedCount, 1);
      expect(h.stats, isEmpty);
      await h.init();
      expect(
        (await h.dailyTasks(catalog)).any((r) => r['id'] == first['id']),
        isFalse,
      );
      await plan();
      expect(
        (await h.dailyTasks(catalog)).any((r) => r['id'] == first['id']),
        isFalse,
      );
      h.clock = () => DateTime(2026, 10, 18, 12);
      final tomorrow = await h.dailyTasks(catalog);
      expect(tomorrow.first['id'], first['id']);
      expect(h.stats, isEmpty);
      await h.record(
        attemptId: 'return',
        id: first['id'],
        topic: LearningService.taskTopic(getTaskById(first['id'])!),
        ref: first,
        correct: true,
        input: 'test',
      );
      expect(h.completedToday(first), isTrue);
    },
  );
  test('Repeated success on a single task does not imply mastery', () async {
    final tasks = getTasksByGradeAndTopic(5, 'Проценты');
    final task = tasks.first;
    for (var i = 0; i < 10; i++) {
      await h.record(
        attemptId: 'repeat$i',
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: LearningService.taskRef(task),
        correct: true,
        input: task.answer,
      );
    }
    expect(h.topicStatus(h.topicStats().single), 'Пока мало данных');
    for (final t in tasks.skip(1).take(4)) {
      await h.record(
        attemptId: t.id,
        id: t.id,
        topic: LearningService.taskTopic(t),
        ref: LearningService.taskRef(t),
        correct: true,
        input: t.answer,
      );
    }
    expect(h.topicStatus(h.topicStats().single), 'Освоено');
    await h.record(
      attemptId: 'wrong',
      id: task.id,
      topic: LearningService.taskTopic(task),
      ref: LearningService.taskRef(task),
      correct: false,
      input: 'PRIVATE_INPUT',
    );
    expect(h.topicStatus(h.topicStats().single), 'Нужно повторить');
    final report = buildStudyReport(h);
    expect(report, contains('Проценты'));
    expect(report, contains('Что повторить'));
    expect(report, isNot(contains('PRIVATE_INPUT')));
    expect(report, contains('Нужно повторить'));
  });
  test(
    'All fraction and rational lesson tasks now have real steps and hints',
    () {
      final tasks = getAllTasks()
          .where(
            (t) => t.id.startsWith('g5_frac_') || t.id.startsWith('g6_rat_'),
          )
          .toList();
      expect(tasks, hasLength(40));
      for (final task in tasks) {
        expect(task.explanationSteps, isNotEmpty, reason: task.id);
        expect(TaskTeaching.hints(task), isNotEmpty, reason: task.id);
      }
      expect(
        TaskTeaching.calculation(getTaskById('g5_frac_6')!)!.value.toString(),
        '1/2',
      );
      expect(
        TaskTeaching.calculation(getTaskById('g6_rat_10')!)!.value.toString(),
        '2',
      );
    },
  );
  test(
    'Invalid duration is rejected without replacing the saved plan',
    () async {
      await plan();
      await expectLater(
        h.configurePlan({...h.plan, 'minutes': 5.0}),
        throwsFormatException,
      );
      expect(h.plan['minutes'], 10);
    },
  );
  test('One reinforcement has a different condition and answer', () {
    final task = getTaskById('g5_frac_5')!;
    final selected = LearningService.similar(task, count: 1);
    expect(selected, hasLength(1));
    expect(selected.single.topic, task.topic);
    expect(selected.single.id, isNot(task.id));
    expect(selected.single.answer, isNot(task.answer));
  });
}
