/// Sound Service — звуки приложения (упрощённая версия)
/// 
/// Использует системные звуки Flutter

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SoundService {
  static SharedPreferences? _prefs;
  
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  
  /// Инициализация
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Звуки включены?
  static bool isSoundEnabled() {
    return _prefs?.getBool(_keySoundEnabled) ?? true;
  }
  
  /// Включить/выключить звуки
  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySoundEnabled, enabled);
  }
  
  /// Вибрация включена?
  static bool isVibrationEnabled() {
    return _prefs?.getBool(_keyVibrationEnabled) ?? true;
  }
  
  /// Включить/выключить вибрацию
  static Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs?.setBool(_keyVibrationEnabled, enabled);
  }
  
  /// Правильный ответ ✅
  static Future<void> playCorrect() async {
    if (!isSoundEnabled()) return;
    await SystemSound.play(SystemSoundType.click);
    await _vibrate();
  }
  
  /// Неправильный ответ ❌
  static Future<void> playWrong() async {
    if (!isSoundEnabled()) return;
    await SystemSound.play(SystemSoundType.alert);
    await _vibrate(heavy: true);
  }
  
  /// Streak 🔥
  static Future<void> playStreak() async {
    if (!isSoundEnabled()) return;
    await SystemSound.play(SystemSoundType.click);
    await _vibrate();
  }
  
  /// Достижение 🏆
  static Future<void> playAchievement() async {
    if (!isSoundEnabled()) return;
    await SystemSound.play(SystemSoundType.click);
    await _vibrate();
  }
  
  /// Тема завершена 🎉
  static Future<void> playComplete() async {
    if (!isSoundEnabled()) return;
    await SystemSound.play(SystemSoundType.click);
    await _vibrate();
  }
  
  /// Вибрация
  static Future<void> _vibrate({bool heavy = false}) async {
    if (!isVibrationEnabled()) return;
    
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
  
  /// Публичный метод для haptic feedback (лёгкий)
  static Future<void> hapticLight() async {
    if (!isVibrationEnabled()) return;
    HapticFeedback.lightImpact();
  }
  
  /// Публичный метод для haptic feedback (сильный)
  static Future<void> hapticHeavy() async {
    if (!isVibrationEnabled()) return;
    HapticFeedback.heavyImpact();
  }
}
