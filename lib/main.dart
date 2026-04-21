/// Algeon — математика с пониманием
///
/// Приложение для обучения математике (5–11 класс)
/// Web-only, GoRouter, Provider
///
/// Важно для Web: не вызывать `await` тяжёлых сервисов в `main()` до [runApp].
/// Иначе событие `flutter-first-frame` не наступает и в index.html вечно видна
/// только HTML-заставка «Algeon».
library;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/progress_service.dart';
import 'services/achievements_service.dart';
import 'services/sound_service.dart';
import 'widgets/app_logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const AlgeonBootstrap());
}

/// Первый кадр — сразу после [runApp], чтобы снять HTML-лоадер в index.html.
class AlgeonBootstrap extends StatefulWidget {
  const AlgeonBootstrap({super.key});

  @override
  State<AlgeonBootstrap> createState() => _AlgeonBootstrapState();
}

class _AlgeonBootstrapState extends State<AlgeonBootstrap> {
  bool _ready = false;
  Object? _initError;

  static const Duration _initTimeout = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _warmUp();
  }

  Future<void> _warmUp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await Future.wait([
        AuthService.init(),
        ProgressService.init(),
        AchievementsService.init(),
        SoundService.init(),
      ]).timeout(_initTimeout);
      await CloudSyncService.initAndBind();
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() => _initError = 'Превышено время ожидания (${_initTimeout.inSeconds} с). $e');
      }
      return;
    } catch (e, st) {
      debugPrint('AlgeonBootstrap._warmUp: $e\n$st');
      if (mounted) setState(() => _initError = e);
      return;
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: const _NoGlowScrollBehavior(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  'Не удалось запустить Algeon.\n\n$_initError\n\n'
                  'Попробуйте обновить страницу (жёсткое обновление: '
                  'Ctrl+Shift+R или Cmd+Shift+R) или режим инкогнито.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: const _NoGlowScrollBehavior(),
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF0F4FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF111111),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const Scaffold(body: _BootstrapSplash()),
      );
    }

    return const AlgeonApp();
  }
}

class _BootstrapSplash extends StatefulWidget {
  const _BootstrapSplash();

  @override
  State<_BootstrapSplash> createState() => _BootstrapSplashState();
}

class _BootstrapSplashState extends State<_BootstrapSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          );
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoIcon(size: 88),
            SizedBox(height: 16),
            Text(
              'Algeon',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.9,
                color: Color(0xFF2563EB),
              ),
            ),
            SizedBox(height: 22),
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2.8),
            ),
          ],
        ),
      ),
    );
  }
}

class AlgeonApp extends StatelessWidget {
  const AlgeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDark = themeProvider.themeMode == ThemeMode.dark ||
              (themeProvider.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp.router(
            title: 'Algeon',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const _NoGlowScrollBehavior(),
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

/// Единое поведение скролла для web/mobile: без glow/stretch-индикатора.
class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
