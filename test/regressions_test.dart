import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/services/progress_service.dart';

Task taskWithAnswer(String answer) => Task(
      id: 'mixed',
      grade: 6,
      topic: 'Смешанные числа',
      question: 'Вычислите',
      type: TaskType.textInput,
      answer: answer,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Mixed fractions preserve the whole-part separator', () {
    expect(taskWithAnswer('1.5').checkAnswer('1 1/2'), isTrue);
    expect(taskWithAnswer('1 1/2').checkAnswer('3/2'), isTrue);
    expect(taskWithAnswer('11/2').checkAnswer('1 1/2'), isFalse);
    expect(taskWithAnswer('1 1/2').checkAnswer('11/2'), isFalse);
    expect(taskWithAnswer('x = 1 1/2').checkAnswer('1.5'), isTrue);
  });

  test('Negative mixed fractions include the sign of a zero whole part', () {
    expect(taskWithAnswer('-1.5').checkAnswer('-1 1/2'), isTrue);
    expect(taskWithAnswer('-0.5').checkAnswer('-0 1/2'), isTrue);
    expect(taskWithAnswer('0.5').checkAnswer('-0 1/2'), isFalse);
  });

  test('Multiple choice distinguishes a function and its antiderivative', () {
    const task = Task(
        id: 'integral',
        grade: 11,
        topic: 'Интеграл',
        question: 'Формула Ньютона–Лейбница',
        type: TaskType.multipleChoice,
        options: ['F(b) - F(a)', 'f(b) - f(a)'],
        answer: 'F(b) - F(a)');
    expect(task.checkAnswer('F(b) - F(a)'), isTrue);
    expect(task.checkAnswer('f(b) - f(a)'), isFalse);
  });

  test('Systems accept decimal commas and reject duplicate assignments', () {
    final task = taskWithAnswer('x=1.5; y=2');
    expect(task.checkAnswer('y=2; x=1,5'), isTrue);
    expect(task.checkAnswer('y=2, x=1,5'), isTrue);
    expect(task.checkAnswer('x=999; x=1.5; y=2'), isFalse);
    expect(task.checkAnswer('x=1.5; y=3'), isFalse);
    expect(task.checkAnswer('x=1.5'), isFalse);
    expect(task.checkAnswer('y=2; x=1 1/2'), isTrue);
  });

  test('Exact arithmetic rejects close but unequal answers', () {
    expect(taskWithAnswer('9007199254740993').checkAnswer('9007199254740992'),
        isFalse);
    expect(taskWithAnswer('0.0000001').checkAnswer('0'), isFalse);
    expect(taskWithAnswer('1/3').checkAnswer('0.3333333333333333'), isFalse);
    expect(taskWithAnswer('0.5').checkAnswer('+.5'), isTrue);
    expect(taskWithAnswer('-0.5').checkAnswer('1/-2'), isTrue);
    expect(taskWithAnswer('12').checkAnswer('1 2'), isFalse);
  });

  test('Roots are unordered, coordinates and variable names are preserved', () {
    expect(taskWithAnswer('x=-3; x=3').checkAnswer('3; -3'), isTrue);
    expect(taskWithAnswer('x=±3').checkAnswer('-3; 3'), isTrue);
    expect(taskWithAnswer('x=±3').checkAnswer('y=±3'), isFalse);
    expect(taskWithAnswer('x=3').checkAnswer('y=3'), isFalse);
    expect(taskWithAnswer('(2; 3)').checkAnswer('(3; 2)'), isFalse);
    expect(taskWithAnswer('1, 2, 3').checkAnswer('3, 2, 1'), isFalse);
    expect(taskWithAnswer('F(x)').checkAnswer('f(x)'), isFalse);
  });

  test('Reset clears daily statistics and preserves the profile', () async {
    SharedPreferences.setMockInitialValues(
        {'user_name': 'Тест', 'current_grade': 7});
    await ProgressService.init();
    await ProgressService.markSolved('task-1');
    expect(ProgressService.getTodayCompletedCount(), 1);
    await ProgressService.resetProgress();
    expect(ProgressService.getTodayCompletedCount(), 0);
    expect(ProgressService.getTotalSolved(), 0);
    expect(ProgressService.getTotalAttempts(), 0);
    expect(ProgressService.getTotalCorrect(), 0);
    expect(ProgressService.getUserName(), 'Тест');
    expect(ProgressService.getCurrentGrade(), 7);
    await ProgressService.markSolved('task-2');
    expect(ProgressService.getTodayCompletedCount(), 1);
  });
}
