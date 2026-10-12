import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/models/task.dart';

void main() {
  test('Catalog has unique IDs and usable questions and answers', () {
    final tasks = getAllTasks();
    final ids = <String>{};
    final problems = <String>[];
    for (final task in tasks) {
      if (!ids.add(task.id)) problems.add('Duplicate ID: ${task.id}');
      if (task.question.trim().isEmpty ||
          task.answer.trim().isEmpty ||
          task.topic.trim().isEmpty) {
        problems.add('Missing content: ${task.id}');
      }
      if (!task.checkAnswer(task.answer)) {
        problems.add('Rejected own answer: ${task.id}');
      }
      if (task.type == TaskType.textInput && task.options != null) {
        problems.add('Hidden choices: ${task.id}');
      }
      if (task.type == TaskType.multipleChoice) {
        final options = task.options ?? [];
        if (options.length < 2 || options.toSet().length != options.length) {
          problems.add('Invalid choices: ${task.id}');
        }
        final equivalentChecker = Task(
          id: task.id,
          grade: task.grade,
          topic: task.topic,
          question: task.question,
          type: TaskType.textInput,
          answer: task.answer,
        );
        final equivalent = options
            .where(equivalentChecker.checkAnswer)
            .toList();
        if (equivalent.length > 1) {
          problems.add('Equivalent choices: ${task.id}: $equivalent');
        }
        final accepted = options.where(task.checkAnswer).toList();
        if (accepted.length != 1) {
          problems.add('Ambiguous answer: ${task.id}: $accepted');
        }
      }
    }
    for (var grade = 1; grade <= 11; grade++) {
      expect(getTasksByGrade(grade), isNotEmpty, reason: 'Grade $grade');
    }
    // ignore: avoid_print
    print(
      'Catalog: ${tasks.length} tasks across 11 grades, ${tasks.map((t) => t.topic).toSet().length} topics',
    );
    for (var grade = 1; grade <= 11; grade++) {
      print(
        '$grade: ${getTasksByGrade(grade).map((t) => t.topic).toSet().length} topics',
      );
    }
    expect(problems, isEmpty);
  });
}
