/// Логотип приложения — минималистичная белая лестница

import 'package:flutter/material.dart';

/// Логотип: синий фон + белая лестница (для светлых экранов)
class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 80, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StairsPainter(color: color ?? Colors.white),
        size: Size(size, size),
      ),
    );
  }
}

/// Логотип в синем квадрате — иконка приложения
class AppLogoIcon extends StatelessWidget {
  final double size;

  const AppLogoIcon({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: CustomPaint(
        painter: _StairsPainter(color: Colors.white),
        size: Size(size, size),
      ),
    );
  }
}

/// Лестница — единый силуэт без зазоров
class _StairsPainter extends CustomPainter {
  final Color color;

  const _StairsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final pad  = w * 0.06;
    final step = (w - pad * 2) / 3;
    final base = h - pad;
    final rr   = step * 0.18;

    final path = Path()
      ..moveTo(pad + rr, base)
      ..lineTo(w - pad - rr, base)
      ..arcToPoint(Offset(w - pad, base - rr),   radius: Radius.circular(rr))
      ..lineTo(w - pad, pad + rr)
      ..arcToPoint(Offset(w - pad - rr, pad),     radius: Radius.circular(rr))
      ..lineTo(pad + step * 2 + rr, pad)
      ..arcToPoint(Offset(pad + step * 2, pad + rr), radius: Radius.circular(rr))
      ..lineTo(pad + step * 2, base - step * 2)
      ..lineTo(pad + step,     base - step * 2)
      ..lineTo(pad + step,     base - step)
      ..lineTo(pad + rr,       base - step)
      ..arcToPoint(Offset(pad, base - step + rr), radius: Radius.circular(rr))
      ..lineTo(pad, base - rr)
      ..arcToPoint(Offset(pad + rr, base),        radius: Radius.circular(rr))
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StairsPainter old) => old.color != color;
}

/// Логотип с названием (для онбординга и др.)
class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  final Color? textColor;

  const AppLogoWithText({super.key, this.logoSize = 80, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoIcon(size: logoSize),
        const SizedBox(height: 16),
        Text(
          'Algeon',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textColor ?? const Color(0xFF2563EB),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
