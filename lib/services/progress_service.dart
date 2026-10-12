/// Сервис прогресса
///
/// Хранит: профиль, прогресс, streak, статистику
/// Локальное хранение через SharedPreferences
library;

import 'bookmark_service.dart';

import 'learning_service.dart';
import 'mock_exam_service.dart';
import 'study_session_service.dart';
import 'exam_progress.dart';
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
  static const String _keyEquippedBetaItem = 'equipped_beta_item';
  static const String _keyProfileBackground = 'profile_background';

  static SharedPreferences? _prefs;
  static Set<String> _solvedTaskIds = {};

  // ============================================================
  // INIT
  // ============================================================

  static DateTime Function() _clock = DateTime.now;
  static Future<void> _pending = Future<void>.value();

  // Keep read/modify/write operations ordered, including rapid submissions.
  static Future<void> _mutate(Future<void> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  static Future<void> init({DateTime Function()? clock}) async {
    await _pending;
    _clock = clock ?? DateTime.now;
    _prefs = await SharedPreferences.getInstance();
    _loadSolvedTasks();
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
    final grade = _prefs?.getInt(_keyGrade) ?? 5;
    return grade.clamp(1, 11);
  }

  static Future<void> setCurrentGrade(int grade) async {
    final normalized = grade.clamp(1, 11);
    await _prefs?.setInt(_keyGrade, normalized);
    _log('Grade: $normalized');
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
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      _log('Invalid custom avatar data: $e');
      return null;
    }
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

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime? _storedDay(String? value) {
    if (value == null) return null;
    // Read both the padded format and dates saved by previous versions.
    final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(value);
    if (match == null) return null;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    final date = DateTime.utc(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }

  static int? _daysSinceStudy() {
    final last = _storedDay(_prefs?.getString(_keyLastActive));
    if (last == null) return null;
    final now = _clock();
    return DateTime.utc(now.year, now.month, now.day).difference(last).inDays;
  }

  static Future<void> _updateStreak() async {
    final difference = _daysSinceStudy();
    if (difference == 0) return;
    final previous = _prefs?.getInt(_keyStreak) ?? 0;
    final streak = difference == 1 ? previous + 1 : 1;
    await _prefs?.setInt(_keyStreak, streak);
    await _prefs?.setString(_keyLastActive, _dateKey(_clock()));
  }

  static int getStreakDays() {
    final difference = _daysSinceStudy();
    if (difference != 0 && difference != 1) return 0;
    return _prefs?.getInt(_keyStreak) ?? 0;
  }

  // ============================================================
  // TASKS
  // ============================================================

  static Future<void> markSolved(String taskId) => _mutate(() async {
    if (taskId.trim().isEmpty) throw ArgumentError.value(taskId, 'taskId');
    _solvedTaskIds.add(taskId);
    await _prefs?.setStringList(_keySolved, _solvedTaskIds.toList());
    await _recordAttempt(true);
    _log('Solved: $taskId (total: ${_solvedTaskIds.length})');
  });

  static Future<void> recordAttempt(bool isCorrect) =>
      _mutate(() => _recordAttempt(isCorrect));

  static Future<void> _recordAttempt(bool isCorrect) async {
    final attempts = (_prefs?.getInt(_keyAttempts) ?? 0) + 1;
    await _prefs?.setInt(_keyAttempts, attempts);
    // A study day is earned by attempting a task, not by opening the site.
    await _updateStreak();
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

  static int getSolvedCountForGrade(
    int grade,
    List<String> allTaskIdsForGrade,
  ) {
    return allTaskIdsForGrade.where((id) => _solvedTaskIds.contains(id)).length;
  }

  // ============================================================
  // TODAY STATS
  // ============================================================

  static int getTodayCompletedCount() {
    final today = _dateKey(_clock());
    final savedDate = _prefs?.getString(_keyTodayDate);

    if (savedDate != today) {
      return 0;
    }

    return _prefs?.getInt(_keyTodayCompleted) ?? 0;
  }

  static Future<void> incrementTodayCompleted() async {
    final today = _dateKey(_clock());
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
    if (attempts <= 0) return 0;
    return ((correct / attempts) * 100).clamp(0, 100);
  }

  static int getTotalAttempts() {
    return _prefs?.getInt(_keyAttempts) ?? 0;
  }

  static int getTotalCorrect() {
    return _prefs?.getInt(_keyCorrect) ?? 0;
  }

  static String? getEquippedBetaItem() {
    return _prefs?.getString(_keyEquippedBetaItem);
  }

  static Future<void> setEquippedBetaItem(String itemId) async {
    await _prefs?.setString(_keyEquippedBetaItem, itemId);
    _log('Equipped beta item: $itemId');
  }

  static String getProfileBackground() {
    return _prefs?.getString(_keyProfileBackground) ?? 'indigo';
  }

  static Future<void> setProfileBackground(String id) async {
    await _prefs?.setString(_keyProfileBackground, id);
    _log('Profile background: $id');
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

  static Future<void> resetProgress() => _mutate(() async {
    _solvedTaskIds.clear();
    await _prefs?.remove(_keySolved);
    await _prefs?.remove(_keyAttempts);
    await _prefs?.remove(_keyCorrect);
    await _prefs?.remove(_keyStreak);
    await _prefs?.remove(_keyLastActive);
    await _prefs?.remove(_keyTodayDate);
    await _prefs?.remove(_keyTodayCompleted);
    await StudySessionService.clear();
    await ExamProgress.clear();
    await LearningService.instance.clear();
    await MockExamService.clear();
    _log('Progress reset');
  });

  static Future<void> resetAll() => _mutate(() async {
    await LearningService.instance.flush();
    await MockExamService.flush();
    await BookmarkService.instance.flush();
    await _prefs?.clear();
    await BookmarkService.instance.init();
    await LearningService.instance.init();
    _solvedTaskIds.clear();
    await StudySessionService.clear();
    _log('Full reset');
  });

  static void _log(String msg) {
    debugPrint('[Progress] $msg');
  }

  static Future<void> flush() => _pending;

  /// Restore only the explicitly allowed preferences, with rollback on failure.
  static Future<void> replacePreferences(
    Map<String, dynamic> data,
    Set<String> keys,
  ) => _mutate(() async {
    final prefs = _prefs;
    if (prefs == null) throw StateError('Progress is not initialized');
    final previous = {for (final key in keys) key: prefs.get(key)};
    Future<void> write(String key, dynamic value) async {
      final bool saved;
      if (value == null) {
        saved = await prefs.remove(key);
      } else if (value is bool) {
        saved = await prefs.setBool(key, value);
      } else if (value is int) {
        saved = await prefs.setInt(key, value);
      } else if (value is String) {
        saved = await prefs.setString(key, value);
      } else if (value is List) {
        saved = await prefs.setStringList(key, value.cast<String>());
      } else {
        throw ArgumentError('Unsupported preference');
      }
      if (!saved) throw StateError('Could not save progress');
    }

    try {
      for (final key in keys) {
        await write(key, data[key]);
      }
    } catch (_) {
      for (final entry in previous.entries) {
        await write(entry.key, entry.value);
      }
      rethrow;
    }
    _loadSolvedTasks();
  });

  // ============================================================
  // CLOUD SNAPSHOT
  // ============================================================

  static const List<String> _cloudKeys = [
    _keyAttempts,
    _keyCorrect,
    _keyLastActive,
    _keyStreak,
    _keyGrade,
    _keyOnboarding,
    _keyUserName,
    _keyAvatar,
    _keyTodayDate,
    _keyTodayCompleted,
    _keyEquippedBetaItem,
    _keyProfileBackground,
    'custom_avatar',
    _keyCustomPhoto,
  ];

  static Map<String, dynamic> exportForCloud() {
    final out = <String, dynamic>{
      _keySolved: _solvedTaskIds.toList(growable: false),
    };
    for (final k in _cloudKeys) {
      final v = _prefs?.get(k);
      if (v != null) out[k] = v;
    }
    return out;
  }

  static Future<void> importFromCloud(Map<String, dynamic> data) async {
    final solvedRaw = data[_keySolved];
    if (solvedRaw is List) {
      final solved = solvedRaw.map((e) => e.toString()).toList(growable: false);
      _solvedTaskIds = solved.toSet();
      await _prefs?.setStringList(_keySolved, solved);
    }

    for (final k in _cloudKeys) {
      final v = data[k];
      if (v == null) continue;
      if (v is bool) {
        await _prefs?.setBool(k, v);
      } else if (v is int) {
        await _prefs?.setInt(k, v);
      } else if (v is double) {
        await _prefs?.setDouble(k, v);
      } else if (v is String) {
        await _prefs?.setString(k, v);
      } else if (v is List) {
        await _prefs?.setStringList(k, v.map((e) => e.toString()).toList());
      }
    }
    _loadSolvedTasks();
  }
}
