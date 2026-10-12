import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'math_text.dart';

/// Explicitly labelled teaching examples, never a guessed task diagram.
class TopicVisual extends StatefulWidget {
  const TopicVisual({super.key, required this.topic});
  final String topic;
  static String? kind(String topic) {
    if (topic == 'Тригонометрические функции') return 'sine';
    if (topic == 'Линейная функция') return 'line';
    if (topic == 'Функция y=ax²' || topic == 'Квадратичная функция') {
      return 'parabola';
    }
    if (['Дроби', 'Обыкновенные дроби', 'Доли и дроби'].contains(topic)) {
      return 'fraction';
    }
    if ([
      'Площади фигур',
      'Площадь треугольника',
      'Теорема Пифагора',
      'Геометрия: треугольники',
      'Треугольники',
    ].contains(topic)) {
      return 'triangle';
    }
    return null;
  }

  @override
  State<TopicVisual> createState() => _TopicVisualState();
}

class _TopicVisualState extends State<TopicVisual> {
  double parameter = 1;
  int pieces = 3;
  @override
  Widget build(BuildContext context) {
    final kind = TopicVisual.kind(widget.topic);
    if (kind == null) return const SizedBox.shrink();
    final value = parameter.toStringAsFixed(1).replaceAll('.0', '');
    final formula = switch (kind) {
      'sine' =>
        parameter == 1
            ? 'y = sin x, T = 2π'
            : 'y = sin($value x), T = 2π/$value',
      'line' => parameter == 1 ? 'y = x' : 'y = $value x',
      'parabola' => parameter == 1 ? 'y = x²' : 'y = $value x²',
      'fraction' => '$pieces/8',
      _ => 'a = 4, b = 3, c = 5; S = (4 × 3)/2 = 6',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Наглядный пример',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            MathText(formula, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Semantics(
              label: kind == 'fraction'
                  ? 'Закрашено $pieces из 8 равных частей'
                  : kind == 'triangle'
                  ? 'Прямоугольный треугольник с катетами 4 и 3, гипотенузой 5'
                  : 'График функции $formula',
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: CustomPaint(
                  painter: _TeachingPainter(
                    kind,
                    parameter,
                    pieces,
                    Theme.of(context).colorScheme,
                  ),
                ),
              ),
            ),
            if (kind != 'triangle')
              Slider(
                value: kind == 'fraction' ? pieces.toDouble() : parameter,
                min: kind == 'fraction'
                    ? 1
                    : kind == 'line'
                    ? -3
                    : 0.5,
                max: kind == 'fraction' ? 7 : 3,
                divisions: kind == 'fraction'
                    ? 6
                    : kind == 'line'
                    ? 12
                    : 5,
                label: kind == 'fraction' ? '$pieces/8' : value,
                semanticFormatterCallback: (v) => kind == 'fraction'
                    ? '${v.round()} из 8 частей'
                    : 'Коэффициент ${v.toStringAsFixed(1)}',
                onChanged: (v) => setState(() {
                  if (kind == 'fraction') {
                    pieces = v.round();
                  } else {
                    parameter = v;
                  }
                }),
              ),
            Text(
              switch (kind) {
                'sine' =>
                  'Меняй коэффициент: чем больше его модуль, тем короче период.',
                'line' =>
                  'Коэффициент задаёт наклон. При отрицательном значении функция убывает.',
                'parabola' => 'Чем больше коэффициент, тем уже парабола.',
                'fraction' =>
                  'Знаменатель — число равных частей. Числитель — сколько частей закрашено.',
                _ =>
                  'Отметка у вершины обозначает прямой угол. Площадь равна половине произведения катетов.',
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeachingPainter extends CustomPainter {
  _TeachingPainter(this.kind, this.parameter, this.pieces, this.colors);
  final String kind;
  final double parameter;
  final int pieces;
  final ColorScheme colors;
  void label(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: colors.onSurface,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = colors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    if (kind == 'fraction') {
      final w = (size.width - 16) / 8;
      for (var i = 0; i < 8; i++) {
        final rect = Rect.fromLTWH(8 + i * w, 50, w, 65);
        canvas.drawRect(
          rect,
          Paint()
            ..color = i < pieces
                ? colors.primary
                : colors.surfaceContainerHighest,
        );
        canvas.drawRect(
          rect,
          Paint()
            ..color = colors.onSurface
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      }
      label(canvas, '0', const Offset(8, 125));
      label(canvas, '1', Offset(size.width - 16, 125));
      return;
    }
    if (kind == 'triangle') {
      final scale = math.min((size.width - 80) / 4, (size.height - 50) / 3);
      final a = const Offset(32, 150),
          b = Offset(32 + 4 * scale, 150),
          c = Offset(32, 150 - 3 * scale);
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy)
          ..close(),
        ink,
      );
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy - 12)
          ..lineTo(a.dx + 12, a.dy - 12)
          ..lineTo(a.dx + 12, a.dy),
        ink,
      );
      label(canvas, '4', Offset((a.dx + b.dx) / 2, 155));
      label(canvas, '3', Offset(10, (a.dy + c.dy) / 2));
      label(canvas, '5', Offset((b.dx + c.dx) / 2 + 8, (b.dy + c.dy) / 2 - 16));
      return;
    }
    const margin = 24.0;
    final center = Offset(size.width / 2, size.height / 2);
    final xMax = kind == 'sine' ? 2 * math.pi : 4.0;
    final yMax = kind == 'sine' ? 1.5 : 4.0;
    final xScale = (size.width - 2 * margin) / (2 * xMax),
        yScale = (size.height - 2 * margin) / (2 * yMax);
    final axis = Paint()
      ..color = colors.onSurfaceVariant
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(margin, center.dy),
      Offset(size.width - 8, center.dy),
      axis,
    );
    canvas.drawLine(
      Offset(center.dx, 8),
      Offset(center.dx, size.height - 8),
      axis,
    );
    label(canvas, 'x', Offset(size.width - 12, center.dy + 5));
    label(canvas, 'y', Offset(center.dx + 5, 0));
    label(canvas, '0', center + const Offset(4, 4));
    for (final x in [-xMax / 2, xMax / 2]) {
      final px = center.dx + x * xScale;
      canvas.drawLine(
        Offset(px, center.dy - 3),
        Offset(px, center.dy + 3),
        axis,
      );
      label(
        canvas,
        kind == 'sine' ? (x < 0 ? '−π' : 'π') : x.toInt().toString(),
        Offset(px - 6, center.dy + 5),
      );
    }
    for (final y in [-1.0, 1.0]) {
      final py = center.dy - y * yScale;
      canvas.drawLine(
        Offset(center.dx - 3, py),
        Offset(center.dx + 3, py),
        axis,
      );
      label(canvas, y.toInt().toString(), Offset(center.dx + 5, py - 12));
    }
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(margin, 8, size.width - margin, size.height - 8),
    );
    final path = Path();
    for (var i = 0; i <= 600; i++) {
      final x = -xMax + 2 * xMax * i / 600;
      final y = kind == 'sine'
          ? math.sin(parameter * x)
          : kind == 'line'
          ? parameter * x
          : parameter * x * x;
      final point = Offset(center.dx + x * xScale, center.dy - y * yScale);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TeachingPainter old) =>
      old.kind != kind ||
      old.parameter != parameter ||
      old.pieces != pieces ||
      old.colors != colors;
}
