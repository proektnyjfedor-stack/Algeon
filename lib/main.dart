/// MathPilot — Математический тренажёр
/// 
/// Запуск: flutter run -d chrome

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  await AuthService.init();
  await ProgressService.init();
  
  runApp(const MathPilotApp());
}

class MathPilotApp extends StatelessWidget {
  const MathPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthService.isLoggedIn 
          ? const MainScreen() 
          : const LoginScreen(),
    );
  }
}
