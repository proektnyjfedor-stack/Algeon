/// Achievements Service — достижения и бейджи
///
/// Система наград за прогресс

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Тип достижения
enum AchievementType {
  // Количество решённых задач
  tasksSolved10,
  tasksSolved50,
  tasksSolved100,
  tasksSolved200,

  // Streak
  streak3,
  streak7,
  streak14,
  streak30,

  // Точность
  accuracy80,
  accuracy90,
  accuracy100,

  // Классы
  grade1Complete,
  grade2Complete,
  grade3Complete,
  grade4Complete,

  // Специальные
  firstTask,
  perfectSession,
}

/// Модель достижения
class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final int target;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  String get key => 'achievement_${type.name}';
}

class AchievementsService {
  static SharedPreferences? _prefs;
  static final List<Achievement> _achievements = [];
  
  /// Инициализация
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initAchievements();
    _loadUnlocked();
    _log('Initialized with ${_achievements.length} achievements');
  }
  
  /// Создание списка достижений
  static void _initAchievements() {
    _achievements.clear();
    _achievements.addAll([
      // Задачи
      Achievement(
        type: AchievementType.firstTask,
        title: 'Первые шаги',
        description: 'Реши первую задачу',
        icon: Icons.flag_rounded,
        target: 1,
      ),
      Achievement(
        type: AchievementType.tasksSolved10,
        title: 'Начинающий',
        description: 'Реши 10 задач',
        icon: Icons.star_outline_rounded,
        target: 10,
      ),
      Achievement(
        type: AchievementType.tasksSolved50,
        title: 'Практик',
        description: 'Реши 50 задач',
        icon: Icons.star_rounded,
        target: 50,
      ),
      Achievement(
        type: AchievementType.tasksSolved100,
        title: 'Мастер',
        description: 'Реши 100 задач',
        icon: Icons.star_half_rounded,
        target: 100,
      ),
      Achievement(
        type: AchievementType.tasksSolved200,
        title: 'Эксперт',
        description: 'Реши 200 задач',
        icon: Icons.emoji_events_rounded,
        target: 200,
      ),

      // Streak
      Achievement(
        type: AchievementType.streak3,
        title: 'На волне',
        description: '3 дня подряд',
        icon: Icons.local_fire_department_rounded,
        target: 3,
      ),
      Achievement(
        type: AchievementType.streak7,
        title: 'Неделя силы',
        description: '7 дней подряд',
        icon: Icons.fitness_center_rounded,
        target: 7,
      ),
      Achievement(
        type: AchievementType.streak14,
        title: 'Двухнедельник',
        description: '14 дней подряд',
        icon: Icons.rocket_launch_rounded,
        target: 14,
      ),
      Achievement(
        type: AchievementType.streak30,
        title: 'Месяц упорства',
        description: '30 дней подряд',
        icon: Icons.workspace_premium_rounded,
        target: 30,
      ),

      // Точность
      Achievement(
        type: AchievementType.accuracy80,
        title: 'Меткий глаз',
        description: '80% точность',
        icon: Icons.gps_fixed_rounded,
        target: 80,
      ),
      Achievement(
        type: AchievementType.accuracy90,
        title: 'Снайпер',
        description: '90% точность',
        icon: Icons.track_changes_rounded,
        target: 90,
      ),
      Achievement(
        type: AchievementType.accuracy100,
        title: 'Безупречность',
        description: '100% точность (мин. 20 задач)',
        icon: Icons.diamond_rounded,
        target: 100,
      ),

      // Классы
      Achievement(
        type: AchievementType.grade1Complete,
        title: 'Первоклассник',
        description: 'Заверши 1 класс',
        icon: Icons.looks_one_rounded,
        target: 1,
      ),
      Achievement(
        type: AchievementType.grade2Complete,
        title: 'Второклассник',
        description: 'Заверши 2 класс',
        icon: Icons.looks_two_rounded,
        target: 2,
      ),
      Achievement(
        type: AchievementType.grade3Complete,
        title: 'Третьеклассник',
        description: 'Заверши 3 класс',
        icon: Icons.looks_3_rounded,
        target: 3,
      ),
      Achievement(
        type: AchievementType.grade4Complete,
        title: 'Четвероклассник',
        description: 'Заверши 4 класс',
        icon: Icons.looks_4_rounded,
        target: 4,
      ),

      // Специальные
      Achievement(
        type: AchievementType.perfectSession,
        title: 'Без единой ошибки',
        description: 'Заверши сессию на 100%',
        icon: Icons.auto_awesome_rounded,
        target: 1,
      ),
    ]);
  }
  
  /// Загрузка разблокированных
  static void _loadUnlocked() {
    for (final a in _achievements) {
      final timestamp = _prefs?.getInt(a.key);
      if (timestamp != null) {
        a.isUnlocked = true;
        a.unlockedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }
  }
  
  /// Получить все достижения
  static List<Achievement> getAll() {
    return List.unmodifiable(_achievements);
  }
  
  /// Получить разблокированные
  static List<Achievement> getUnlocked() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }
  
  /// Получить заблокированные
  static List<Achievement> getLocked() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }
  
  /// Количество разблокированных
  static int getUnlockedCount() {
    return _achievements.where((a) => a.isUnlocked).length;
  }
  
  /// Всего достижений
  static int getTotalCount() {
    return _achievements.length;
  }
  
  /// Прогресс (0.0 - 1.0)
  static double getProgress() {
    return getUnlockedCount() / getTotalCount();
  }
  
  /// Разблокировать достижение
  static Future<Achievement?> unlock(AchievementType type) async {
    final achievement = _achievements.firstWhere(
      (a) => a.type == type,
      orElse: () => throw Exception('Achievement not found: $type'),
    );
    
    if (achievement.isUnlocked) return null;
    
    achievement.isUnlocked = true;
    achievement.unlockedAt = DateTime.now();
    
    await _prefs?.setInt(
      achievement.key, 
      achievement.unlockedAt!.millisecondsSinceEpoch,
    );
    
    _log('Unlocked: ${achievement.title}');
    return achievement;
  }
  
  /// Проверить и разблокировать достижения по задачам
  static Future<List<Achievement>> checkTaskAchievements(int totalSolved) async {
    final unlocked = <Achievement>[];
    
    if (totalSolved >= 1) {
      final a = await unlock(AchievementType.firstTask);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 10) {
      final a = await unlock(AchievementType.tasksSolved10);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 50) {
      final a = await unlock(AchievementType.tasksSolved50);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 100) {
      final a = await unlock(AchievementType.tasksSolved100);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 200) {
      final a = await unlock(AchievementType.tasksSolved200);
      if (a != null) unlocked.add(a);
    }
    
    return unlocked;
  }
  
  /// Проверить и разблокировать достижения по streak
  static Future<List<Achievement>> checkStreakAchievements(int streak) async {
    final unlocked = <Achievement>[];
    
    if (streak >= 3) {
      final a = await unlock(AchievementType.streak3);
      if (a != null) unlocked.add(a);
    }
    if (streak >= 7) {
      final a = await unlock(AchievementType.streak7);
      if (a != null) unlocked.add(a);
    }
    if (streak >= 14) {
      final a = await unlock(AchievementType.streak14);
      if (a != null) unlocked.add(a);
    }
    if (streak >= 30) {
      final a = await unlock(AchievementType.streak30);
      if (a != null) unlocked.add(a);
    }
    
    return unlocked;
  }
  
  /// Проверить точность
  static Future<List<Achievement>> checkAccuracyAchievements(
    double accuracy, 
    int totalAttempts,
  ) async {
    final unlocked = <Achievement>[];
    
    // Минимум 20 попыток для достижений точности
    if (totalAttempts < 20) return unlocked;
    
    if (accuracy >= 80) {
      final a = await unlock(AchievementType.accuracy80);
      if (a != null) unlocked.add(a);
    }
    if (accuracy >= 90) {
      final a = await unlock(AchievementType.accuracy90);
      if (a != null) unlocked.add(a);
    }
    if (accuracy >= 100) {
      final a = await unlock(AchievementType.accuracy100);
      if (a != null) unlocked.add(a);
    }
    
    return unlocked;
  }
  
  /// Проверить завершение класса
  static Future<Achievement?> checkGradeComplete(int grade, double progress) async {
    if (progress < 1.0) return null;
    
    switch (grade) {
      case 1:
        return unlock(AchievementType.grade1Complete);
      case 2:
        return unlock(AchievementType.grade2Complete);
      case 3:
        return unlock(AchievementType.grade3Complete);
      case 4:
        return unlock(AchievementType.grade4Complete);
      default:
        return null;
    }
  }
  
  /// Проверить идеальную сессию
  static Future<Achievement?> checkPerfectSession(int correct, int total) async {
    if (correct == total && total >= 5) {
      return unlock(AchievementType.perfectSession);
    }
    return null;
  }
  
  /// Сброс достижений
  static Future<void> reset() async {
    for (final a in _achievements) {
      a.isUnlocked = false;
      a.unlockedAt = null;
      await _prefs?.remove(a.key);
    }
    _log('Reset all achievements');
  }
  
  static void _log(String msg) {
    // ignore: avoid_print
    print('[Achievements] $msg');
  }
}
