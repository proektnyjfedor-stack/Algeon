import '../models/task.dart';
import 'learning_service.dart';
import 'task_teaching.dart';

/// Relative exercise complexity, not a school grade or an ability score.
class AdaptivePractice {
  static int complexity(Task task) {
    final calc =
        TaskTeaching.calculation(task) ?? TaskTeaching.linearCalculation(task);
    if (calc != null) return calc.steps.length.clamp(1, 3);
    final signs = RegExp(r'[+−×÷/²³√]').allMatches(task.question).length;
    if (task.question.length > 150 || task.explanationSteps.length >= 4) {
      return 3;
    }
    if (signs > 1 || task.question.length > 85) return 2;
    return 1;
  }

  static int startingStage(List<Task> tasks) {
    final recent = <bool>[];
    final history = LearningService.instance.stats;
    for (final task in tasks) {
      final entry = history[task.id];
      if (entry != null) recent.addAll((entry['recent'] as List).cast<bool>());
    }
    if (recent.length < 5) return 1;
    final ratio = recent.where((v) => v).length / recent.length;
    return ratio >= .8 ? 2 : 1;
  }

  static List<Task> sequence(List<Task> tasks) {
    if (tasks.isEmpty ||
        tasks.map((t) => '${t.grade}:${t.topic}').toSet().length != 1) {
      return tasks;
    }
    final stage = startingStage(tasks);
    final order = {for (var i = 0; i < tasks.length; i++) tasks[i].id: i};
    return List<Task>.from(tasks)..sort((a, b) {
      final ca = complexity(a), cb = complexity(b);
      // Experienced students start with practice; keep fundamentals available at the end.
      final pa = stage == 2 && ca == 1 ? 4 : ca;
      final pb = stage == 2 && cb == 1 ? 4 : cb;
      return pa == pb ? order[a.id]!.compareTo(order[b.id]!) : pa.compareTo(pb);
    });
  }

  static String feedback(Task task, String input) {
    if (input.trim().isEmpty) {
      return 'Ответ пропущен. Начни с первого шага разбора и попробуй объяснить его своими словами.';
    }
    if (task.checkAnswer(input)) return '';
    Rational? number(String value) {
      try {
        return Calculation.parse(value).value;
      } on FormatException {
        return null;
      }
    }

    final expected = number(task.answer), given = number(input);
    bool same(Rational a, Rational b) =>
        a.numerator == b.numerator && a.denominator == b.denominator;
    if (expected != null && given != null) {
      if (expected.numerator != BigInt.zero &&
          same(given, Rational(-expected.numerator, expected.denominator))) {
        return 'Проверь знак: модуль твоего ответа совпадает с правильным, но знак противоположный. Найди действие, где знак мог измениться.';
      }
      final fractions = RegExp(
        r'(\d+)\s*/\s*(\d+)\s*\+\s*(\d+)\s*/\s*(\d+)',
      ).firstMatch(task.question);
      if (fractions != null &&
          (BigInt.parse(fractions[2]!) + BigInt.parse(fractions[4]!)) !=
              BigInt.zero) {
        final wrong = Rational(
          BigInt.parse(fractions[1]!) + BigInt.parse(fractions[3]!),
          BigInt.parse(fractions[2]!) + BigInt.parse(fractions[4]!),
        );
        if (same(given, wrong)) {
          return 'Ответ совпадает с результатом сложения числителей и знаменателей по отдельности. Так дроби не складывают: сначала приведи их к общему знаменателю, затем сложи числители.';
        }
      }
      if (task.question.contains('%') &&
          expected.numerator != BigInt.zero &&
          (same(given, expected * Rational.number('100')) ||
              same(given, expected / Rational.number('100')))) {
        return 'Ответ отличается в 100 раз. Проверь перевод процентов в долю: 1% = 1/100. Уточни, ищешь ли ты часть или целое.';
      }
      final calc = TaskTeaching.calculation(task);
      if (calc != null && calc.steps.length > 1) {
        return 'Проверь порядок действий и сравни промежуточные результаты с разбором. Первое расхождение покажет, с какого действия нужно начать заново.';
      }
    }
    return 'Сравни своё решение с разбором по одному шагу. Проверь исходные данные, выбранное правило и то, какую величину просили найти.';
  }
}
