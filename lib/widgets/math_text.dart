/// Consistent textbook notation, without changing stored answers or checking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathNotation {
  static const _atom =
      r'(?:√(?:\([^()\n]+\)|[A-Za-z0-9]+)|\([^()\n]+\)|(?:sin|cos|tan|ctg|tg|ln|log)(?:[²³]|\^\d+)?\s*(?:\([^()\n]+\)|[a-zA-Zαβθ])|[A-Za-z0-9παβθ]+(?:[.,]\d+)?(?:[²³⁴⁵⁶⁷⁸⁹⁰¹₀₁₂₃₄₅₆₇₈₉]+|\^[+-]?\d+)?)';
  static String tex(String input) {
    var s = input.trim();
    final fractions = RegExp('($_atom)\\s*/\\s*($_atom)');
    s = s.replaceAllMapped(fractions, (m) {
      String operand(String value) =>
          value.startsWith('(') && value.endsWith(')')
          ? tex(value.substring(1, value.length - 1))
          : tex(value);
      return '\\frac{${operand(m[1]!)}}{${operand(m[2]!)}}';
    });
    const superscripts = {
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
    };
    s = s.replaceAllMapped(
      RegExp(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+'),
      (m) => '^{${m[0]!.split('').map((c) => superscripts[c]).join()}}',
    );
    s = s.replaceAllMapped(RegExp(r'√\(([^()]+)\)'), (m) => '\\sqrt{${m[1]}}');
    s = s.replaceAllMapped(
      RegExp(r'√([A-Za-z0-9]+)'),
      (m) => '\\sqrt{${m[1]}}',
    );
    const subscripts = {
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
    s = s.replaceAllMapped(
      RegExp(r'[₀₁₂₃₄₅₆₇₈₉]+'),
      (m) => '_{${m[0]!.split('').map((c) => subscripts[c]).join()}}',
    );
    s = s.replaceAllMapped(RegExp(r'\^([+-]?\d+)'), (m) => '^{${m[1]}}');
    s = s.replaceAllMapped(
      RegExp(r'(?<!\\)\b(sin|cos|tan|ctg|tg|ln|log)(?=\(|\s|\^)'),
      (m) => ['tg', 'ctg'].contains(m[1])
          ? '\\operatorname{${m[1]}}'
          : '\\${m[1]}',
    );
    return s
        .replaceAll('·', r'\cdot ')
        .replaceAll('×', r'\times ')
        .replaceAll('÷', r'\div ')
        .replaceAll('−', '-')
        .replaceAll('≤', r'\leq ')
        .replaceAll('≥', r'\geq ')
        .replaceAll('≠', r'\neq ')
        .replaceAll('π', r'\pi ')
        .replaceAll('α', r'\alpha ')
        .replaceAll('β', r'\beta ')
        .replaceAll('θ', r'\theta ')
        .replaceAll('Δ', r'\Delta ')
        .replaceAll('∞', r'\infty ');
  }

  static List<({String content, bool math})> parts(String input) {
    const vulgar = {
      '½': '1/2',
      '⅓': '1/3',
      '⅔': '2/3',
      '¼': '1/4',
      '¾': '3/4',
      '⅕': '1/5',
      '⅖': '2/5',
      '⅗': '3/5',
      '⅘': '4/5',
      '⅙': '1/6',
      '⅚': '5/6',
      '⅛': '1/8',
      '⅜': '3/8',
      '⅝': '5/8',
      '⅞': '7/8',
    };
    input = input.replaceAllMapped(
      RegExp(r'(\d*)([½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])'),
      (m) => '\$${m[1]}${tex(vulgar[m[2]]!)}\$',
    );
    final result = <({String content, bool math})>[];
    void plain(String value) {
      // Only notation with an explicit mathematical sign is promoted to math.
      // Dates, web addresses and prose stay as ordinary text.
      final pattern = RegExp(
        '$_atom(?:\\s*[+−\\-×·÷/=^≤≥≠]\\s*(?:$_atom|\\?))+|√\\([^()\\n]+\\)|√[A-Za-z0-9]+|[A-Za-z0-9]+(?:[²³⁴⁵⁶⁷⁸⁹⁰¹]+|\\^[+-]?\\d+)',
      );
      var end = 0;
      for (final m in pattern.allMatches(value)) {
        if (m.start > end) {
          result.add((content: value.substring(end, m.start), math: false));
        }
        final formula = m[0]!;
        final date = RegExp(r'^\d{1,4}/\d{1,2}/\d{1,4}$').hasMatch(formula);
        result.add((content: date ? formula : tex(formula), math: !date));
        end = m.end;
      }
      if (end < value.length) {
        result.add((content: value.substring(end), math: false));
      }
    }

    var end = 0;
    for (final m in RegExp(r'\$([^$]+)\$').allMatches(input)) {
      plain(input.substring(end, m.start));
      result.add((content: m[1]!, math: true));
      end = m.end;
    }
    plain(input.substring(end));
    return result;
  }
}

class MathText extends StatelessWidget {
  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  @override
  Widget build(BuildContext context) {
    final effective = DefaultTextStyle.of(context).style.merge(style);
    final parts = MathNotation.parts(text);
    if (!parts.any((p) => p.math)) {
      return Text(text, style: effective, textAlign: textAlign);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 48;
        return Text.rich(
          TextSpan(
            children: [
              for (final p in parts)
                if (!p.math)
                  TextSpan(text: p.content)
                else
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 3,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Math.tex(
                            p.content,
                            textStyle: effective,
                            mathStyle: MathStyle.display,
                            onErrorFallback: (_) =>
                                Text(p.content, style: effective),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          style: effective,
          textAlign: textAlign,
        );
      },
    );
  }
}
