import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/services/task_teaching.dart';

void main() {
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
