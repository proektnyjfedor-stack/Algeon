import 'task.dart';

class ExamAnswer {
  static List<String> alternatives(String answer) => answer
      .split('|')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  static bool canCheck(Map<String, dynamic> question) =>
      question['kind'] == 'short' &&
      alternatives(question['answer'] as String).isNotEmpty &&
      alternatives(
        question['answer'] as String,
      ).every((a) => RegExp(r'^[\d,\.\-]+$').hasMatch(a));
  static bool matches(String input, String expected) {
    String normalize(String s) => s
        .trim()
        .replaceAll('−', '-')
        .replaceAll('.', ',')
        .replaceAll(RegExp(r'\s+'), '');
    final entered = normalize(input);
    for (final value in alternatives(expected)) {
      if (entered == normalize(value)) return true;
      // Numeric equivalence is safe for decimal answers; ordered digit codes
      // and concatenated roots keep the exact sequence required by the source.
      if (RegExp(r'^-?\d+[,.]\d+$').hasMatch(value) &&
          Task(
            id: 'exam',
            grade: 11,
            topic: '',
            question: '',
            type: TaskType.textInput,
            answer: value,
          ).checkAnswer(input)) {
        return true;
      }
    }
    return false;
  }
}
