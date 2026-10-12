/// Practice Tab — Практика
///
/// Плоский Duolingo-стиль
/// Быстрый тест + статистика
library;

import 'study_hub_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../services/language_service.dart';
import '../data/topic_titles_en.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../models/task.dart';

class PracticeTab extends StatefulWidget {
  const PracticeTab({super.key});

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  int _selectedCount = 10;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageService>().t;
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF60A5FA)
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t('practice.title'),
                          style: AppTypography.h1.copyWith(
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const StudyLinks(),
                  const SizedBox(height: 16),
                  // Быстрый тест
                  _buildQuickTestCard(),

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
    final t = context.watch<LanguageService>().t;
    final grade = ProgressService.getCurrentGrade();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
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
                child: const Icon(Icons.bolt, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('practice.quickTest'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      t('practice.gradeSuffix').replaceAll('{grade}', '$grade'),
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
                    onTap: () {
                      SoundService.hapticSelection();
                      SoundService.playTap();
                      setState(() => _selectedCount = count);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.34),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
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
              onPressed: () {
                SoundService.hapticHeavy();
                SoundService.playStart();
                _startQuickTest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                t('practice.start'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSection() {
    final t = context.watch<LanguageService>().t;
    final isEnglish = context.watch<LanguageService>().isEnglish;
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
        Text(
          t('practice.continue'),
          style: AppTypography.h3.copyWith(
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        ...incompleteTopics.take(3).map((topic) {
          final tasks = getTasksByGradeAndTopic(grade, topic.name);
          final displayTopic = isEnglish
              ? topicTitleEn(topic.name)
              : topic.name;
          final solved = ProgressService.getSolvedCountForTopic(
            topic.name,
            tasks.map((t) => t.id).toList(),
          );
          final progress = solved / topic.taskCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                SoundService.hapticMedium();
                SoundService.playNavigate();
                _openTopic(topic.name, tasks);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemeColors.border(context),
                    width: 2,
                  ),
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
                        child: Icon(
                          topic.icon,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTopic,
                            textAlign: TextAlign.left,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppThemeColors.borderLight(
                                context,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$solved/${topic.taskCount}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
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
    final t = context.watch<LanguageService>().t;
    final totalSolved = ProgressService.getTotalSolved();
    final accuracy = ProgressService.getAccuracy();
    final streak = ProgressService.getStreakDays();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border(context), width: 1.6),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('practice.stats'),
            style: AppTypography.h3.copyWith(
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 360;
              if (!narrow) {
                return Row(
                  children: [
                    _buildStatItem(
                      t('practice.solved'),
                      '$totalSolved',
                      Icons.check_circle_outline,
                      isDark ? AppColors.purple : AppColorsLight.purple,
                    ),
                    _buildStatItem(
                      t('practice.accuracy'),
                      '${accuracy.toStringAsFixed(0)}%',
                      Icons.gps_fixed_rounded,
                      isDark ? AppColors.success : AppColorsLight.success,
                    ),
                    _buildStatItem(
                      t('practice.streak'),
                      '$streak',
                      Icons.local_fire_department_rounded,
                      isDark ? AppColors.orange : AppColorsLight.orange,
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      _buildStatItem(
                        t('practice.solved'),
                        '$totalSolved',
                        Icons.check_circle_outline,
                        isDark ? AppColors.purple : AppColorsLight.purple,
                      ),
                      _buildStatItem(
                        t('practice.accuracy'),
                        '${accuracy.toStringAsFixed(0)}%',
                        Icons.gps_fixed_rounded,
                        isDark ? AppColors.success : AppColorsLight.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatItem(
                        t('practice.streak'),
                        '$streak',
                        Icons.local_fire_department_rounded,
                        isDark ? AppColors.orange : AppColorsLight.orange,
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
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

  void _startQuickTest() {
    final t = context.read<LanguageService>().t;
    final grade = ProgressService.getCurrentGrade();
    final allTasks = getTasksByGrade(grade);

    final shuffled = List<Task>.from(allTasks)..shuffle();
    final selected = shuffled.take(_selectedCount).toList();

    if (selected.isEmpty) return;

    context
        .push(
          '/learn/topic',
          extra: {'name': t('practice.quickTestTopic'), 'tasks': selected},
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  void _openTopic(String topicName, List<Task> tasks) {
    context
        .push('/learn/topic', extra: {'name': topicName, 'tasks': tasks})
        .then((_) {
          if (mounted) setState(() {});
        });
  }
}
