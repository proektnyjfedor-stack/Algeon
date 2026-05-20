/// Algeon — математика с пониманием
///
/// Приложение для обучения математике (5–11 класс)
/// Web-only, GoRouter, Provider
///
/// Важно для Web: не вызывать `await` тяжёлых сервисов в `main()` до [runApp].
/// Иначе событие `flutter-first-frame` не наступает и долго висит пустой экран.
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
import 'services/sound_service.dart';
import 'services/language_service.dart';
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
  bool _introDone = false;
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
        SoundService.init(),
        LanguageService.instance.init(),
      ]).timeout(_initTimeout);
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() => _initError =
            'Превышено время ожидания (${_initTimeout.inSeconds} с). $e');
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
                  '${LanguageService.instance.t('main.initFail')}\n\n$_initError\n\n'
                  '${LanguageService.instance.t('main.refreshHint')}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_ready || !_introDone) {
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
        home: BrandSplashScreen(
          ready: _ready,
          onFinished: () {
            if (mounted) setState(() => _introDone = true);
          },
        ),
      );
    }

    return const AlgeonApp();
  }
}

class BrandSplashScreen extends StatefulWidget {
  const BrandSplashScreen({
    super.key,
    required this.ready,
    required this.onFinished,
  });

  final bool ready;
  final VoidCallback onFinished;

  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _zoomController;
  late final Animation<Offset> _floatOffset;
  late final Animation<double> _zoom;
  late final Animation<double> _fade;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _floatOffset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-10, 4),
          end: const Offset(8, -6),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(8, -6),
          end: const Offset(12, 7),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(12, 7),
          end: const Offset(-6, -4),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
    ]).animate(_floatController);
    _zoom = Tween<double>(begin: 1, end: 22).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInExpo),
    );
    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: const Interval(0.55, 1, curve: Curves.easeOut),
      ),
    );
    if (widget.ready) _finish();
  }

  @override
  void didUpdateWidget(covariant BrandSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.ready && widget.ready) _finish();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    _floatController.stop();
    await _zoomController.forward();
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatController, _zoomController]),
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Transform.translate(
                offset: _zoomController.isAnimating
                    ? Offset.zero
                    : _floatOffset.value,
                child: Transform.scale(
                  scale: _zoom.value,
                  child: child,
                ),
              ),
            );
          },
          child: const AppLogo(size: 186),
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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageService>.value(
            value: LanguageService.instance,
          ),
        ],
        child: Consumer2<ThemeProvider, LanguageService>(
            builder: (context, themeProvider, languageService, _) {
          final isDark = themeProvider.themeMode == ThemeMode.dark ||
              (themeProvider.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp.router(
            title: 'Algeon',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const _NoGlowScrollBehavior(),
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            locale: Locale(languageService.isEnglish ? 'en' : 'ru'),
            routerConfig: appRouter,
          );
        }),
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
