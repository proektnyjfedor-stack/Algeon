import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/flutter_math.dart';
// ignore: implementation_imports
import 'package:flutter_math_fork/src/parser/tex/parser.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/data/topic_theory.dart';
import 'package:math_pilot/data/exam_theory.dart';
import 'package:math_pilot/widgets/math_text.dart';

void main() {
  test(
    'Fractions preserve grouping, roots and superscripts use typesetting',
    () {
      expect(MathNotation.parts('2½').single.content, r'2\frac{1}{2}');
      expect(MathNotation.tex('(a+b)/(c+d)'), r'\frac{a+b}{c+d}');
      expect(
        MathNotation.tex('(1/2)/(3/4)'),
        r'\frac{\frac{1}{2}}{\frac{3}{4}}',
      );
      expect(MathNotation.tex('sin(x)/2'), r'\frac{\sin(x)}{2}');
      expect(MathNotation.tex('2π/3'), r'\frac{2\pi }{3}');
      expect(MathNotation.tex('1/cos²x'), r'\frac{1}{\cos^{2}x}');
      expect(MathNotation.tex('√(x² + y²)'), r'\sqrt{x^{2} + y^{2}}');
      expect(
        MathNotation.parts(
          'Вычисли 3/4 + 1/2.',
        ).where((p) => p.math).single.content,
        r'\frac{3}{4} + \frac{1}{2}',
      );
    },
  );
  test('All task, theory and exam notation parses without a raw fallback', () {
    final texts = <String>[];
    for (final task in getAllTasks()) {
      texts.addAll([
        task.question,
        task.answer,
        task.hint ?? '',
        ...?task.options,
        ...task.explanationSteps,
      ]);
    }
    for (final topic in getAllTasks().map((t) => t.topic).toSet()) {
      for (final english in [true, false]) {
        for (final section
            in getTopicTheory(topic, english: english)?.sections ??
                <TheorySection>[]) {
          texts.addAll([section.content, ...?section.items]);
        }
      }
    }
    for (final track in ['oge', 'base', 'profile']) {
      for (
        var slot = 1;
        slot <=
            (track == 'oge'
                ? 25
                : track == 'base'
                ? 21
                : 20);
        slot++
      ) {
        texts.add(examGuide(track, slot).text);
      }
    }
    final failures = <String>[];
    for (final text in texts.toSet()) {
      for (final part in MathNotation.parts(text).where((p) => p.math)) {
        try {
          TexParser(part.content, const TexParserSettings()).parse();
        } catch (error) {
          failures.add('${part.content}: $error');
        }
      }
    }
    expect(failures, isEmpty);
  });
  testWidgets('Inline fractions wrap with prose on a narrow screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: MathText(
              r'Площадь треугольника $S=\frac{ab\sin C}{2}$. Затем вычисли 3/4 + 1/2.',
              style: TextStyle(fontSize: 19),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Math), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
