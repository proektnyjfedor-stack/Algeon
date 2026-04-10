/// Splash Screen — крупная лестница (~половина экрана), движение вниз, фон по теме

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

  late Animation<double> _logoOp;
  late Animation<double> _textOp;
  late Animation<double> _subOp;
  late Animation<double> _subSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoOp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _textOp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.52, 0.76, curve: Curves.easeOut),
      ),
    );
    _subOp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.62, 0.86, curve: Curves.easeOut),
      ),
    );
    _subSlide = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.62, 0.86, curve: Curves.easeOut),
      ),
    );
    _pulse = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.92, curve: Curves.easeInOut),
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

  /// Смещение лестницы по Y: сверху вниз (отрицательный старт → 0).
  double _logoSlideY(double screenHeight) {
    const slideCurve = Interval(0.0, 0.62, curve: Curves.easeOutCubic);
    final t = slideCurve.transform(_ctrl.value);
    final start = -screenHeight * 0.28;
    return start * (1 - t);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final stairColor = isDark ? Colors.white : const Color(0xFF2563EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E3A8A);
    final subtitleColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);
    final progressBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0);
    const progressFg = Color(0xFF2563EB);

    final halfH = screen.height * 0.5;
    final logoSz = min(screen.width * 0.78, halfH * 0.92).clamp(200.0, 480.0);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _navigate,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            final slideY = _logoSlideY(screen.height);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: halfH,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, slideY),
                      child: Opacity(
                        opacity: _logoOp.value,
                        child: Transform.scale(
                          scale: _pulse.value,
                          child: SizedBox(
                            width: logoSz,
                            height: logoSz,
                            child: AppLogo(
                              size: logoSz,
                              color: stairColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: _textOp.value,
                          child: Text(
                            'Algeon',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Transform.translate(
                          offset: Offset(0, _subSlide.value),
                          child: Opacity(
                            opacity: _subOp.value,
                            child: Column(
                              children: [
                                Text(
                                  'Математика с пониманием',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: subtitleColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: 96,
                                  child: LinearProgressIndicator(
                                    minHeight: 5,
                                    borderRadius: BorderRadius.circular(999),
                                    value: _ctrl.value.clamp(0.06, 1.0),
                                    backgroundColor: progressBg,
                                    valueColor: AlwaysStoppedAnimation<Color>(progressFg),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
