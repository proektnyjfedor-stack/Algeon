/// Algeon — математика с пониманием
///
/// Приложение для обучения математике 1-4 класс
/// Web-only, GoRouter, Provider

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'router/app_router.dart';
import 'services/progress_service.dart';
import 'services/achievements_service.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Прозрачная статус-бар и навигационная панель
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Инициализация сервисов
  await ProgressService.init();
  await AchievementsService.init();
  await SoundService.init();

  // Обработка ошибок Flutter
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  runApp(const AlgeonApp());
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

          // Настройка системного UI — всегда прозрачный
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
