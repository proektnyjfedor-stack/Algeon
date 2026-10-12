/// Theme Provider — управление светлой/тёмной темой
///
/// Сохраняет выбор пользователя в SharedPreferences
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accent_palette.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeProvider() {
    _loadThemeMode();
    WidgetsBinding.instance.addObserver(this);
  }
  bool _disposed = false;
  Color _accentColor = AccentPalette.defaultColor;
  Color get accentColor => _accentColor;
  Future<void> setAccentColor(Color color) async {
    final opaque = color.withAlpha(255);
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setInt('accent_color', opaque.toARGB32())) {
      throw StateError('Не удалось сохранить цвет');
    }
    if (_disposed) return;
    _accentColor = opaque;
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) notifyListeners();
  }

  static const String _keyThemeMode = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  bool get followSystem => _themeMode == ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeMode get manualThemeMode =>
      _themeMode == ThemeMode.system ? ThemeMode.light : _themeMode;

  Future<void> reload() => _loadThemeMode();

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode);
    final accent = prefs.get('accent_color');
    _accentColor = accent is int && accent >= 0xFF000000 && accent <= 0xFFFFFFFF
        ? Color(accent)
        : AccentPalette.defaultColor;
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
    if (!_disposed) notifyListeners();
  }

  Future<void> setFollowSystem(bool enabled) async {
    if (enabled) {
      await setThemeMode(ThemeMode.system);
    } else {
      await setThemeMode(
        _platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
      );
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
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
