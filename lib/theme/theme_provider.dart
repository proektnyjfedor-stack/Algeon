/// Theme Provider — управление светлой/тёмной темой
///
/// Сохраняет выбор пользователя в SharedPreferences

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAutoByTime = 'theme_auto_by_time';

  ThemeMode _manualThemeMode = ThemeMode.light;
  bool _autoByTime = true;
  Timer? _themeTick;

  bool get autoByTime => _autoByTime;
  ThemeMode get manualThemeMode => _manualThemeMode;

  ThemeMode get themeMode =>
      _autoByTime ? _themeModeByCurrentTime() : _manualThemeMode;

  ThemeProvider() {
    _loadThemeMode();
    _startThemeTicker();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode);
    _autoByTime = prefs.getBool(_keyAutoByTime) ?? true;
    switch (value) {
      case 'light':
        _manualThemeMode = ThemeMode.light;
        break;
      case 'dark':
        _manualThemeMode = ThemeMode.dark;
        break;
      default:
        _manualThemeMode = ThemeMode.light;
        break;
    }
    notifyListeners();
  }

  ThemeMode _themeModeByCurrentTime() {
    final hour = DateTime.now().hour;
    final isNight = hour >= 20 || hour < 7;
    return isNight ? ThemeMode.dark : ThemeMode.light;
  }

  void _startThemeTicker() {
    _themeTick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_autoByTime) {
        notifyListeners();
      }
    });
  }

  Future<void> setAutoByTime(bool enabled) async {
    _autoByTime = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoByTime, enabled);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _manualThemeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> toggleTheme() async {
    if (_manualThemeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  @override
  void dispose() {
    _themeTick?.cancel();
    super.dispose();
  }
}
