/// Логотип приложения — лестница на чёрном фоне

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Чёрный фон
        borderRadius: BorderRadius.circular(size * 0.22), // Скруглённые углы
      ),
      child: CustomPaint(
        painter: _StairsPainter(),
        size: Size(size, size),
      ),
    );
  }
}

/// Рисует ступеньки (лестницу)
class _StairsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Градиент синий
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF60A5FA), // Светло-синий
          const Color(0xFF3B82F6), // Синий
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Размеры
    final padding = size.width * 0.2;
    final stepWidth = (size.width - padding * 2) / 3;
    final stepHeight = (size.height - padding * 2) / 3;
    
    // Рисуем ступеньки снизу вверх
    final path = Path();
    
    // Начальная точка (левый нижний угол)
    final startX = padding;
    final startY = size.height - padding;
    
    path.moveTo(startX, startY);
    
    // Первая ступенька (нижняя)
    path.lineTo(startX, startY - stepHeight);
    path.lineTo(startX + stepWidth, startY - stepHeight);
    
    // Вторая ступенька (средняя)
    path.lineTo(startX + stepWidth, startY - stepHeight * 2);
    path.lineTo(startX + stepWidth * 2, startY - stepHeight * 2);
    
    // Третья ступенька (верхняя)
    path.lineTo(startX + stepWidth * 2, startY - stepHeight * 3);
    path.lineTo(startX + stepWidth * 3, startY - stepHeight * 3);
    
    // Закрываем путь
    path.lineTo(startX + stepWidth * 3, startY);
    path.close();

    // Заливка градиентом
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Логотип с названием
class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  
  const AppLogoWithText({super.key, this.logoSize = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize),
        const SizedBox(height: 16),
        const Text(
          'MathPilot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }
}
