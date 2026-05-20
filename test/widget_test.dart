import 'package:flutter_test/flutter_test.dart';

import 'package:math_pilot/data/topic_theory.dart';
import 'package:math_pilot/models/task.dart';

void main() {
  test('Task answer normalization accepts equivalent variable answers', () {
    const task = Task(
      id: 'linear_equation_test',
      grade: 7,
      topic: 'Уравнения',
      question: 'x + 2 = 5',
      type: TaskType.textInput,
      answer: 'x = 3',
    );

    expect(task.checkAnswer('3'), isTrue);
    expect(task.checkAnswer('x=3'), isTrue);
    expect(task.checkAnswer('x = 4'), isFalse);
  });

  test('Task answer normalization accepts equivalent numeric formats', () {
    const percentTask = Task(
      id: 'percent_test',
      grade: 5,
      topic: 'Проценты',
      question: 'Запишите 0.35 в процентах',
      type: TaskType.textInput,
      answer: '35%',
    );
    const fractionTask = Task(
      id: 'fraction_test',
      grade: 5,
      topic: 'Обыкновенные дроби',
      question: 'Вычислите: 1/3 + 1/6',
      type: TaskType.textInput,
      answer: '1/2',
    );
    const degreeTask = Task(
      id: 'degree_test',
      grade: 5,
      topic: 'Геометрия',
      question: 'Сумма углов треугольника равна:',
      type: TaskType.textInput,
      answer: '180°',
    );

    expect(percentTask.checkAnswer('35'), isTrue);
    expect(fractionTask.checkAnswer('0.5'), isTrue);
    expect(degreeTask.checkAnswer('180'), isTrue);
  });

  test('Task answer normalization accepts keyboard-friendly math formats', () {
    const powerTask = Task(
      id: 'power_test',
      grade: 7,
      topic: 'Степени и одночлены',
      question: 'Упростите: a³ × a⁴',
      type: TaskType.textInput,
      answer: 'a⁷',
    );
    const systemTask = Task(
      id: 'system_test',
      grade: 7,
      topic: 'Системы уравнений',
      question: 'Решите систему',
      type: TaskType.textInput,
      answer: 'x=3, y=2',
    );
    const rootTask = Task(
      id: 'root_test',
      grade: 8,
      topic: 'Корни и степени',
      question: 'Вынесите множитель из-под корня',
      type: TaskType.textInput,
      answer: '5√3',
    );

    expect(powerTask.checkAnswer('a^7'), isTrue);
    expect(systemTask.checkAnswer('y = 2; x = 3'), isTrue);
    expect(rootTask.checkAnswer('5sqrt(3)'), isTrue);
  });

  test('Fallback theory is specific for curriculum topics', () {
    final theory = getTopicTheory('НОД и НОК');

    expect(theory, isNotNull);
    expect(
        theory!.sections.first.content, contains('наибольший общий делитель'));
    expect(theory.sections.first.content,
        isNot(contains('Тема "НОД и НОК" важна')));
  });
}
