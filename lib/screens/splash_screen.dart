/// Splash Screen — лестница поднимается снизу вверх как единый объект

import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../services/progress_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Лого поднимается вверх целиком
  late Animation<double> _logoY;
  late Animation<double> _logoOp;

  // Текст появляется после
  late Animation<double> _textOp;
  late Animation<double> _subOp;
  late Animation<double> _subSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Лого: поднимается от 110px ниже позиции до нужного места
    _logoY = Tween<double>(begin: 110, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic),
      ),
    );
    _logoOp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.36, curve: Curves.easeOut),
      ),
    );

    // Текст появляется когда лого уже на месте
    _textOp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.56, 0.78, curve: Curves.easeOut),
      ),
    );
    _subOp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );
    _subSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().whenComplete(_navigate);
  }

  void _navigate() {
    if (!mounted) return;
    if (ProgressService.isOnboardingComplete()) {
      context.go(AppRoutes.learn);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    // Лого: не больше 68% ширины И 52% высоты, чтобы влезало на экран
    final logoSz = min(screen.width * 0.68, screen.height * 0.52).clamp(160.0, 340.0);

    // Scaffold снаружи — не блокирует касания следующего экрана
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _navigate,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Лого — поднимается целиком снизу вверх
                  Transform.translate(
                    offset: Offset(0, _logoY.value),
                    child: Opacity(
                      opacity: _logoOp.value,
                      child: SizedBox(
                        width: logoSz,
                        height: logoSz,
                        child: const CustomPaint(painter: _StairsPainter()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Название
                  Opacity(
                    opacity: _textOp.value,
                    child: const Text(
                      'Algeon',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E3A8A),
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Субтитр
                  Transform.translate(
                    offset: Offset(0, _subSlide.value),
                    child: Opacity(
                      opacity: _subOp.value,
                      child: const Text(
                        'Математика с пониманием',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Рисует лестницу как ЕДИНЫЙ силуэт (один Path, без зазоров).
/// Форма: три ступени — левый профиль образует «лесенку» снизу-слева вверх-вправо.
/// Внешние углы скруглены, внутренние (вогнутые) — острые.
class _StairsPainter extends CustomPainter {
  const _StairsPainter();

  static const _blue = Color(0xFF2563EB);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = _blue
      ..style = PaintingStyle.fill;

    final pad  = w * 0.06;
    final inner = w - pad * 2;
    final step  = inner / 3;   // размер одной ступени
    final base  = h - pad;     // нижняя граница
    final rr    = step * 0.16; // радиус скругления внешних углов

    // Единый силуэт лестницы (обход по часовой стрелке):
    //   - 5 выпуклых (скруглённых) углов: BL, BR, TR, step3-TL, step1-left-TL
    //   - 3 вогнутых (острых) угла внутри ступеней
    final path = Path()
      ..moveTo(pad + rr, base)                              // старт на нижней кромке (после BL)
      ..lineTo(w - pad - rr, base)                          // нижняя кромка →
      ..arcToPoint(Offset(w - pad, base - rr),             // BR скруглённый угол
          radius: Radius.circular(rr))
      ..lineTo(w - pad, pad + rr)                           // правая кромка ↑
      ..arcToPoint(Offset(w - pad - rr, pad),              // TR скруглённый угол
          radius: Radius.circular(rr))
      ..lineTo(pad + step * 2 + rr, pad)                   // верх ступени 3 ←
      ..arcToPoint(Offset(pad + step * 2, pad + rr),       // TL ступени 3 скруглённый
          radius: Radius.circular(rr))
      ..lineTo(pad + step * 2, base - step * 2)            // левая кромка ступени 3 ↓ (острый)
      ..lineTo(pad + step,     base - step * 2)            // внутренний уступ ←      (острый)
      ..lineTo(pad + step,     base - step)                // левая кромка ступени 2 ↓ (острый)
      ..lineTo(pad + rr,       base - step)                // верх ступени 1 ← (к TL-left)
      ..arcToPoint(Offset(pad, base - step + rr),          // TL-left скруглённый угол
          radius: Radius.circular(rr))
      ..lineTo(pad, base - rr)                             // левая кромка ↓
      ..arcToPoint(Offset(pad + rr, base),                 // BL скруглённый угол
          radius: Radius.circular(rr))
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StairsPainter old) => false;
}
