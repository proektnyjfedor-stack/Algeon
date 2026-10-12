import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/topic_lessons.dart';
import 'math_text.dart';

class TopicLessonCard extends StatelessWidget {
  const TopicLessonCard({super.key, required this.lesson});
  final TopicLesson lesson;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            MathText(
              lesson.meaning,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(8),
              child: Semantics(
                label: 'Иллюстрация правила: ${lesson.title}',
                image: true,
                child: SizedBox(
                  height: 210,
                  child: CustomPaint(
                    painter: LessonDiagramPainter(lesson.visual, colors),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Иллюстрация правила',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Text(
              'Разберём по шагам',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            MathText(
              lesson.example,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < lesson.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MathText(
                        lesson.steps[i],
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24),
            Text(
              'Где легко ошибиться',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            MathText(
              lesson.pitfall,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deterministic vector diagrams: all plotted values are explicitly labelled teaching examples.
class LessonDiagramPainter extends CustomPainter {
  LessonDiagramPainter(this.kind, this.colors);
  final String kind;
  final ColorScheme colors;
  double scale = 1;
  late Canvas c;
  Paint get ink => Paint()
    ..color = colors.primary
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  Paint get muted => Paint()
    ..color = colors.onSurfaceVariant
    ..strokeWidth = 1.3
    ..style = PaintingStyle.stroke;
  void text(
    String value,
    double x,
    double y, {
    Color? color,
    double fontSize = 13,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: math.max(fontSize, 11 / scale),
          color: color ?? colors.onSurface,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 290 - x.clamp(0, 270));
    p.paint(c, Offset(x, y));
  }

  void line(double x, double y, double a, double b, {bool secondary = false}) =>
      c.drawLine(Offset(x, y), Offset(a, b), secondary ? muted : ink);
  void dot(double x, double y, {bool open = false}) => c.drawCircle(
    Offset(x, y),
    4,
    open ? ink : (Paint()..color = colors.primary),
  );
  void rect(double x, double y, double w, double h, {bool fill = false}) =>
      c.drawRect(
        Rect.fromLTWH(x, y, w, h),
        fill ? (Paint()..color = colors.primary.withValues(alpha: .2)) : ink,
      );
  void path(List<Offset> points, {bool fill = false, bool close = true}) {
    final p = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      p.lineTo(pt.dx, pt.dy);
    }
    if (close) p.close();
    c.drawPath(
      p,
      fill ? (Paint()..color = colors.primary.withValues(alpha: .18)) : ink,
    );
  }

  void arrow(double x, double y, double a, double b) {
    line(x, y, a, b);
    final angle = math.atan2(b - y, a - x);
    for (final delta in [-.5, .5]) {
      line(
        a,
        b,
        a - 9 * math.cos(angle + delta),
        b - 9 * math.sin(angle + delta),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    c = canvas;
    scale = math.min(size.width / 300, size.height / 200);
    c.save();
    c.translate(
      (size.width - 300 * scale) / 2,
      (size.height - 200 * scale) / 2,
    );
    c.scale(scale);
    switch (kind) {
      case 'trigTriangle':
      case 'triangle':
      case 'pythagoras':
        path([
          const Offset(50, 160),
          const Offset(250, 160),
          const Offset(50, 10),
        ]);
        line(50, 147, 63, 147);
        line(63, 147, 63, 160);
        text('4', 145, 168);
        text('3', 28, 80);
        text('5', 158, 65);
        if (kind == 'trigTriangle') {
          c.drawArc(
            const Rect.fromLTWH(210, 120, 80, 80),
            math.pi,
            .64,
            false,
            ink,
          );
          text('α', 210, 135);
          text('sin α = 0,6', 95, 185);
        }
        if (kind == 'pythagoras') text('3² + 4² = 5²', 90, 185);
        if (kind == 'triangle') text('S = 4 × 3 ÷ 2 = 6', 85, 185);
      case 'unitCircle':
      case 'trigEquation':
      case 'trigInequality':
        unitCircle();
      case 'line':
      case 'parabola':
      case 'quadraticRoots':
      case 'system':
      case 'cubic':
      case 'exponential':
      case 'logarithm':
      case 'derivative':
      case 'integral':
        graph();
      case 'units':
        for (var i = 0; i < 10; i++) {
          for (var j = 0; j < 10; j++) {
            rect(80 + i * 12, 25 + j * 12, 12, 12, fill: true);
            rect(80 + i * 12, 25 + j * 12, 12, 12);
          }
        }
        text('100 см', 108, 155);
        text('1 м² = 10 000 см²', 55, 182);
      case 'rectangle':
        for (var i = 0; i < 4; i++) {
          for (var j = 0; j < 3; j++) {
            rect(65 + i * 40, 30 + j * 40, 40, 40, fill: true);
            rect(65 + i * 40, 30 + j * 40, 40, 40);
          }
        }
        text('4', 140, 160);
        text('3', 40, 80);
        text('12 равных клеток', 80, 183);
      case 'shapes':
        path([
          const Offset(20, 125),
          const Offset(70, 30),
          const Offset(120, 125),
        ]);
        rect(165, 35, 100, 90);
        text('3 стороны', 22, 150);
        text('4 стороны', 165, 150);
      case 'anglesTriangle':
        final h =
            190 /
            (1 / math.tan(50 * math.pi / 180) +
                1 / math.tan(60 * math.pi / 180));
        final x = 50 + h / math.tan(50 * math.pi / 180);
        path([
          const Offset(50, 160),
          const Offset(240, 160),
          Offset(x, 160 - h),
        ]);
        text('50°', 63, 137);
        text('60°', 198, 137);
        text('70°', x - 12, 160 - h + 15);
        text('50° + 60° + 70° = 180°', 50, 183);
      case 'angles':
        line(20, 150, 280, 150);
        line(150, 150, 202, 39);
        dot(150, 150);
        c.drawArc(
          const Rect.fromLTWH(110, 110, 80, 80),
          -math.pi,
          math.pi,
          false,
          muted,
        );
        text('115°', 91, 108);
        text('65°', 177, 112);
        text('Развёрнутый угол: 180°', 60, 177);
      case 'circle':
      case 'inscribed':
      case 'polygon':
        circleDiagram();
      case 'similar':
        path([
          const Offset(20, 150),
          const Offset(100, 150),
          const Offset(20, 90),
        ]);
        path([
          const Offset(125, 150),
          const Offset(285, 150),
          const Offset(125, 30),
        ]);
        text('4', 52, 157);
        text('3', 4, 107);
        text('8', 200, 157);
        text('6', 106, 80);
        text('k = 2', 123, 180);
      case 'coordinates':
        arrow(30, 165, 280, 165);
        arrow(30, 165, 30, 10);
        dot(80, 125);
        dot(230, 45);
        arrow(80, 125, 230, 45);
        line(80, 125, 230, 125, secondary: true);
        line(230, 125, 230, 45, secondary: true);
        text('A(1; 1)', 52, 138);
        text('B(4; 3)', 190, 20);
        text('+3', 140, 130);
        text('+2', 238, 80);
        text('x', 280, 168);
        text('y', 13, 5);
      case 'solid':
      case 'cube':
      case 'space':
        solid();
      case 'cylinder':
        c.drawOval(const Rect.fromLTWH(20, 25, 100, 30), ink);
        c.drawOval(const Rect.fromLTWH(20, 140, 100, 30), ink);
        line(20, 40, 20, 155);
        line(120, 40, 120, 155);
        line(70, 40, 120, 40);
        c.drawOval(const Rect.fromLTWH(180, 140, 100, 30), ink);
        line(230, 25, 180, 155);
        line(230, 25, 280, 155);
        line(230, 25, 230, 155, secondary: true);
        text('r = 2', 45, 62);
        text('h = 3', 45, 100);
        text('h = 3', 234, 95);
        text('12π', 50, 177);
        text('4π', 215, 177);
      case 'sphere':
        c.drawCircle(const Offset(150, 95), 75, ink);
        c.drawOval(const Rect.fromLTWH(75, 70, 150, 50), muted);
        line(150, 95, 225, 95);
        dot(150, 95);
        text('r = 3', 169, 78);
        text('Сфера: поверхность, шар: объём', 40, 182);
      case 'clock':
        c.drawCircle(const Offset(150, 95), 70, ink);
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi / 6 - math.pi / 2;
          line(
            150 + 64 * math.cos(a),
            95 + 64 * math.sin(a),
            150 + 70 * math.cos(a),
            95 + 70 * math.sin(a),
          );
        }
        arrow(150, 95, 205, 95);
        arrow(
          150,
          95,
          150 + 35 * math.cos(-math.pi / 8),
          95 + 35 * math.sin(-math.pi / 8),
        );
        dot(150, 95);
        text('12', 140, 5);
        text('3', 227, 86);
        text('6', 145, 167);
        text('9', 57, 86);
        text('2:15 — два часа пятнадцать минут', 25, 187, fontSize: 12);
      case 'numberline':
      case 'subtract':
      case 'compare':
      case 'inequality':
      case 'intervals':
        numberLine();
      case 'fraction':
      case 'mixed':
      case 'percent':
      case 'decimal':
        fractions();
      case 'double':
      case 'count':
      case 'ten':
      case 'multiply':
      case 'remainder':
        counters();
      case 'statistics':
        for (var i = 0; i < 3; i++) {
          final v = [2, 4, 9][i];
          rect(55 + i * 70, 160 - v * 14, 40, v * 14, fill: true);
          rect(55 + i * 70, 160 - v * 14, 40, v * 14);
          text('$v', 65 + i * 70, 135 - v * 14);
        }
        line(30, 160, 280, 160, secondary: true);
        line(30, 90, 280, 90, secondary: true);
        text('Среднее: 5', 80, 180);
      case 'probability':
        for (var i = 0; i < 6; i++) {
          final x = 25 + (i % 3) * 90.0, y = 20 + (i ~/ 3) * 75.0;
          rect(x, y, 65, 55, fill: i.isOdd);
          rect(x, y, 65, 55);
          text('${i + 1}', x + 25, y + 18);
        }
        text('Подходят 2, 4, 6: 3 из 6', 55, 180);
      case 'tree':
        for (var i = 0; i < 2; i++) {
          final y = 45 + i * 105.0;
          line(30, 100, 110, y);
          dot(110, y);
          text('Ф${i + 1}', 75, y - 25);
          for (var j = 0; j < 3; j++) {
            final end = y - 30 + j * 30.0;
            line(110, y, 230, end);
            dot(230, end);
            text('Б${j + 1}', 245, end - 8);
          }
        }
      case 'sequence':
        for (var i = 0; i < 4; i++) {
          final x = 15 + i * 75.0;
          text('${2 + 3 * i}', x + 12, 80, fontSize: 24);
          if (i < 3) {
            arrow(x + 30, 120, x + 72, 120);
            text('+3', x + 40, 140);
          }
        }
        text('2 → 5 → 8 → 11', 85, 25);
      case 'place':
        for (var i = 0; i < 3; i++) {
          rect(15 + i * 95, 30, 80, 110, fill: true);
          text(['Сотни', 'Десятки', 'Единицы'][i], 19 + i * 95, 45);
          text(['3', '0', '4'][i], 43 + i * 95, 83, fontSize: 25);
        }
        text('304 = 300 + 0 + 4', 75, 170);
      case 'mass':
      case 'length':
      case 'scale':
        arrow(35, 95, 265, 95);
        text(
          kind == 'mass'
              ? '2 кг'
              : kind == 'length'
              ? '2 м'
              : '3 см на плане',
          30,
          50,
        );
        text(
          kind == 'mass'
              ? '2000 г'
              : kind == 'length'
              ? '200 см'
              : '300 см в жизни',
          170,
          118,
        );
        text(kind == 'mass' ? '× 1000' : '× 100', 120, 60);
        text(
          kind == 'scale' ? 'Масштаб 1:100' : 'Перевод в меньшие единицы',
          35,
          177,
        );
      case 'motion':
        arrow(25, 100, 275, 100);
        for (var i = 0; i < 3; i++) {
          dot(30 + i * 120, 100);
          text(['0 км', '60 км', '120 км'][i], 18 + i * 115, 120);
        }
        text('1 час', 70, 70);
        text('1 час', 190, 70);
        text('60 км/ч × 2 ч = 120 км', 60, 175);
      case 'factors':
        text('12 = 2 × 2 × 3', 55, 30, fontSize: 20);
        text('18 = 2 × 3 × 3', 55, 85, fontSize: 20);
        text('Общие множители: 2 × 3', 40, 145);
        text('НОД = 6', 110, 175);
      case 'powers':
        for (var i = 0; i < 7; i++) {
          for (var j = 0; j < 7; j++) {
            rect(65 + i * 20, 15 + j * 20, 20, 20, fill: true);
            rect(65 + i * 20, 15 + j * 20, 20, 20);
          }
        }
        text('7', 130, 162);
        text('7', 43, 75);
        text('7² = 49, √49 = 7', 70, 184);
      case 'balance':
      case 'balanceBasic':
        path([
          const Offset(130, 150),
          const Offset(170, 150),
          const Offset(150, 110),
        ]);
        line(150, 110, 150, 45);
        line(40, 60, 260, 60);
        rect(30, 75, 95, 40, fill: true);
        rect(175, 75, 95, 40, fill: true);
        text(kind == 'balance' ? '2x + 6' : 'x + 6', 43, 87);
        text('14', 208, 87);
        line(75, 60, 75, 75);
        line(222, 60, 222, 75);
        text('Равные действия с обеими частями', 25, 180, fontSize: 12);
      case 'divide':
        text('144 = 120 + 24', 45, 35, fontSize: 22);
        text('120 ÷ 12 = 10', 55, 90);
        text('24 ÷ 12 = 2', 55, 125);
        text('10 + 2 = 12', 75, 170, fontSize: 22);
      case 'powerCube':
        text('2 × 2 × 2', 65, 55, fontSize: 26);
        arrow(150, 100, 150, 130);
        text('2³ = 8', 100, 155, fontSize: 24);
      case 'monomial':
        text('3x² × 2x³', 65, 35, fontSize: 26);
        text('3 × 2 = 6', 90, 95);
        text('x² × x³ = x⁵', 75, 130);
        text('6x⁵', 120, 165, fontSize: 24);
      case 'algebraFraction':
        text('(x − 1)(x + 1)', 70, 25, fontSize: 20);
        line(65, 55, 245, 55);
        text('x − 1', 125, 65, fontSize: 20);
        arrow(150, 100, 150, 125);
        text('x + 1', 115, 135, fontSize: 22);
        text('Условие: x ≠ 1', 95, 180);
      case 'operations':
      case 'algebra':
        text(
          kind == 'operations' ? '18 − 2 × (3 + 4)' : '2(x + 3) + 3x',
          35,
          25,
          fontSize: 22,
        );
        arrow(150, 62, 150, 92);
        text(
          kind == 'operations' ? '18 − 2 × 7' : '2x + 6 + 3x',
          60,
          100,
          fontSize: 20,
        );
        arrow(150, 135, 150, 155);
        text(kind == 'operations' ? '4' : '5x + 6', 105, 165, fontSize: 24);
      default:
        rect(35, 60, 230, 45, fill: true);
        line(165, 60, 165, 105);
        text('Известная часть', 37, 115);
        text('Остаток', 185, 115);
        text('Целое = сумма частей', 62, 30);
    }
    c.restore();
  }

  void counters() {
    if (kind == 'double') {
      for (var row = 0; row < 2; row++) {
        for (var i = 0; i < 6; i++) {
          c.drawCircle(
            Offset(35 + i * 45.0, 55 + row * 65.0),
            12,
            Paint()..color = colors.primary,
          );
        }
      }
      text('6 + 6 = 12', 100, 170);
      return;
    }
    final n = kind == 'count'
        ? 7
        : kind == 'ten'
        ? 13
        : kind == 'remainder'
        ? 14
        : 12;
    final columns = kind == 'count'
        ? 7
        : kind == 'ten'
        ? 10
        : 4;
    for (var i = 0; i < n; i++) {
      final x = kind == 'count'
          ? 25 + i * 40.0
          : 30 + (i % columns) * (kind == 'ten' ? 26.0 : 65.0);
      final y = kind == 'count' ? 75.0 : 30 + (i ~/ columns) * 45.0;
      c.drawCircle(
        Offset(x, y),
        kind == 'ten' ? 9 : 12,
        Paint()
          ..color =
              (kind == 'count' && i < 3 ||
                  kind == 'ten' && i < 10 ||
                  kind == 'remainder' && i >= 12)
              ? colors.secondary
              : colors.primary,
      );
    }
    text(
      kind == 'count'
          ? '3 + 4 = 7'
          : kind == 'ten'
          ? '10 + 3 = 13'
          : kind == 'remainder'
          ? '14 = 4 × 3 + 2'
          : '3 ряда по 4: 3 × 4 = 12',
      45,
      180,
    );
  }

  void fractions() {
    if (kind == 'mixed') {
      for (var whole = 0; whole < 3; whole++) {
        for (var part = 0; part < 3; part++) {
          final x = 20 + whole * 90 + part * 25.0;
          rect(x, 65, 25, 60, fill: whole < 2 || part == 0);
          rect(x, 65, 25, 60);
        }
      }
      text('2 целых и 1 треть = 7 третей', 45, 165);
      return;
    }
    final denominator = kind == 'percent'
        ? 4
        : kind == 'decimal'
        ? 10
        : 6;
    final numerator = kind == 'percent'
        ? 1
        : kind == 'decimal'
        ? 3
        : 3;
    for (var i = 0; i < denominator; i++) {
      rect(
        20 + i * 260 / denominator,
        65,
        260 / denominator,
        65,
        fill: i < numerator,
      );
      rect(20 + i * 260 / denominator, 65, 260 / denominator, 65);
    }
    text(
      kind == 'percent'
          ? '1 часть из 4 = 25%'
          : kind == 'decimal'
          ? '3 десятых = 0,3'
          : kind == 'mixed'
          ? 'Каждое целое делится на равные доли'
          : '3 части из 6 — половина',
      30,
      165,
    );
  }

  void numberLine() {
    arrow(15, 105, 285, 105);
    final isBasic = kind == 'subtract' || kind == 'compare';
    for (var i = 0; i < 7; i++) {
      final x = 30 + i * 40.0;
      line(x, 100, x, 110, secondary: true);
      text('${isBasic ? i + 3 : i - 3}', x - 4, 115);
    }
    if (kind == 'subtract') {
      arrow(270, 70, 110, 70);
      dot(270, 105);
      dot(110, 105);
      text('9 − 4 = 5', 105, 35);
    } else if (kind == 'compare') {
      dot(70, 105);
      dot(190, 105);
      text('7 > 4', 120, 40);
    } else if (kind == 'inequality') {
      dot(30, 105, open: true);
      arrow(35, 80, 280, 80);
      text('x > −3', 110, 35);
    } else if (kind == 'intervals') {
      dot(70, 105, open: true);
      dot(190, 105, open: true);
      arrow(65, 80, 15, 80);
      arrow(195, 80, 280, 80);
      text('+', 30, 45);
      text('−', 125, 45);
      text('+', 240, 45);
    } else {
      dot(70, 105);
      dot(270, 105);
      line(70, 75, 270, 75);
      text('5 единиц', 125, 45);
    }
  }

  void unitCircle() {
    const center = Offset(150, 95);
    const r = 75.0;
    c.drawCircle(center, r, ink);
    arrow(45, 95, 265, 95);
    arrow(150, 185, 150, 5);
    text('1', 228, 100);
    text('−1', 54, 100);
    text('1', 155, 10);
    text('0', 135, 100);
    if (kind == 'trigInequality') {
      c.drawArc(
        const Rect.fromLTWH(75, 20, 150, 150),
        math.pi,
        math.pi,
        false,
        ink..strokeWidth = 5,
      );
      dot(75, 95, open: true);
      dot(225, 95, open: true);
      text('sin x > 0: верхняя дуга', 55, 185);
      return;
    }
    const a = math.pi / 6;
    final point = Offset(150 + r * math.cos(a), 95 - r * math.sin(a));
    line(150, 95, point.dx, point.dy);
    dot(point.dx, point.dy);
    line(point.dx, point.dy, point.dx, 95, secondary: true);
    line(point.dx, point.dy, 150, point.dy, secondary: true);
    text('30°', 175, 80);
    text('sin x', 100, 47);
    text('cos x', 172, 110);
    if (kind == 'trigEquation') {
      final second = Offset(150 - r * math.cos(a), point.dy);
      dot(second.dx, second.dy);
      line(150, 95, second.dx, second.dy);
      text('150°', 85, 75);
      text('Одна высота — два угла', 65, 185);
    } else {
      text('(cos x; sin x)', 168, 25);
      text('Угол 30°: высота равна 0,5', 50, 185);
    }
  }

  void circleDiagram() {
    const center = Offset(150, 95);
    const radius = 72.0;
    c.drawCircle(center, radius, ink);
    dot(150, 95);
    if (kind == 'circle') {
      line(78, 95, 222, 95);
      text('r = 3', 162, 70);
      text('d = 6', 126, 112);
      text('C = 2πr, S = πr²', 78, 183);
      return;
    }
    if (kind == 'polygon') {
      final points = List.generate(
        6,
        (i) => Offset(
          150 + radius * math.cos(i * math.pi / 3),
          95 + radius * math.sin(i * math.pi / 3),
        ),
      );
      path(points);
      line(150, 95, points[0].dx, points[0].dy);
      line(150, 95, points[1].dx, points[1].dy);
      text('60°', 163, 108);
      text('6 равных центральных углов', 50, 183);
      return;
    }
    final a = Offset(
      150 + radius * math.cos(-math.pi / 3),
      95 + radius * math.sin(-math.pi / 3),
    );
    final b = Offset(
      150 + radius * math.cos(40 * math.pi / 180),
      95 + radius * math.sin(40 * math.pi / 180),
    );
    const vertex = Offset(78, 95);
    line(150, 95, a.dx, a.dy);
    line(150, 95, b.dx, b.dy);
    line(vertex.dx, vertex.dy, a.dx, a.dy);
    line(vertex.dx, vertex.dy, b.dx, b.dy);
    text('100°', 175, 88);
    text('50°', 94, 84);
    text('Вписанный угол вдвое меньше', 38, 183);
  }

  void solid() {
    const a = Offset(45, 155),
        b = Offset(205, 155),
        d = Offset(45, 65),
        e = Offset(105, 30);
    path([a, b, const Offset(205, 65), d]);
    path([d, const Offset(205, 65), const Offset(265, 30), e]);
    path([
      b,
      const Offset(265, 120),
      const Offset(265, 30),
      const Offset(205, 65),
    ]);
    line(a.dx, a.dy, 105, 120, secondary: true);
    line(105, 120, 265, 120, secondary: true);
    line(105, 120, e.dx, e.dy, secondary: true);
    text(
      kind == 'space'
          ? 'x'
          : kind == 'cube'
          ? 'a'
          : '4',
      120,
      160,
    );
    text(
      kind == 'space'
          ? 'y'
          : kind == 'cube'
          ? 'a'
          : '3',
      235,
      137,
    );
    text(
      kind == 'space'
          ? 'z'
          : kind == 'cube'
          ? 'a'
          : '2',
      20,
      100,
    );
    text(
      kind == 'space'
          ? 'Три направления в пространстве'
          : kind == 'cube'
          ? '6 граней, 12 рёбер, 8 вершин'
          : 'V = 4 × 3 × 2 = 24',
      48,
      185,
    );
  }

  void graph() {
    final xMin = kind == 'integral'
        ? -.5
        : kind == 'logarithm'
        ? -.5
        : -3.0;
    final xMax = kind == 'integral' ? 3.0 : 5.0;
    const yMin = -3.0, yMax = 6.0;
    Offset pt(double x, double y) => Offset(
      25 + (x - xMin) / (xMax - xMin) * 250,
      175 - (y - yMin) / (yMax - yMin) * 155,
    );
    final zero = pt(0, 0);
    arrow(25, zero.dy, 285, zero.dy);
    arrow(zero.dx, 180, zero.dx, 12);
    text('x', 281, zero.dy + 5);
    text('y', zero.dx + 5, 0);
    text('0', zero.dx - 13, zero.dy + 3);
    for (final v in [1.0, 2.0, 3.0]) {
      final p = pt(v, 0);
      line(p.dx, p.dy - 3, p.dx, p.dy + 3, secondary: true);
      text('${v.toInt()}', p.dx - 3, p.dy + 5);
    }
    for (final v in [1.0, 3.0]) {
      final p = pt(0, v);
      line(p.dx - 3, p.dy, p.dx + 3, p.dy, secondary: true);
      text('${v.toInt()}', p.dx - 16, p.dy - 8);
    }
    double f(double x) => switch (kind) {
      'line' => 2 * x + 1,
      'system' => 5 - x,
      'parabola' => x * x - 4 * x + 3,
      'quadraticRoots' => x * x - 5 * x + 6,
      'cubic' => x * x * x,
      'exponential' => math.pow(2, x).toDouble(),
      'logarithm' => math.log(x) / math.ln2,
      'integral' => 2 * x,
      _ => x * x,
    };
    c.save();
    c.clipRect(const Rect.fromLTWH(25, 15, 250, 160));
    if (kind == 'integral') {
      path([pt(0, 0), pt(2, 0), pt(2, 4)], fill: true);
    }
    final points = <Offset>[];
    for (var i = 0; i <= 400; i++) {
      final x = xMin + (xMax - xMin) * i / 400;
      if (kind == 'logarithm' && x <= 0) continue;
      points.add(pt(x, f(x)));
    }
    path(points, close: false);
    if (kind == 'system') {
      path([pt(xMin, xMin - 1), pt(xMax, xMax - 1)], close: false);
      dot(pt(3, 2).dx, pt(3, 2).dy);
    }
    if (kind == 'derivative') {
      final a = pt(-2, -5), b = pt(4, 7);
      c.drawLine(a, b, muted);
      dot(pt(1, 1).dx, pt(1, 1).dy);
    }
    c.restore();
    if (kind == 'parabola') {
      dot(pt(2, -1).dx, pt(2, -1).dy);
      text('(2; −1)', pt(2, -1).dx + 6, pt(2, -1).dy - 8);
    }
    text(
      switch (kind) {
        'line' => 'y = 2x + 1',
        'system' => 'x + y = 5; x − y = 1',
        'parabola' => 'y = x² − 4x + 3',
        'quadraticRoots' => 'Нули графика: 2 и 3',
        'cubic' => 'y = x³',
        'exponential' => 'y = 2ˣ',
        'logarithm' => 'y = log₂ x',
        'integral' => 'Площадь под y = 2x: 4',
        _ => 'y = x², касательная при x = 1',
      },
      35,
      186,
      fontSize: 12,
    );
  }

  @override
  bool shouldRepaint(covariant LessonDiagramPainter old) =>
      old.kind != kind || old.colors != colors;
}
