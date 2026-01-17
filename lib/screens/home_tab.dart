/// Вкладка "Главная" — список тем как на макете
/// 
/// Показывает: прогресс, кол-во заданий, уровень, замки

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../services/progress_service.dart';
import 'task_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    // Все темы из всех классов
    final allTopics = _getAllTopicsWithLevels();
    
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: allTopics.length,
        itemBuilder: (context, index) {
          final topic = allTopics[index];
          return _buildTopicCard(topic, index);
        },
      ),
    );
  }

  /// Получить все темы с уровнями
  List<_TopicData> _getAllTopicsWithLevels() {
    final List<_TopicData> result = [];
    
    // Уровень 1 — 2 класс
    final grade2Topics = getTopicsInfoByGrade(2);
    for (final topic in grade2Topics) {
      final tasks = getTasksByGradeAndTopic(2, topic.name);
      final solvedCount = ProgressService.getSolvedCountForTopic(
        topic.name, 
        tasks.map((t) => t.id).toList(),
      );
      result.add(_TopicData(
        name: topic.name,
        grade: 2,
        level: 1,
        taskCount: tasks.length,
        solvedCount: solvedCount,
        isUnlocked: true, // Первый уровень всегда открыт
      ));
    }
    
    // Уровень 2 — 3 класс (заблокирован пока не пройден уровень 1)
    final grade3Topics = getTopicsInfoByGrade(3);
    final level1Completed = result.isNotEmpty && 
        result.every((t) => t.solvedCount >= t.taskCount * 0.5);
    
    for (final topic in grade3Topics) {
      final tasks = getTasksByGradeAndTopic(3, topic.name);
      final solvedCount = ProgressService.getSolvedCountForTopic(
        topic.name,
        tasks.map((t) => t.id).toList(),
      );
      result.add(_TopicData(
        name: topic.name,
        grade: 3,
        level: 2,
        taskCount: tasks.length,
        solvedCount: solvedCount,
        isUnlocked: level1Completed,
      ));
    }
    
    // Добавляем заглушки для демо (как на макете — много карточек)
    if (result.length < 8) {
      for (int i = result.length; i < 8; i++) {
        result.add(_TopicData(
          name: 'Тема ${i + 1}',
          grade: 3,
          level: 2,
          taskCount: 0,
          solvedCount: 0,
          isUnlocked: false,
        ));
      }
    }
    
    return result;
  }

  /// Карточка темы (как на макете)
  Widget _buildTopicCard(_TopicData topic, int index) {
    final progress = topic.taskCount > 0 
        ? topic.solvedCount / topic.taskCount 
        : 0.0;
    
    return GestureDetector(
      onTap: topic.isUnlocked && topic.taskCount > 0
          ? () => _openTopic(topic)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: topic.isUnlocked ? AppColors.accent : AppColors.border,
            width: topic.isUnlocked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Иконка (замок или галочка)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: topic.isUnlocked 
                    ? AppColors.accentLight 
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                topic.isUnlocked ? Icons.lock_open : Icons.lock,
                color: topic.isUnlocked 
                    ? AppColors.accent 
                    : AppColors.textHint,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Прогресс и текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Текст "Пройдено X из Y" или название
                  Text(
                    topic.isUnlocked && topic.taskCount > 0
                        ? 'Пройдено ${topic.solvedCount} из ${topic.taskCount}'
                        : topic.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: topic.isUnlocked 
                          ? AppColors.textPrimary 
                          : AppColors.textHint,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Прогресс-бар
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        topic.isUnlocked ? AppColors.accent : AppColors.textHint,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Кол-во заданий
            Column(
              children: [
                Text(
                  '${topic.taskCount}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: topic.isUnlocked 
                        ? AppColors.textPrimary 
                        : AppColors.textHint,
                  ),
                ),
                Text(
                  'заданий',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Уровень
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: topic.isUnlocked 
                    ? AppColors.accent 
                    : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: topic.isUnlocked 
                    ? null 
                    : Border.all(color: AppColors.border),
              ),
              child: Text(
                'Ур ${topic.level}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: topic.isUnlocked 
                      ? Colors.white 
                      : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Открыть тему
  void _openTopic(_TopicData topic) {
    final tasks = getTasksByGradeAndTopic(topic.grade, topic.name);
    
    if (tasks.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskScreen(tasks: tasks, topicName: topic.name),
      ),
    ).then((_) => setState(() {}));
  }
}

/// Данные темы
class _TopicData {
  final String name;
  final int grade;
  final int level;
  final int taskCount;
  final int solvedCount;
  final bool isUnlocked;

  _TopicData({
    required this.name,
    required this.grade,
    required this.level,
    required this.taskCount,
    required this.solvedCount,
    required this.isUnlocked,
  });
}
