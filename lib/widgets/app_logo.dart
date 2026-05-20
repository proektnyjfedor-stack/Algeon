/// Логотип приложения — лестница (силуэт), по умолчанию синий акцент
library;

import 'package:flutter/material.dart';

/// Цвет лестницы из брендового логотипа.
const Color kAppLogoStairBlue = Color(0xFF2388F2);

/// Логотип: единый синий силуэт лестницы с мягкими внешними углами.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StairsPainter(color: color ?? kAppLogoStairBlue),
        size: Size(size, size),
      ),
    );
  }
}

/// Иконка приложения. Теперь без дополнительного синего квадрата, чтобы везде
/// использовался один и тот же брендовый знак.
class AppLogoIcon extends StatelessWidget {
  const AppLogoIcon({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return AppLogo(size: size);
  }
}

/// Лестница из трёх ступеней. Пропорции подобраны под присланный логотип.
class _StairsPainter extends CustomPainter {
  const _StairsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final left = w * 0.17;
    final right = w * 0.83;
    final bottom = h * 0.82;
    final top = h * 0.16;
    final x1 = w * 0.38;
    final x2 = w * 0.61;
    final stepHeight = (bottom - top) / 3;
    final y1 = bottom - stepHeight;
    final y2 = bottom - stepHeight * 2;
    final r = w * 0.055;

    final path = Path()
      ..moveTo(left + r, bottom)
      ..lineTo(right - r, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - r)
      ..lineTo(right, top + r)
      ..quadraticBezierTo(right, top, right - r, top)
      ..lineTo(x2 + r, top)
      ..quadraticBezierTo(x2, top, x2, top + r)
      ..lineTo(x2, y2)
      ..lineTo(x1 + r, y2)
      ..quadraticBezierTo(x1, y2, x1, y2 + r)
      ..lineTo(x1, y1)
      ..lineTo(left + r, y1)
      ..quadraticBezierTo(left, y1, left, y1 + r)
      ..lineTo(left, bottom - r)
      ..quadraticBezierTo(left, bottom, left + r, bottom)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StairsPainter old) => old.color != color;
}

/// Логотип с названием (для онбординга и др.)
class AppLogoWithText extends StatelessWidget {
  const AppLogoWithText({super.key, this.logoSize = 80, this.textColor});
  final double logoSize;
  final Color? textColor;

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
            color: textColor ?? kAppLogoStairBlue,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
