/// Модель задачи для Algeon
///
/// Два типа заданий:
/// - multipleChoice: выбор из вариантов
/// - textInput: свободный ввод
library;

/// Тип задания
enum TaskType {
  multipleChoice,
  textInput,
}

/// Модель математической задачи
class Task {
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
    this.imageAsset,
    this.explanationSteps = const [], // По умолчанию пустой список!
  });

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
      imageAsset: json['imageAsset'] as String?,
      explanationSteps: (json['explanationSteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
  final String id;
  final int grade;
  final String topic;
  final String question;
  final TaskType type;
  final List<String>? options;
  final String answer;
  final String? unit;
  final String? hint;

  /// Рисунок к условию (локальный asset), если есть
  final String? imageAsset;

  /// Пошаговое объяснение (только для текстовых задач!)
  final List<String> explanationSteps;

  /// Проверка ответа
  bool checkAnswer(String userAnswer) {
    final userNormalized = _normalize(userAnswer);
    final correctNormalized = _normalize(answer);
    if (userNormalized == correctNormalized) return true;

    if (_assignmentSetEquivalent(userNormalized, correctNormalized)) {
      return true;
    }

    // Accept equivalent forms for variable answers:
    // "x=-2" == "-2", "y = 3.5" == "3.5", etc.
    final userValueOnly = _valuePart(userNormalized);
    final correctValueOnly = _valuePart(correctNormalized);
    if (userValueOnly.isNotEmpty &&
        correctValueOnly.isNotEmpty &&
        userValueOnly == correctValueOnly) {
      return true;
    }

    if (_numericEquivalent(userValueOnly, correctValueOnly)) {
      return true;
    }

    if (_percentEquivalent(userValueOnly, correctValueOnly)) {
      return true;
    }

    return false;
  }

  String _normalize(String text) {
    var normalized = _normalizePowers(text)
        .trim()
        .toLowerCase()
        .replaceAll('≤', '<=')
        .replaceAll('≥', '>=')
        .replaceAll('≠', '!=')
        .replaceAll('÷', '/')
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('√', 'sqrt')
        .replaceAll('–', '-')
        .replaceAll('−', '-')
        .replaceAllMapped(RegExp(r'([<>])\s*='), (m) => '${m.group(1)}=')
        .replaceAllMapped(RegExp(r'([<>])\s+'), (m) => m.group(1)!)
        .replaceAll(RegExp(r'\s+'), ' ');
    normalized = normalized
        .replaceAllMapped(
          RegExp(r'sqrt\(([^()]+)\)'),
          (m) => 'sqrt${m.group(1)}',
        )
        .replaceAll('+-', '±')
        .replaceAll('+/-', '±');
    return normalized;
  }

  String _valuePart(String normalized) {
    final compact = normalized.replaceAll(' ', '');
    final match = RegExp(r'^[a-zа-я]\s*=\s*(.+)$', caseSensitive: false)
        .firstMatch(compact);
    if (match != null) {
      return match.group(1) ?? '';
    }
    return compact;
  }

  bool _numericEquivalent(String user, String correct) {
    final userValue = _parseNumberLike(user);
    final correctValue = _parseNumberLike(correct);
    if (userValue == null || correctValue == null) return false;
    return (userValue - correctValue).abs() < 1e-9;
  }

  bool _assignmentSetEquivalent(String user, String correct) {
    final userMap = _parseAssignments(user);
    final correctMap = _parseAssignments(correct);
    if (userMap == null || correctMap == null) return false;
    if (userMap.length != correctMap.length) return false;
    for (final entry in correctMap.entries) {
      final userValue = userMap[entry.key];
      if (userValue == null) return false;
      if (userValue == entry.value) continue;
      if (!_numericEquivalent(userValue, entry.value)) return false;
    }
    return true;
  }

  Map<String, String>? _parseAssignments(String text) {
    final compact = text.replaceAll(' ', '');
    final chunks = compact.split(RegExp(r'[;,]'));
    if (chunks.length < 2) return null;
    final out = <String, String>{};
    for (final chunk in chunks) {
      if (chunk.isEmpty) return null;
      final match = RegExp(r'^([a-zа-я])=([^=]+)$', caseSensitive: false)
          .firstMatch(chunk);
      if (match == null) return null;
      out[match.group(1)!] = match.group(2)!;
    }
    return out;
  }

  String _normalizePowers(String text) {
    const superscript = {
      '⁰': '0',
      '¹': '1',
      '²': '2',
      '³': '3',
      '⁴': '4',
      '⁵': '5',
      '⁶': '6',
      '⁷': '7',
      '⁸': '8',
      '⁹': '9',
      '⁻': '-',
    };
    const subscript = {
      '₀': '0',
      '₁': '1',
      '₂': '2',
      '₃': '3',
      '₄': '4',
      '₅': '5',
      '₆': '6',
      '₇': '7',
      '₈': '8',
      '₉': '9',
    };

    final buffer = StringBuffer();
    var i = 0;
    while (i < text.length) {
      final ch = text[i];
      if (superscript.containsKey(ch)) {
        buffer.write('^');
        while (i < text.length && superscript.containsKey(text[i])) {
          buffer.write(superscript[text[i]]);
          i++;
        }
        continue;
      }
      buffer.write(subscript[ch] ?? ch);
      i++;
    }
    return buffer.toString();
  }

  bool _percentEquivalent(String user, String correct) {
    if (!correct.endsWith('%')) return false;
    final userValue = _parsePlainNumber(user);
    final correctValue = _parsePlainNumber(correct.replaceAll('%', ''));
    if (userValue == null || correctValue == null) return false;
    return (userValue - correctValue).abs() < 1e-9;
  }

  double? _parseNumberLike(String raw) {
    final text = raw
        .replaceAll('°', '')
        .replaceAll('руб.', '')
        .replaceAll('руб', '')
        .trim();
    if (text.isEmpty) return null;

    final mixed = RegExp(r'^(-?\d+)\s+(\d+)/(\d+)$').firstMatch(text);
    if (mixed != null) {
      final whole = double.tryParse(mixed.group(1)!);
      final numerator = double.tryParse(mixed.group(2)!);
      final denominator = double.tryParse(mixed.group(3)!);
      if (whole == null ||
          numerator == null ||
          denominator == null ||
          denominator == 0) {
        return null;
      }
      final sign = whole < 0 ? -1 : 1;
      return whole + sign * numerator / denominator;
    }

    final fraction = RegExp(r'^(-?\d+)/(\d+)$').firstMatch(text);
    if (fraction != null) {
      final numerator = double.tryParse(fraction.group(1)!);
      final denominator = double.tryParse(fraction.group(2)!);
      if (numerator == null || denominator == null || denominator == 0) {
        return null;
      }
      return numerator / denominator;
    }

    if (text.endsWith('%')) {
      final value = _parsePlainNumber(text.substring(0, text.length - 1));
      return value == null ? null : value / 100;
    }

    return _parsePlainNumber(text);
  }

  double? _parsePlainNumber(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(text)) return null;
    return double.tryParse(text);
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
