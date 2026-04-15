/// Splash Screen — логотип-лестница и надпись Algeon с анимацией входа
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<double> _textReveal;
  late Animation<double> _textSlideX;
  late Animation<double> _logoSlideX;

  bool _hapticMilestone1 = false;
  bool _hapticMilestone2 = false;
  bool _hapticMilestone3 = false;

  static const Color _splashBlue = Color(0xFF1769F2);

  void _onAnimTick() {
    final v = _ctrl.value;
    if (!_hapticMilestone1 && v >= 0.22) {
      _hapticMilestone1 = true;
      SoundService.hapticLight();
    }
    if (!_hapticMilestone2 && v >= 0.52) {
      _hapticMilestone2 = true;
      SoundService.hapticSelection();
    }
    if (!_hapticMilestone3 && v >= 0.82) {
      _hapticMilestone3 = true;
      SoundService.hapticMedium();
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ctrl.addListener(_onAnimTick);
    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.26, 0.76, curve: Curves.easeOut),
    );
    _textReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.84, curve: Curves.easeOutCubic),
    );
    _logoSlideX = Tween<double>(begin: 0, end: -16).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.24, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _textSlideX = Tween<double>(begin: -34, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.28, 0.84, curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward().whenComplete(_navigate);
  }

  void _navigate() {
    if (!mounted) return;
    SoundService.playPop();
    unawaited(SoundService.hapticDouble());
    if (ProgressService.isOnboardingComplete()) {
      context.go(AppRoutes.learn);
      return;
    }
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onAnimTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBlue,
      body: GestureDetector(
        onTap: _navigate,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, _) {
              final w = MediaQuery.sizeOf(ctx).width;
              final logoSize = (w * 0.11).clamp(46.0, 72.0);
              final fontSize = (w * 0.12).clamp(50.0, 78.0);
              final gap = (w * 0.018).clamp(6.0, 14.0);
              final maxTextWidth = (fontSize * 3.7).clamp(220.0, 360.0);

              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: _logoFade.value,
                    child: Transform.translate(
                      offset: Offset(_logoSlideX.value, 0),
                      child: AppLogo(size: logoSize, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: maxTextWidth,
                    child: Opacity(
                      opacity: _textFade.value,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: _textReveal.value,
                          child: Transform.translate(
                            offset: Offset(_textSlideX.value, 0),
                            child: Text(
                              'Algeon',
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: fontSize,
                                fontWeight: FontWeight.w900,
                                letterSpacing: fontSize * -0.05,
                                height: 1.22,
                                leadingDistribution: TextLeadingDistribution.even,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
