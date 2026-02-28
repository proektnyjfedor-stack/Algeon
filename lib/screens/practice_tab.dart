/// Practice Tab — Практика
///
/// Плоский Duolingo-стиль
/// Быстрый тест + статистика

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../services/progress_service.dart';
import '../services/ai_service.dart';
import '../models/task.dart';

class PracticeTab extends StatefulWidget {
  const PracticeTab({super.key});

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  int _selectedCount = 10;
  bool _aiGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text('Практика',
                      style: AppTypography.h1.copyWith(
                        color: AppThemeColors.textPrimary(context),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Закрепляй знания',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppThemeColors.textSecondary(context),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Быстрый тест
                  _buildQuickTestCard(),

                  const SizedBox(height: 16),

                  // ИИ-задачи
                  _buildAiTasksCard(),

                  const SizedBox(height: 16),

                  // Повторить темы
                  _buildRepeatSection(),

                  const SizedBox(height: 16),

                  // Статистика
                  _buildStatsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTestCard() {
    final grade = ProgressService.getCurrentGrade();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Быстрый тест',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$grade класс',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Выбор количества
          Row(
            children: [5, 10, 15].map((count) {
              final isSelected = _selectedCount == count;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: count == 15 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCount = count),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? AppColors.accent : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Кнопка
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _startQuickTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accent,
                elevation: 0,
              ),
              child: const Text('НАЧАТЬ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSection() {
    final grade = ProgressService.getCurrentGrade();
    final topics = getTopicsInfoByGrade(grade);

    final incompleteTopics = topics.where((topic) {
      final tasks = getTasksByGradeAndTopic(grade, topic.name);
      final solved = ProgressService.getSolvedCountForTopic(
        topic.name,
        tasks.map((t) => t.id).toList(),
      );
      return solved > 0 && solved < topic.taskCount;
    }).toList();

    if (incompleteTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Продолжить',
            style: AppTypography.h3.copyWith(
              color: AppThemeColors.textPrimary(context),
            )),
        const SizedBox(height: 12),
        ...incompleteTopics.take(3).map((topic) {
          final tasks = getTasksByGradeAndTopic(grade, topic.name);
          final solved = ProgressService.getSolvedCountForTopic(
            topic.name,
            tasks.map((t) => t.id).toList(),
          );
          final progress = solved / topic.taskCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openTopic(topic.name, tasks);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppThemeColors.border(context), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppThemeColors.accentLight(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(topic.icon,
                            color: AppColors.accent, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(topic.name,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppThemeColors.textPrimary(context),
                              )),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  AppThemeColors.borderLight(context),
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.accent),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$solved/${topic.taskCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsCard() {
    final totalSolved = ProgressService.getTotalSolved();
    final accuracy = ProgressService.getAccuracy();
    final streak = ProgressService.getStreakDays();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppThemeColors.border(context), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Статистика',
              style: AppTypography.h3.copyWith(
                color: AppThemeColors.textPrimary(context),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Решено', '$totalSolved', Icons.check_circle_outline),
              _buildStatItem('Точность', '${accuracy.toStringAsFixed(0)}%', Icons.gps_fixed_rounded),
              _buildStatItem('Серия', '$streak', Icons.local_fire_department_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiTasksCard() {
    final grade = ProgressService.getCurrentGrade();
    final topics = getTopicsInfoByGrade(grade);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeColors.accentLight(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ИИ-задачи',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Новые задачи от ИИ по теме',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              return GestureDetector(
                onTap: _aiGenerating
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        _generateAiTasks(grade, topic.name);
                      },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppThemeColors.accentLight(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    topic.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_aiGenerating) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ИИ генерирует задачи...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateAiTasks(int grade, String topic) async {
    setState(() => _aiGenerating = true);

    final tasks = await AiService.generateTasks(
      grade: grade,
      topic: topic,
      count: 5,
    );

    if (!mounted) return;
    setState(() => _aiGenerating = false);

    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сгенерировать задачи')),
      );
      return;
    }

    context
        .push(
          '/learn/topic',
          extra: {'name': '$topic (ИИ)', 'tasks': tasks},
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  void _startQuickTest() {
    final grade = ProgressService.getCurrentGrade();
    final allTasks = getTasksByGrade(grade);

    final shuffled = List<Task>.from(allTasks)..shuffle();
    final selected = shuffled.take(_selectedCount).toList();

    if (selected.isEmpty) return;

    context
        .push(
          '/learn/topic',
          extra: {'name': 'Быстрый тест', 'tasks': selected},
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openTopic(String topicName, List<Task> tasks) {
    context
        .push(
          '/learn/topic',
          extra: {'name': topicName, 'tasks': tasks},
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }
}
