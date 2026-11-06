import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/router/route_extra_codec.dart';

void main() {
  test('A requested denominator is part of the answer', () {
    final task = getTaskById('g5_frac_18')!;
    expect(task.checkAnswer('8/12'), isTrue);
    expect(task.checkAnswer('2/3'), isFalse);
    expect(task.checkAnswer('16/24'), isFalse);
  });
  test(
    'A reduced fraction cannot be replaced by an unreduced one or a decimal',
    () {
      final task = getTaskById('g5_frac_16')!;
      expect(task.checkAnswer('3/4'), isTrue);
      expect(task.checkAnswer('18/24'), isFalse);
      expect(task.checkAnswer('0.75'), isFalse);
      final percent = getTaskById('g5_pct_2')!;
      expect(percent.checkAnswer('9/20'), isTrue);
      expect(percent.checkAnswer('45/100'), isFalse);
      expect(percent.checkAnswer('45%'), isFalse);
    },
  );
  test('Conversion tasks distinguish improper fractions and mixed numbers', () {
    final improper = getTaskById('g5_frac_7')!;
    expect(improper.checkAnswer('13/5'), isTrue);
    expect(improper.checkAnswer('26/10'), isTrue);
    expect(improper.checkAnswer('2 3/5'), isFalse);
    expect(improper.checkAnswer('2.6'), isFalse);
    final mixed = getTaskById('g5_frac_8')!;
    expect(mixed.checkAnswer('4 1/4'), isTrue);
    expect(mixed.checkAnswer('17/4'), isFalse);
    expect(mixed.checkAnswer('3 5/4'), isFalse);
    expect(mixed.checkAnswer('4.25'), isFalse);
  });
  test(
    'Ordinary answers retain numeric equivalence and form metadata survives navigation',
    () {
      expect(getTaskById('g5_frac_3')!.checkAnswer('0.5'), isTrue);
      expect(getTaskById('g5_frac_14')!.checkAnswer('40/5'), isTrue);
      final task = getTaskById('g5_frac_18')!;
      const codec = RouteExtraCodec();
      final restored = codec.decode(codec.encode(task)) as Task;
      expect(restored.answerFormat, AnswerFormat.fractionWithDenominator);
      expect(restored.requiredDenominator, 12);
      expect(restored.checkAnswer('2/3'), isFalse);
      expect(getTaskById('g5_frac_8')!.checkAnswer('4 1 / 4'), isTrue);
      expect(getTaskById('g5_frac_8')!.checkAnswer('4\u00a01/4'), isTrue);
    },
  );
  test('A notation notice is only given for a numerically correct value', () {
    final task = getTaskById('g5_frac_18')!;
    expect(task.answerFormatIssue('2/3'), contains('Значение верное'));
    expect(task.answerFormatIssue('2/3'), contains('12'));
    expect(task.answerFormatIssue('8/12'), isNull);
    expect(task.answerFormatIssue('7/12'), isNull);
    expect(task.answerFormatIssue('not a number'), isNull);
  });
}
