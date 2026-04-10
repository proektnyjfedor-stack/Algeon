/// Splash Screen — лестница поднимается снизу вверх как единый объект

import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../services/progress_service.dart';
import '../widgets/app_logo.dart';

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
  late Animation<double> _pulse;

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
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.9, curve: Curves.easeInOut),
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
                        child: Transform.scale(
                          scale: _pulse.value,
                          child: Container(
                            width: logoSz,
                            height: logoSz,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(logoSz * 0.18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x332563EB),
                                  blurRadius: 26,
                                  offset: Offset(0, 14),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(logoSz * 0.12),
                              child: const AppLogo(size: 220, color: Color(0xFF2563EB)),
                            ),
                          ),
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
                        child: Column(
                          children: [
                            const Text(
                              'Математика с пониманием',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 84,
                              child: LinearProgressIndicator(
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(999),
                                value: _ctrl.value.clamp(0.08, 1.0),
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
                              ),
                            ),
                          ],
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
