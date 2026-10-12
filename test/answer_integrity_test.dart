import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/data/tasks_data.dart';

Task example(String answer, {String question = 'Вычисли', String? unit}) =>
    Task(
      id: 'integrity',
      grade: 8,
      topic: 'Выражения',
      question: question,
      type: TaskType.textInput,
      answer: answer,
      unit: unit,
    );

void main() {
  test('Root normalization preserves the scope of a compound radicand', () {
    expect(example('√2 + 3').checkAnswer('√(2 + 3)'), false);
    expect(example('√(2 + 3)').checkAnswer('√2 + 3'), false);
    expect(example('√a + b').checkAnswer('sqrt(a + b)'), false);
    expect(example('√(a + b)').checkAnswer('sqrt(a + b)'), true);
    expect(example('5√3').checkAnswer('5sqrt(3)'), true);
    expect(example('√0.25').checkAnswer('sqrt(0.25)'), true);
  });

  test(
    'Unit symbols embedded in a number cannot turn malformed input into a valid answer',
    () {
      final angle = example('12°', question: 'Найди угол в градусах');
      expect(angle.checkAnswer('1°2'), false);
      expect(angle.checkAnswer('12°°'), false);
      final money = example('12', question: 'Сколько рублей стоит покупка?');
      expect(money.checkAnswer('1руб2'), false);
      expect(money.checkAnswer('руб12'), false);
      expect(money.checkAnswer('12 руб.'), true);
      expect(angle.checkAnswer('12'), true);
      expect(
        example('12', question: 'Вырубили 12 деревьев').checkAnswer('12 руб'),
        false,
      );
      expect(
        example('12', question: 'Углубили канаву').checkAnswer('12°'),
        false,
      );
      expect(example('12', question: 'Найди угол').checkAnswer('12°'), true);
    },
  );

  test(
    'Declared measurement units may be entered but incompatible dimensions are rejected',
    () {
      final length = example('12', unit: 'см');
      expect(length.checkAnswer('12 см'), true);
      expect(length.checkAnswer('12см'), true);
      expect(length.checkAnswer('12 м'), false);
      expect(length.checkAnswer('12 см²'), false);
      expect(length.checkAnswer('12°'), false);
      expect(length.checkAnswer('12 руб.'), false);
      expect(example('12').checkAnswer('12 руб.'), false);
      expect(example('0.5', unit: 'см²').checkAnswer('1/2 см²'), true);
    },
  );

  test(
    'Every catalog task with a declared unit accepts its answer followed by that unit',
    () {
      final tasks = getAllTasks()
          .where((t) => t.type == TaskType.textInput && t.unit != null)
          .toList();
      expect(tasks, isNotEmpty);
      for (final task in tasks) {
        expect(
          task.checkAnswer('${task.answer} ${task.unit}'),
          true,
          reason: task.id,
        );
      }
    },
  );
}
