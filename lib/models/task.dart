/// Модель задачи для Algeon
/// 
/// Два типа заданий:
/// - multipleChoice: выбор из вариантов
/// - textInput: свободный ввод

/// Тип задания
enum TaskType {
  multipleChoice,
  textInput,
}

/// Модель математической задачи
class Task {
  final String id;
  final int grade;
  final String topic;
  final String question;
  final TaskType type;
  final List<String>? options;
  final String answer;
  final String? unit;
  final String? hint;
  
  /// Пошаговое объяснение (только для текстовых задач!)
  final List<String> explanationSteps;

  const Task({
    required this.id,
    required this.grade,
    required this.topic,
    required this.question,
    required this.type,
    this.options,
    required this.answer,
    this.unit,
    this.hint,
    this.explanationSteps = const [], // По умолчанию пустой список!
  });

  /// Проверка ответа
  bool checkAnswer(String userAnswer) {
    final userNormalized = _normalize(userAnswer);
    final correctNormalized = _normalize(answer);
    return userNormalized == correctNormalized;
  }
  
  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      grade: json['grade'] as int,
      topic: json['topic'] as String,
      question: json['question'] as String,
      type: _parseTaskType(json['type'] as String),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      answer: json['answer'].toString(),
      unit: json['unit'] as String?,
      hint: json['hint'] as String?,
      explanationSteps: (json['explanationSteps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? const [],
    );
  }

  static TaskType _parseTaskType(String value) {
    switch (value) {
      case 'multipleChoice':
        return TaskType.multipleChoice;
      case 'textInput':
        return TaskType.textInput;
      default:
        throw ArgumentError('Unknown TaskType: $value');
    }
  }

  @override
  String toString() => 'Task(id: $id, topic: $topic)';
}
