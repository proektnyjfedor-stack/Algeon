import '../models/task.dart';

/// Only evaluates fully numeric expressions; never guesses from prose.
class TaskTeaching {
  static List<String> explanation(Task task) {
    if (task.explanationSteps.isNotEmpty) return task.explanationSteps;
    final calc = calculation(task) ?? linearCalculation(task);
    if (calc != null && task.checkAnswer(calc.value.toString())) {
      return calc.steps;
    }
    return hints(task);
  }

  static Calculation? calculation(Task task) {
    var source = task.question.trim();
    final hasPrefix = RegExp(r'^Вычисли(?:те)?:?\s*').hasMatch(source);
    if (!hasPrefix && !RegExp(r'=\s*\?$').hasMatch(source)) return null;
    source = source
        .replaceFirst(RegExp(r'^Вычисли(?:те)?:?\s*'), '')
        .replaceFirst(RegExp(r'\s*=\s*\?$'), '')
        .replaceFirst(RegExp(r'\?\s*$'), '')
        .trim();
    if (!RegExp(r'^[\d\s.,+−\-*/×÷:()]+$').hasMatch(source)) return null;
    // A written fraction after ÷ is one operand, not two chained divisions.
    if (source.contains('÷') || source.contains(':')) {
      source = source.replaceAllMapped(
        RegExp(r'\d+(?:[.,]\d+)?\s*/\s*\d+(?:[.,]\d+)?'),
        (m) => '(${m[0]})',
      );
    }
    try {
      return Calculation.parse(source);
    } on FormatException {
      return null;
    }
  }

  static Calculation? linearCalculation(Task task) {
    var q = task.question
        .trim()
        .replaceFirst(
          RegExp(r'^(?:Реши(?:те)?(?: уравнение)?|Найди(?:те)? x):\s*'),
          '',
        )
        .replaceFirst(RegExp(r'\.\s*(?:Найди(?:те)? x\.?|Чему равен x\?)$'), '')
        .replaceFirst(RegExp(r'\s*\?$'), '');
    if (!q.contains('x') || !RegExp(r'^[\dx\s.,+−\-*/×÷:()=]+$').hasMatch(q)) {
      return null;
    }
    q = q
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(':', '/')
        .replaceAll('−', '-');
    final sides = q.split('=');
    if (sides.length != 2 || sides.any((s) => s.trim().isEmpty)) return null;
    // Products of unknowns and unknowns in denominators are not linear.
    final compact = q.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'/[+\-]*x|[()]').hasMatch(compact)) return null;
    // Unary signs after multiplication/division do not separate terms.
    // Each multiplicative term may contain at most one unknown.
    final terms = compact
        .replaceAllMapped(RegExp(r'([*/])[+\-]+'), (m) => m[1]!)
        .split(RegExp(r'[+\-=]'));
    if (terms.any((term) => 'x'.allMatches(term).length > 1)) return null;
    q = q.replaceAllMapped(RegExp(r'(\d)\s*x'), (m) => '${m[1]}*x');
    final normalized = q.split('=');
    try {
      Rational evaluate(String expression, int x) =>
          Calculation.parse(expression.replaceAll('x', '($x)')).value;
      final b = evaluate(normalized[0], 0) - evaluate(normalized[1], 0);
      final one = evaluate(normalized[0], 1) - evaluate(normalized[1], 1);
      final a = one - b;
      if (a.numerator == BigInt.zero) return null;
      final negativeB = Rational(-b.numerator, b.denominator);
      final root = negativeB / a;
      return Calculation(q, root, [
        'Соберём слагаемые с x слева, числа справа: $a × x = $negativeB.',
        'Разделим обе части на $a: x = ${negativeB.operand} ÷ ${a.operand} = $root.',
        'Подстановка x = $root в исходное равенство даёт одинаковые значения слева и справа.',
      ]);
    } on FormatException {
      return null;
    }
  }

  static List<String> hints(Task task) {
    if (task.hint?.trim().isNotEmpty ?? false) return [task.hint!.trim()];
    final q = task.question;
    if (linearCalculation(task) != null) {
      return [
        'Сохрани равенство: выполняй одно и то же действие с обеими частями.',
        'Собери слагаемые с x в одной части, числа — в другой. Затем раздели на коэффициент при x.',
      ];
    }
    if (calculation(task) != null) {
      return [
        'Посмотри, какие действия нужно выполнить и есть ли скобки.',
        'Сначала скобки, затем умножение и деление, после — сложение и вычитание. Действия одной ступени выполняй слева направо.',
      ];
    }
    if (q.contains('период') &&
        (q.contains('sin') || q.contains('cos') || q.contains('tg'))) {
      return [
        'Период — наименьший положительный сдвиг, после которого график повторяется.',
        q.contains('tg')
            ? 'Для y = tg(kx + b): T = π/|k|.'
            : 'Для y = sin(kx + b) и y = cos(kx + b): T = 2π/|k|. Сдвиг b не меняет период.',
      ];
    }
    if (q.contains('НОД')) {
      return [
        'Нужен делитель, который подходит обоим числам.',
        'Разложи оба числа на простые множители. Возьми общие множители в наименьших степенях.',
      ];
    }
    if (q.contains('НОК')) {
      return [
        'Нужно наименьшее число, которое делится на оба данных.',
        'НОК(a, b) = a × b / НОД(a, b).',
      ];
    }
    if (q.contains('%')) {
      return [
        'Процент — одна сотая часть величины.',
        'Чтобы найти p% от a, вычисли a × p/100. Чтобы найти долю в процентах, раздели часть на целое и умножь на 100.',
      ];
    }
    return const [];
  }
}

class Calculation {
  Calculation(this.expression, this.value, this.steps);
  final String expression;
  final Rational value;
  final List<String> steps;
  static Calculation parse(String source) {
    final parser = _ArithmeticParser(source);
    final value = parser.expression();
    if (parser.index != parser.tokens.length) {
      throw const FormatException('Trailing expression');
    }
    return Calculation(source, value, parser.steps);
  }
}

class Rational {
  factory Rational(BigInt n, BigInt d) {
    if (d == BigInt.zero) throw const FormatException('Zero denominator');
    final divisor = n.gcd(d);
    return Rational._(
      d.isNegative ? -n ~/ divisor : n ~/ divisor,
      d.abs() ~/ divisor,
    );
  }
  const Rational._(this.numerator, this.denominator);
  factory Rational.number(String value) {
    final parts = value.replaceAll(',', '.').split('.');
    final scale = BigInt.from(10).pow(parts.length == 2 ? parts[1].length : 0);
    return Rational(BigInt.parse(parts.join()), scale);
  }
  final BigInt numerator, denominator;
  Rational operator +(Rational b) => Rational(
    numerator * b.denominator + b.numerator * denominator,
    denominator * b.denominator,
  );
  Rational operator -(Rational b) => Rational(
    numerator * b.denominator - b.numerator * denominator,
    denominator * b.denominator,
  );
  Rational operator *(Rational b) =>
      Rational(numerator * b.numerator, denominator * b.denominator);
  Rational operator /(Rational b) {
    if (b.numerator == BigInt.zero) {
      throw const FormatException('Division by zero');
    }
    return Rational(numerator * b.denominator, denominator * b.numerator);
  }

  /// Keep signed and fractional operands unambiguous in plain-text steps.
  String get operand => numerator.isNegative || denominator != BigInt.one
      ? '($this)'
      : toString();

  @override
  String toString() =>
      denominator == BigInt.one ? '$numerator' : '$numerator/$denominator';
}

class _ArithmeticParser {
  _ArithmeticParser(String input) {
    final normalized = input
        .replaceAll('−', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(':', '/');
    final pattern = RegExp(r'\d+(?:[.,]\d+)?|[()+*/\-]');
    final matches = pattern.allMatches(normalized);
    if (matches.map((m) => m[0]).join() !=
        normalized.replaceAll(RegExp(r'\s'), '')) {
      throw const FormatException('Unknown symbol');
    }
    tokens = matches.map((m) => m[0]!).toList();
  }
  late final List<String> tokens;
  final steps = <String>[];
  int index = 0;
  String? get current => index < tokens.length ? tokens[index] : null;
  Rational expression() {
    var a = term();
    while (current == '+' || current == '-') {
      final op = tokens[index++];
      final b = term();
      final result = op == '+' ? a + b : a - b;
      steps.add('${a.operand} $op ${b.operand} = $result');
      a = result;
    }
    return a;
  }

  Rational term() {
    var a = atom();
    while (current == '*' || current == '/') {
      final op = tokens[index++];
      final b = atom();
      final result = op == '*' ? a * b : a / b;
      steps.add('${a.operand} ${op == '*' ? '×' : '÷'} ${b.operand} = $result');
      a = result;
    }
    return a;
  }

  Rational atom() {
    if (current == '+' || current == '-') {
      final negative = tokens[index++] == '-';
      final value = atom();
      return negative ? Rational(-value.numerator, value.denominator) : value;
    }
    if (current == '(') {
      index++;
      final value = expression();
      if (current != ')') throw const FormatException('Unclosed bracket');
      index++;
      return value;
    }
    if (current == null || !RegExp(r'^\d').hasMatch(current!)) {
      throw const FormatException('Missing number');
    }
    return Rational.number(tokens[index++]);
  }
}
