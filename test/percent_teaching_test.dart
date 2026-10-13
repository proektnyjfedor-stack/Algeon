import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/services/task_teaching.dart';

void main() {
  test('An authored hint takes priority over a generic formula', () {
    const task = Task(
      id: 'specific',
      grade: 5,
      topic: 'Проценты',
      question: 'Найдите 100%, если 30% числа равны 21',
      type: TaskType.textInput,
      answer: '70',
      hint: 'Найди 1% делением на 30, затем умножь на 100.',
    );
    expect(TaskTeaching.hints(task), [task.hint]);
  });
  test(
    'Every percent lesson task has a contextual hint, including questions without a percent sign',
    () {
      final tasks = getAllTasks()
          .where((t) => t.id.startsWith('g5_pct_'))
          .toList();
      expect(tasks, hasLength(20));
      for (final task in tasks) {
        expect(task.hint, isNotNull, reason: task.id);
        expect(TaskTeaching.hints(task), [task.hint], reason: task.id);
        expect(TaskTeaching.explanation(task), isNotEmpty, reason: task.id);
      }
      expect(
        TaskTeaching.hints(getTaskById('g5_pct_4')!).single,
        contains('раздели 18'),
      );
      expect(
        TaskTeaching.hints(getTaskById('g5_pct_17')!).single,
        contains('старую цену 200'),
      );
      expect(
        TaskTeaching.hints(getTaskById('g5_pct_13')!).single,
        contains('сумма экономии'),
      );
    },
  );
  test('One percent is a fraction, not the amount found in the problem', () {
    final steps = TaskTeaching.explanation(getTaskById('g5_pct_8')!);
    expect(steps.first, '1% = 1/100.');
    expect(steps.last, contains('1% от 7500'));
    expect(
      getTaskById('g5_pct_8')!.checkAnswer((7500 / 100).toString()),
      isTrue,
    );
    expect(
      getTaskById('g5_pct_4')!.checkAnswer((18 / (30 / 100)).toString()),
      isTrue,
    );
    expect(
      getTaskById('g5_pct_17')!.checkAnswer('${(250 - 200) / 200 * 100}%'),
      isTrue,
    );
  });
}
