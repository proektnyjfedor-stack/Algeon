import 'package:math_pilot/models/task.dart';

void main() {
  final cases = <(String, String, bool)>[
    ('1.5', '1 1/2', true),
    ('1 1/2', '3/2', true),
    ('11/2', '1 1/2', false),
    ('1 1/2', '11/2', false),
    ('x = 1 1/2', '1.5', true),
    ('-1.5', '-1 1/2', true),
    ('-0.5', '-0 1/2', true),
    ('0.5', '-0 1/2', false),
    ('x = 3', '3', true),
    ('x = 3', 'x = 4', false),
    ('1/2', '0.5', true),
    ('35%', '35', true),
    ('180°', '180', true),
    ('a⁷', 'a^7', true),
    ('x=3, y=2', 'y = 2; x = 3', true),
    ('5√3', '5sqrt(3)', true),
  ];
  for (final (expected, input, result) in cases) {
    final task = Task(
        id: 'check',
        grade: 6,
        topic: 'test',
        question: 'test',
        type: TaskType.textInput,
        answer: expected);
    if (task.checkAnswer(input) != result) {
      throw StateError('$expected / $input');
    }
  }
  print('PASS: ${cases.length} answer-checking cases');
}
