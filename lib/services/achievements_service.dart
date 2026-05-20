/// Achievements Service — достижения и бейджи
///
/// Система наград за прогресс
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Тип достижения
enum AchievementType {
  // Количество решённых задач
  tasksSolved10,
  tasksSolved25,
  tasksSolved50,
  tasksSolved75,
  tasksSolved100,
  tasksSolved150,
  tasksSolved200,
  tasksSolved300,

  // Streak
  streak3,
  streak7,
  streak14,
  streak30,

  // Точность
  accuracy80,
  accuracy90,
  accuracy100,

  // Специальные
  firstTask,
  perfectSession,
}

/// Модель достижения
class Achievement {

  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    this.isUnlocked = false,
    this.unlockedAt,
  });
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final int target;
  bool isUnlocked;
  DateTime? unlockedAt;

  String get key => 'achievement_${type.name}';
}

class AchievementsService {
  static SharedPreferences? _prefs;
  static final List<Achievement> _achievements = [];
  static const List<String> _baseAvatarSkins = <String>[
    'boy_blue',
    'girl_pink',
    'boy_green',
    'girl_purple',
  ];
  static const Map<AchievementType, String> _achievementAvatarSkins =
      <AchievementType, String>{
    AchievementType.firstTask: 'boy_orange',
    AchievementType.tasksSolved10: 'girl_red',
    AchievementType.streak3: 'boy_dark',
    AchievementType.accuracy80: 'girl_teal',
    AchievementType.tasksSolved50: 'robot',
    AchievementType.tasksSolved150: 'girl_purple',
    AchievementType.tasksSolved300: 'boy_green',
    AchievementType.perfectSession: 'cat',
  };
  
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
        description:
            'Заверши любую 1 задачу: выбери тему, открой задание и дай правильный ответ.',
        icon: Icons.flag_rounded,
        target: 1,
      ),
      Achievement(
        type: AchievementType.tasksSolved10,
        title: 'Начинающий',
        description:
            'Реши суммарно 10 задач с правильным ответом (в любых темах и классах).',
        icon: Icons.star_outline_rounded,
        target: 10,
      ),
      Achievement(
        type: AchievementType.tasksSolved25,
        title: 'Разогрев',
        description:
            'Реши 25 задач с правильным ответом. Учитывается общий прогресс по аккаунту.',
        icon: Icons.bolt_rounded,
        target: 25,
      ),
      Achievement(
        type: AchievementType.tasksSolved50,
        title: 'Практик',
        description:
            'Достигни 50 правильно решённых задач в сумме по всем занятиям.',
        icon: Icons.star_rounded,
        target: 50,
      ),
      Achievement(
        type: AchievementType.tasksSolved75,
        title: 'Темп набран',
        description:
            'Реши 75 задач правильно. Пропуски и ошибки прогресс не уменьшают.',
        icon: Icons.trending_up_rounded,
        target: 75,
      ),
      Achievement(
        type: AchievementType.tasksSolved100,
        title: 'Мастер',
        description:
            'Реши 100 задач с правильным ответом. Можно в разных классах и темах.',
        icon: Icons.star_half_rounded,
        target: 100,
      ),
      Achievement(
        type: AchievementType.tasksSolved150,
        title: 'Турбо-режим',
        description:
            'Суммарно реши 150 задач правильно. Зачитываются все предыдущие решения.',
        icon: Icons.rocket_launch_rounded,
        target: 150,
      ),
      Achievement(
        type: AchievementType.tasksSolved200,
        title: 'Эксперт',
        description:
            'Дойди до 200 правильно решённых задач. Это долгосрочная награда.',
        icon: Icons.emoji_events_rounded,
        target: 200,
      ),
      Achievement(
        type: AchievementType.tasksSolved300,
        title: 'Легенда практики',
        description:
            'Реши 300 задач правильно. Максимальная награда по количеству решений.',
        icon: Icons.workspace_premium_rounded,
        target: 300,
      ),

      // Streak
      Achievement(
        type: AchievementType.streak3,
        title: 'На волне',
        description:
            'Решай задачи 3 дня подряд без пропуска дня. Нужна ежедневная активность.',
        icon: Icons.local_fire_department_rounded,
        target: 3,
      ),
      Achievement(
        type: AchievementType.streak7,
        title: 'Неделя силы',
        description:
            'Поддерживай серию 7 дней подряд: каждый день решай хотя бы одну задачу.',
        icon: Icons.fitness_center_rounded,
        target: 7,
      ),
      Achievement(
        type: AchievementType.streak14,
        title: 'Двухнедельник',
        description:
            'Не прерывай серию 14 дней подряд. Пропуск дня сбрасывает цепочку.',
        icon: Icons.rocket_launch_rounded,
        target: 14,
      ),
      Achievement(
        type: AchievementType.streak30,
        title: 'Месяц упорства',
        description:
            'Решай задачи 30 дней подряд. Это награда за устойчивую дисциплину.',
        icon: Icons.workspace_premium_rounded,
        target: 30,
      ),

      // Точность
      Achievement(
        type: AchievementType.accuracy80,
        title: 'Меткий глаз',
        description:
            'Держи точность 80% или выше. Учитывается только после минимум 20 попыток.',
        icon: Icons.gps_fixed_rounded,
        target: 80,
      ),
      Achievement(
        type: AchievementType.accuracy90,
        title: 'Снайпер',
        description:
            'Достигни точности 90% или выше при минимум 20 попытках.',
        icon: Icons.track_changes_rounded,
        target: 90,
      ),
      Achievement(
        type: AchievementType.accuracy100,
        title: 'Безупречность',
        description:
            'Покажи 100% точность при минимум 20 попытках (без ошибок).',
        icon: Icons.diamond_rounded,
        target: 100,
      ),

      // Специальные
      Achievement(
        type: AchievementType.perfectSession,
        title: 'Без единой ошибки',
        description:
            'Пройди одну сессию минимум из 5 задач и реши её на 100% без ошибок.',
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
    if (totalSolved >= 25) {
      final a = await unlock(AchievementType.tasksSolved25);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 50) {
      final a = await unlock(AchievementType.tasksSolved50);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 75) {
      final a = await unlock(AchievementType.tasksSolved75);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 100) {
      final a = await unlock(AchievementType.tasksSolved100);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 150) {
      final a = await unlock(AchievementType.tasksSolved150);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 200) {
      final a = await unlock(AchievementType.tasksSolved200);
      if (a != null) unlocked.add(a);
    }
    if (totalSolved >= 300) {
      final a = await unlock(AchievementType.tasksSolved300);
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
  
  /// Проверить идеальную сессию
  static Future<Achievement?> checkPerfectSession(int correct, int total) async {
    if (correct == total && total >= 5) {
      return unlock(AchievementType.perfectSession);
    }
    return null;
  }

  /// Единая точка проверки достижений по текущему прогрессу.
  static Future<List<Achievement>> evaluateProgress({
    required int totalSolved,
    required int streak,
    required double accuracy,
    required int totalAttempts,
    int? sessionCorrect,
    int? sessionTotal,
    int? grade,
    double? gradeProgress,
  }) async {
    final unlocked = <Achievement>[];

    unlocked.addAll(await checkTaskAchievements(totalSolved));
    unlocked.addAll(await checkStreakAchievements(streak));
    unlocked.addAll(await checkAccuracyAchievements(accuracy, totalAttempts));

    if (sessionCorrect != null && sessionTotal != null) {
      final perfect = await checkPerfectSession(sessionCorrect, sessionTotal);
      if (perfect != null) unlocked.add(perfect);
    }

    return unlocked;
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

  static List<String> getUnlockedAvatarSkinIds() {
    final ids = <String>{..._baseAvatarSkins};
    for (final a in _achievements) {
      if (!a.isUnlocked) continue;
      final skinId = _achievementAvatarSkins[a.type];
      if (skinId != null) ids.add(skinId);
    }
    return ids.toList(growable: false);
  }

  static String? getAvatarSkinUnlockedBy(AchievementType type) {
    return _achievementAvatarSkins[type];
  }
}
