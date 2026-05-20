/// Theme Provider — управление светлой/тёмной темой
///
/// Сохраняет выбор пользователя в SharedPreferences
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadThemeMode();
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      if (_themeMode == ThemeMode.system) {
        notifyListeners();
      }
    };
  }
  static const String _keyThemeMode = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  bool get followSystem => _themeMode == ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeMode get manualThemeMode =>
      _themeMode == ThemeMode.system ? ThemeMode.light : _themeMode;

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode);
    switch (value) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      default:
        // Старые версии сохраняли авто-тему по времени. Новый дефолт — тема
        // системы, чтобы сайт совпадал с настройкой телефона/браузера.
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<void> setFollowSystem(bool enabled) async {
    if (enabled) {
      await setThemeMode(ThemeMode.system);
    } else {
      await setThemeMode(_platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> toggleTheme() async {
    final current = _themeMode == ThemeMode.system
        ? (_platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light)
        : _themeMode;
    if (current == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Brightness get _platformBrightness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void dispose() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        null;
    super.dispose();
  }
}
