/// Модель задачи для Algeon
///
/// Два типа заданий:
/// - multipleChoice: выбор из вариантов
/// - textInput: свободный ввод
library;

/// Тип задания
enum TaskType { multipleChoice, textInput }

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
      explanationSteps:
          (json['explanationSteps'] as List<dynamic>?)
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
    // A selected option is an exact answer, not an expression to simplify.
    // In particular, F(x) and f(x) denote different functions.
    if (type == TaskType.multipleChoice) {
      return userAnswer.trim() == answer.trim();
    }
    if (userAnswer.trim().isEmpty || userAnswer.length > 1000) return false;
    final userNormalized = _normalize(userAnswer);
    final correctNormalized = _normalize(answer);
    if (userNormalized == correctNormalized) return true;

    if (_assignmentSetEquivalent(userNormalized, correctNormalized)) {
      return true;
    }

    final assignment = RegExp(r'^([a-zA-Zа-я])\s*=');
    final userVariable = assignment.firstMatch(userNormalized)?.group(1);
    final correctVariable = assignment.firstMatch(correctNormalized)?.group(1);
    if (userVariable != null &&
        correctVariable != null &&
        userVariable != correctVariable) {
      return false;
    }

    final roots = _rootSetEquivalent(userNormalized, correctNormalized);
    if (roots != null) return roots;

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
          RegExp(r'sqrt\(\s*(\d+(?:[.,]\d+)?|[a-zA-Zαβθ])\s*\)'),
          (m) => 'sqrt${m.group(1)}',
        )
        .replaceAll('+-', '±')
        .replaceAll('+/-', '±');
    // Letter case carries mathematical meaning, but prose is case-insensitive.
    if (normalized.length > 1 &&
        RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s.,!]+$').hasMatch(normalized)) {
      normalized = normalized.toLowerCase();
    }
    return normalized;
  }

  String _valuePart(String normalized) {
    final compact = normalized.trim();
    final match = RegExp(
      r'^[a-zа-я]\s*=\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(compact);
    final value = match?.group(1) ?? compact;
    // The space separates the whole and fractional parts: 1 1/2 != 11/2.
    if (RegExp(r'^-?\d+\s+\d+/\d+$').hasMatch(value)) return value;
    if (RegExp(r'\d\s+\d').hasMatch(value)) return value;
    return value.replaceAll(' ', '');
  }

  bool _numericEquivalent(String user, String correct) {
    final userValue = _parseNumberLike(user);
    final correctValue = _parseNumberLike(correct);
    if (userValue == null || correctValue == null) return false;
    return userValue.equivalentTo(correctValue);
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
    // Split only before another assignment; a decimal comma belongs to a value.
    final chunks = text.split(RegExp(r'[;,]\s*(?=[a-zа-я]\s*=)'));
    if (chunks.length < 2) return null;
    final out = <String, String>{};
    for (final chunk in chunks) {
      if (chunk.isEmpty) return null;
      final match = RegExp(
        r'^([a-zа-я])\s*=\s*([^=;]+)$',
        caseSensitive: false,
      ).firstMatch(chunk.trim());
      if (match == null) return null;
      final variable = match.group(1)!;
      if (out.containsKey(variable)) return null;
      out[variable] = match.group(2)!.trim();
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

  // A set of roots is unordered; a coordinate pair is ordered and is excluded.
  bool? _rootSetEquivalent(String user, String correct) {
    // Numeric lists can also be sequences or ordered comparison answers.
    // Treat only explicitly marked roots or equation questions as a root set.
    final context = '$topic $question'.toLowerCase();
    final markedRoots =
        correct.contains('±') ||
        RegExp(r'[;,]\s*[a-zA-Zа-я]\s*=').hasMatch(correct);
    if (!markedRoots &&
        !context.contains('уравнен') &&
        !context.contains('корн') &&
        !context.contains('equation') &&
        !context.contains('roots')) {
      return null;
    }
    List<String>? values(String text) {
      final compact = text.trim();
      if (compact.startsWith('(') || compact.startsWith('[')) return null;
      final signed = RegExp(
        r'^(?:[a-zA-Zа-я]\s*=\s*)?±(.+)$',
      ).firstMatch(compact);
      if (signed != null && _parseNumberLike(signed[1]!) != null) {
        return [signed[1]!, '-${signed[1]!}'];
      }
      final assignments = compact.split(RegExp(r'[;,]\s*(?=[a-zA-Zа-я]\s*=)'));
      if (assignments.length > 1) {
        String? variable;
        final out = <String>[];
        for (final part in assignments) {
          final match = RegExp(
            r'^([a-zA-Zа-я])\s*=\s*(.+)$',
          ).firstMatch(part.trim());
          if (match == null || (variable != null && variable != match[1])) {
            return null;
          }
          variable = match[1];
          out.add(match[2]!);
        }
        return out.every((v) => _parseNumberLike(v) != null) ? out : null;
      }
      final parts = compact.split(RegExp(r';|,\s+'));
      if (parts.length < 2) return null;
      final out = parts.map(_valuePart).toList();
      return out.every((v) => _parseNumberLike(v) != null) ? out : null;
    }

    final expected = values(correct);
    if (expected == null) return null;
    final entered = values(user);
    if (entered == null || entered.length != expected.length) return false;
    final remaining = List<String>.from(entered);
    for (final root in expected) {
      final index = remaining.indexWhere((v) => _numericEquivalent(v, root));
      if (index < 0) return false;
      remaining.removeAt(index);
    }
    return true;
  }

  bool _percentEquivalent(String user, String correct) {
    if (!correct.endsWith('%')) return false;
    final userValue = _parsePlainNumber(user);
    final correctValue = _parsePlainNumber(
      correct.substring(0, correct.length - 1),
    );
    return userValue != null &&
        correctValue != null &&
        userValue.equivalentTo(correctValue);
  }

  _Rational? _parseNumberLike(String raw) {
    var text = raw.trim();
    final declaredUnit = unit == null
        ? null
        : _normalizePowers(unit!).replaceAll(RegExp(r'\s+'), '');
    final suffixes = <String>{?declaredUnit};
    final context = '$question $answer'.toLowerCase();
    if (declaredUnit == null) {
      if (RegExp(
        r'(^|[^а-яёa-z])руб(?:лей|ля|ль|ли|лю|лём|лем)?\.?(?=$|[^а-яёa-z])|₽',
      ).hasMatch(context)) {
        suffixes.addAll(['руб.', 'руб', '₽']);
      }
      if (RegExp(
        r'(^|[^а-яёa-z])(?:угол|угла|углу|углом|угле|углы|углов|углам|углами|углах|градус[а-яё]*)(?=$|[^а-яёa-z])|°',
      ).hasMatch(context)) {
        suffixes.add('°');
      }
    } else if (RegExp(r'^(?:руб\.?|₽)$').hasMatch(declaredUnit)) {
      suffixes.addAll(['руб.', 'руб', '₽']);
    }
    // Remove one expected suffix only, never a symbol inside the number.
    final orderedSuffixes = suffixes.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final suffix in orderedSuffixes) {
      if (suffix.isNotEmpty && text.endsWith(suffix)) {
        text = text.substring(0, text.length - suffix.length).trim();
        break;
      }
    }
    if (text.isEmpty || text.length > 256) return null;
    final mixed = RegExp(r'^([+-]?\d+)\s+(\d+)/(\d+)$').firstMatch(text);
    if (mixed != null) {
      final whole = BigInt.parse(mixed[1]!);
      final part = BigInt.parse(mixed[2]!);
      final denominator = BigInt.parse(mixed[3]!);
      if (denominator == BigInt.zero) return null;
      final sign = mixed[1]!.startsWith('-') ? -BigInt.one : BigInt.one;
      return _Rational(whole * denominator + sign * part, denominator);
    }
    final fraction = RegExp(r'^([+-]?\d+)/([+-]?\d+)$').firstMatch(text);
    if (fraction != null) {
      final denominator = BigInt.parse(fraction[2]!);
      if (denominator == BigInt.zero) return null;
      return _Rational(BigInt.parse(fraction[1]!), denominator);
    }
    if (text.endsWith('%')) {
      final value = _parsePlainNumber(text.substring(0, text.length - 1));
      return value == null
          ? null
          : _Rational(value.numerator, value.denominator * BigInt.from(100));
    }
    return _parsePlainNumber(text);
  }

  _Rational? _parsePlainNumber(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (text.length > 256 ||
        !RegExp(r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$').hasMatch(text)) {
      return null;
    }
    final negative = text.startsWith('-');
    final unsigned = text.replaceFirst(RegExp(r'^[+-]'), '');
    final pieces = unsigned.split('.');
    final digits = pieces.length == 2 ? pieces[1] : '';
    final numerator = BigInt.parse(
      '${pieces[0].isEmpty ? '0' : pieces[0]}$digits',
    );
    return _Rational(
      negative ? -numerator : numerator,
      BigInt.from(10).pow(digits.length),
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

class _Rational {
  const _Rational(this.numerator, this.denominator);
  final BigInt numerator;
  final BigInt denominator;
  bool equivalentTo(_Rational other) =>
      numerator * other.denominator == other.numerator * denominator;
}
