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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'router/app_router.dart';
import 'services/progress_service.dart';
import 'services/achievements_service.dart';
import 'services/reward_drop_service.dart';
import 'services/sound_service.dart';

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
      await Future.wait([
        ProgressService.init(),
        AchievementsService.init(),
        RewardDropService.init(),
        SoundService.init(),
      ]).timeout(_initTimeout);
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
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Algeon',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    color: Color(0xFF2563EB),
                  ),
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const AlgeonApp();
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
