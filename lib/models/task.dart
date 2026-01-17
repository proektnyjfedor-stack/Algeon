/// Модель задачи для MathPilot
/// 
/// Два типа заданий:
/// - multipleChoice: выбор из вариантов (как на левом макете)
/// - textInput: свободный ввод (как на правом макете)

/// Тип задания
enum TaskType {
  /// Выбор из нескольких вариантов
  multipleChoice,
  
  /// Текстовое поле для ввода ответа
  textInput,
}

/// Модель математической задачи
class Task {
  /// Уникальный ID задачи
  final String id;
  
  /// Класс (1-4)
  final int grade;
  
  /// Название темы
  final String topic;
  
  /// Текст задачи
  final String question;
  
  /// Тип задания
  final TaskType type;
  
  /// Варианты ответов (для multipleChoice)
  final List<String>? options;
  
  /// Правильный ответ (текст или число в виде строки)
  final String answer;
  
  /// Единица измерения (кг, м, см и т.д.)
  final String? unit;
  
  /// Подсказка для ввода
  final String? hint;
  
  /// Пошаговое объяснение решения
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
    required this.explanationSteps,
  });

  /// Проверка ответа
  bool checkAnswer(String userAnswer) {
    // Нормализуем оба ответа
    final userNormalized = _normalize(userAnswer);
    final correctNormalized = _normalize(answer);
    
    return userNormalized == correctNormalized;
  }
  
  /// Нормализация ответа для сравнения
  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Создание из JSON/Map
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
      explanationSteps: (json['explanationSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  /// Парсинг типа задания
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
  String toString() {
    return 'Task(id: $id, topic: $topic, type: $type)';
  }
}
