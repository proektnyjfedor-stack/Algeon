import 'dart:math' as math;
import 'package:math_pilot/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/services/task_teaching.dart';

void main() {
  test('Independently calculate numeric catalog expressions', () {
    var checked = 0;
    final errors = <String>[];
    for (final task in getAllTasks()) {
      final calculation =
          TaskTeaching.calculation(task) ??
          TaskTeaching.linearCalculation(task);
      if (calculation == null) continue;
      checked++;
      if (!Task(
        id: task.id,
        grade: task.grade,
        topic: task.topic,
        question: task.question,
        type: TaskType.textInput,
        answer: task.answer,
      ).checkAnswer(calculation.value.toString())) {
        errors.add(
          '${task.id}: ${task.question}: expected ${calculation.value}, stored ${task.answer}',
        );
      }
    }
    print('Independently calculated $checked expressions');
    expect(checked, greaterThan(100));
    expect(errors, isEmpty);
  });
  test(
    'Divisors, percentages, shares and integer square roots agree with answers',
    () {
      var checked = 0;
      final errors = <String>[];
      for (final task in getAllTasks()) {
        final q = task.question.trim();
        String? expected;
        final divisor = RegExp(
          r'^(НОД|НОК)\((\d+),\s*(\d+)\)\s*=\s*\?$',
        ).firstMatch(q);
        final share = RegExp(
          r'^(\d+)/(\d+) от числа (\d+) = \?$',
        ).firstMatch(q);
        final percent = RegExp(
          r'^(?:Найдите )?(\d+(?:[.,]\d+)?)% от (?:числа )?(\d+(?:[.,]\d+)?)(?: = \?)?$',
        ).firstMatch(q);
        final root = RegExp(r'^√(\d+) = \?$').firstMatch(q);
        if (divisor != null) {
          final a = BigInt.parse(divisor[2]!);
          final b = BigInt.parse(divisor[3]!);
          expected = (divisor[1] == 'НОД' ? a.gcd(b) : a * b ~/ a.gcd(b))
              .toString();
        } else if (share != null) {
          expected = Calculation.parse(
            '${share[1]}/${share[2]}*${share[3]}',
          ).value.toString();
        } else if (percent != null) {
          expected = Calculation.parse(
            '${percent[1]}*${percent[2]}/100',
          ).value.toString();
        } else if (root != null) {
          final number = int.parse(root[1]!);
          final candidate = math.sqrt(number).round();
          if (candidate * candidate == number) expected = '$candidate';
        }
        if (expected == null) continue;
        checked++;
        final checker = Task(
          id: task.id,
          grade: task.grade,
          topic: task.topic,
          question: q,
          type: TaskType.textInput,
          answer: task.answer,
        );
        if (!checker.checkAnswer(expected)) {
          errors.add('${task.id}: $q: $expected != ${task.answer}');
        }
      }
      print(
        'Independently checked $checked divisor, percentage, share and root tasks',
      );
      expect(checked, greaterThan(20));
      expect(errors, isEmpty);
    },
  );
  test('Arithmetic respects precedence, signs, fractions and brackets', () {
    expect(Calculation.parse('2 + 3 * (8 - 6)').value.toString(), '8');
    expect(Calculation.parse('1/3 + 1/6').value.toString(), '1/2');
    expect(Calculation.parse('-2 * -3 + 0,5').value.toString(), '13/2');
    expect(() => Calculation.parse('1/0'), throwsFormatException);
    expect(() => Calculation.parse('2 + x'), throwsFormatException);
  });
}
