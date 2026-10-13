import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/services/task_teaching.dart';
import 'package:math_pilot/models/task.dart';

Task equation(String question) => Task(
  id: 'linear-check',
  grade: 8,
  topic: 'Уравнения',
  question: question,
  type: TaskType.textInput,
  answer: '0',
);

void main() {
  test(
    'Nonlinear products and variable divisors never get a linear solution',
    () {
      for (final source in [
        'x/2*x=x',
        'x*2*x=0',
        'x*-2*x=0',
        'x*−2*x=0',
        '2/-x=1',
        '2/−x=1',
        'x/2/3*x=0',
      ]) {
        expect(
          TaskTeaching.linearCalculation(equation(source)),
          isNull,
          reason: source,
        );
      }
    },
  );

  test(
    'Linear terms on both sides and signed coefficients remain supported',
    () {
      final examples = {
        'x/2+x=3': '2',
        '2x+3=x+5': '2',
        'x*-2=4': '-2',
        'x/−2=4': '-8',
        '3−2x=7': '-2',
      };
      for (final entry in examples.entries) {
        expect(
          TaskTeaching.linearCalculation(equation(entry.key))?.value.toString(),
          entry.value,
          reason: entry.key,
        );
      }
    },
  );
  test('Signed operands retain their scope in every arithmetic operation', () {
    final examples = {
      '3-(-2)': '3 - (-2) = 5',
      '-3+(-2)': '(-3) + (-2) = -5',
      '-3*(-2)': '(-3) × (-2) = 6',
      '6/(-2)': '6 ÷ (-2) = -3',
    };
    for (final entry in examples.entries) {
      expect(Calculation.parse(entry.key).steps.last, entry.value);
    }
  });

  test('A fractional divisor is grouped and evaluated exactly', () {
    final calculation = Calculation.parse('2/(1/3)');
    expect(calculation.steps, ['1 ÷ 3 = 1/3', '2 ÷ (1/3) = 6']);
    expect(calculation.value.toString(), '6');
    expect(Calculation.parse('(1/2)/(3/4)').steps.last, '(1/2) ÷ (3/4) = 2/3');
  });
}
