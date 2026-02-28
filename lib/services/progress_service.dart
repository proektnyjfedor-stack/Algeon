/// Сервис прогресса
/// 
/// Хранит: профиль, прогресс, streak, статистику
/// Локальное хранение через SharedPreferences

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  // Keys
  static const String _keySolved = 'solved_tasks';
  static const String _keyAttempts = 'total_attempts';
  static const String _keyCorrect = 'correct_attempts';
  static const String _keyLastActive = 'last_active_date';
  static const String _keyStreak = 'streak_days';
  static const String _keyGrade = 'current_grade';
  static const String _keyOnboarding = 'onboarding_complete';
  static const String _keyUserName = 'user_name';
  static const String _keyAvatar = 'user_avatar';
  static const String _keyTodayDate = 'today_date';
  static const String _keyTodayCompleted = 'today_completed';
  
  static SharedPreferences? _prefs;
  static Set<String> _solvedTaskIds = {};
  
  // ============================================================
  // INIT
  // ============================================================
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSolvedTasks();
    await _updateStreak();
    _log('Initialized');
  }
  
  static void _loadSolvedTasks() {
    final data = _prefs?.getStringList(_keySolved) ?? [];
    _solvedTaskIds = data.toSet();
    _log('Loaded ${_solvedTaskIds.length} solved');
  }
  
  // ============================================================
  // ONBOARDING & GRADE
  // ============================================================
  
  static bool isOnboardingComplete() {
    return _prefs?.getBool(_keyOnboarding) ?? false;
  }
  
  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_keyOnboarding, value);
    _log('Onboarding: $value');
  }
  
  static int getCurrentGrade() {
    return _prefs?.getInt(_keyGrade) ?? 1;
  }
  
  static Future<void> setCurrentGrade(int grade) async {
    await _prefs?.setInt(_keyGrade, grade);
    _log('Grade: $grade');
  }
  
  // ============================================================
  // PROFILE
  // ============================================================
  
  static String getUserName() {
    return _prefs?.getString(_keyUserName) ?? 'Ученик';
  }
  
  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_keyUserName, name);
    _log('Name: $name');
  }
  
  static String getAvatar() {
    return _prefs?.getString(_keyAvatar) ?? 'boy_blue';
  }
  
  static Future<void> setAvatar(String emoji) async {
    await _prefs?.setString(_keyAvatar, emoji);
    _log('Avatar: $emoji');
  }

  /// Сохранить кастомный аватар
  static Future<void> setCustomAvatar(Map<String, dynamic> data) async {
    await _prefs?.setString('custom_avatar', jsonEncode(data));
    await _prefs?.setString(_keyAvatar, 'custom');
    _log('Custom avatar saved');
  }

  /// Загрузить кастомный аватар
  static Map<String, dynamic>? getCustomAvatar() {
    final str = _prefs?.getString('custom_avatar');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ============================================================
  // ФОТО ИЗ ГАЛЕРЕИ
  // ============================================================

  static const String _keyCustomPhoto = 'custom_photo_b64';

  /// Сохранить фото профиля (base64)
  static Future<void> setCustomPhoto(String base64Data) async {
    await _prefs?.setString(_keyCustomPhoto, base64Data);
    await _prefs?.setString(_keyAvatar, 'photo');
    _log('Custom photo saved');
  }

  /// Получить фото профиля (base64) или null
  static String? getCustomPhoto() {
    return _prefs?.getString(_keyCustomPhoto);
  }
  
  // ============================================================
  // STREAK
  // ============================================================
  
  static Future<void> _updateStreak() async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final lastActive = _prefs?.getString(_keyLastActive);

    if (lastActive == null) {
      await _prefs?.setString(_keyLastActive, today);
      await _prefs?.setInt(_keyStreak, 1);
      return;
    }

    if (lastActive == today) return;

    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    if (lastActive == yesterdayStr) {
      final streak = (_prefs?.getInt(_keyStreak) ?? 0) + 1;
      await _prefs?.setInt(_keyStreak, streak);
    } else {
      await _prefs?.setInt(_keyStreak, 1);
    }

    await _prefs?.setString(_keyLastActive, today);
  }
  
  static int getStreakDays() {
    return _prefs?.getInt(_keyStreak) ?? 0;
  }
  
  // ============================================================
  // TASKS
  // ============================================================
  
  static Future<void> markSolved(String taskId) async {
    _solvedTaskIds.add(taskId);
    await _prefs?.setStringList(_keySolved, _solvedTaskIds.toList());
    
    final attempts = (_prefs?.getInt(_keyAttempts) ?? 0) + 1;
    final correct = (_prefs?.getInt(_keyCorrect) ?? 0) + 1;
    await _prefs?.setInt(_keyAttempts, attempts);
    await _prefs?.setInt(_keyCorrect, correct);
    
    await incrementTodayCompleted();
    
    _log('Solved: $taskId (total: ${_solvedTaskIds.length})');
  }
  
  static Future<void> recordAttempt(bool isCorrect) async {
    final attempts = (_prefs?.getInt(_keyAttempts) ?? 0) + 1;
    await _prefs?.setInt(_keyAttempts, attempts);
    
    if (isCorrect) {
      final correct = (_prefs?.getInt(_keyCorrect) ?? 0) + 1;
      await _prefs?.setInt(_keyCorrect, correct);
      await incrementTodayCompleted();
    }
  }
  
  static bool isSolved(String taskId) {
    return _solvedTaskIds.contains(taskId);
  }
  
  static Set<String> getSolvedTaskIds() {
    return Set.from(_solvedTaskIds);
  }
  
  static int getTotalSolved() {
    return _solvedTaskIds.length;
  }
  
  static int getSolvedCountForTopic(String topic, List<String> taskIds) {
    return taskIds.where((id) => _solvedTaskIds.contains(id)).length;
  }
  
  static int getSolvedCountForGrade(int grade, List<String> allTaskIdsForGrade) {
    return allTaskIdsForGrade.where((id) => _solvedTaskIds.contains(id)).length;
  }
  
  // ============================================================
  // TODAY STATS
  // ============================================================
  
  static int getTodayCompletedCount() {
    final today = DateTime.now().toString().substring(0, 10);
    final savedDate = _prefs?.getString(_keyTodayDate);
    
    if (savedDate != today) {
      return 0;
    }
    
    return _prefs?.getInt(_keyTodayCompleted) ?? 0;
  }
  
  static Future<void> incrementTodayCompleted() async {
    final today = DateTime.now().toString().substring(0, 10);
    final savedDate = _prefs?.getString(_keyTodayDate);
    
    if (savedDate != today) {
      await _prefs?.setString(_keyTodayDate, today);
      await _prefs?.setInt(_keyTodayCompleted, 1);
    } else {
      final current = _prefs?.getInt(_keyTodayCompleted) ?? 0;
      await _prefs?.setInt(_keyTodayCompleted, current + 1);
    }
  }
  
  // ============================================================
  // STATS
  // ============================================================
  
  static double getAccuracy() {
    final attempts = _prefs?.getInt(_keyAttempts) ?? 0;
    final correct = _prefs?.getInt(_keyCorrect) ?? 0;
    if (attempts == 0) return 0;
    return (correct / attempts) * 100;
  }
  
  static int getTotalAttempts() {
    return _prefs?.getInt(_keyAttempts) ?? 0;
  }
  
  static int getTotalCorrect() {
    return _prefs?.getInt(_keyCorrect) ?? 0;
  }

  /// Generic bool getter (for exam pass flags etc.)
  static bool getBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }

  /// Generic bool setter
  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static int getLevel() {
    final solved = _solvedTaskIds.length;
    if (solved >= 150) return 10;
    if (solved >= 120) return 9;
    if (solved >= 100) return 8;
    if (solved >= 80) return 7;
    if (solved >= 60) return 6;
    if (solved >= 40) return 5;
    if (solved >= 25) return 4;
    if (solved >= 15) return 3;
    if (solved >= 5) return 2;
    return 1;
  }
  
  // ============================================================
  // RESET
  // ============================================================
  
  static Future<void> resetProgress() async {
    _solvedTaskIds.clear();
    await _prefs?.remove(_keySolved);
    await _prefs?.remove(_keyAttempts);
    await _prefs?.remove(_keyCorrect);
    await _prefs?.remove(_keyStreak);
    await _prefs?.remove(_keyLastActive);
    _log('Progress reset');
  }
  
  static Future<void> resetAll() async {
    await _prefs?.clear();
    _solvedTaskIds.clear();
    _log('Full reset');
  }
  
  static void _log(String msg) {
    debugPrint('[Progress] $msg');
  }
}
