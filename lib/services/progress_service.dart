/// Сервис прогресса — хранит решённые задачи, аватарку, уровень

import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keySolved = 'solved_tasks';
  static const String _keyAvatar = 'user_avatar';
  static const String _keyLastActive = 'last_active_date';
  static const String _keyStreak = 'streak_days';
  
  static SharedPreferences? _prefs;
  static Set<String> _solvedTaskIds = {};
  
  /// Инициализация
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSolvedTasks();
    _updateStreak();
    _log('ProgressService инициализирован');
  }
  
  /// Загрузка решённых задач
  static void _loadSolvedTasks() {
    final data = _prefs?.getStringList(_keySolved) ?? [];
    _solvedTaskIds = data.toSet();
    _log('Загружено ${_solvedTaskIds.length} решённых задач');
  }
  
  /// Обновление streak (дней подряд)
  static void _updateStreak() {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final lastActive = _prefs?.getString(_keyLastActive);
    
    if (lastActive == null) {
      // Первый запуск
      _prefs?.setString(_keyLastActive, today);
      _prefs?.setInt(_keyStreak, 1);
      return;
    }
    
    if (lastActive == today) {
      // Уже заходил сегодня
      return;
    }
    
    // Проверяем, был ли вчера
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    
    if (lastActive == yesterdayStr) {
      // Был вчера — увеличиваем streak
      final streak = (_prefs?.getInt(_keyStreak) ?? 0) + 1;
      _prefs?.setInt(_keyStreak, streak);
    } else {
      // Пропустил дни — сбрасываем
      _prefs?.setInt(_keyStreak, 1);
    }
    
    _prefs?.setString(_keyLastActive, today);
  }
  
  /// Отметить задачу как решённую
  static Future<void> markSolved(String taskId) async {
    _solvedTaskIds.add(taskId);
    await _prefs?.setStringList(_keySolved, _solvedTaskIds.toList());
    _log('Задача $taskId решена. Всего: ${_solvedTaskIds.length}');
  }
  
  /// Проверить, решена ли задача
  static bool isSolved(String taskId) {
    return _solvedTaskIds.contains(taskId);
  }
  
  /// Получить все решённые задачи
  static Set<String> getSolvedTaskIds() {
    return _solvedTaskIds;
  }
  
  /// Получить кол-во решённых задач для темы
  static int getSolvedCountForTopic(String topic, List<String> taskIds) {
    return taskIds.where((id) => _solvedTaskIds.contains(id)).length;
  }
  
  /// Аватарка
  static String? getAvatar() {
    return _prefs?.getString(_keyAvatar);
  }
  
  static Future<void> setAvatar(String avatar) async {
    await _prefs?.setString(_keyAvatar, avatar);
    _log('Аватарка установлена: $avatar');
  }
  
  /// Streak (дней подряд)
  static int getStreak() {
    return _prefs?.getInt(_keyStreak) ?? 0;
  }
  
  /// Уровень (зависит от кол-ва решённых задач)
  static int getLevel() {
    final solved = _solvedTaskIds.length;
    if (solved >= 50) return 5;
    if (solved >= 30) return 4;
    if (solved >= 15) return 3;
    if (solved >= 5) return 2;
    return 1;
  }
  
  /// Сброс всего прогресса
  static Future<void> resetAll() async {
    _solvedTaskIds.clear();
    await _prefs?.remove(_keySolved);
    await _prefs?.remove(_keyStreak);
    await _prefs?.remove(_keyLastActive);
    _log('Прогресс сброшен');
  }
  
  static void _log(String message) {
    // ignore: avoid_print
    print('[ProgressService] $message');
  }
}
