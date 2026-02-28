/// Achievements Tab — Награды
///
/// Grid достижений с прогрессом и описанием что нужно сделать

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/achievements_service.dart';
import '../services/progress_service.dart';
import '../data/tasks_data.dart';

class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 4;
    return 3;
  }

  /// Получить прогресс и текст для достижения
  ({double progress, String progressText}) _getAchievementProgress(
      Achievement a) {
    final totalSolved = ProgressService.getTotalSolved();
    final streak = ProgressService.getStreakDays();
    final accuracy = ProgressService.getAccuracy();
    final totalAttempts = ProgressService.getTotalAttempts();

    if (a.isUnlocked) {
      return (progress: 1.0, progressText: 'Выполнено!');
    }

    switch (a.type) {
      case AchievementType.firstTask:
      case AchievementType.tasksSolved10:
      case AchievementType.tasksSolved50:
      case AchievementType.tasksSolved100:
      case AchievementType.tasksSolved200:
        final p = (totalSolved / a.target).clamp(0.0, 1.0);
        return (progress: p, progressText: '$totalSolved / ${a.target} задач');

      case AchievementType.streak3:
      case AchievementType.streak7:
      case AchievementType.streak14:
      case AchievementType.streak30:
        final p = (streak / a.target).clamp(0.0, 1.0);
        return (progress: p, progressText: '$streak / ${a.target} дней');

      case AchievementType.accuracy80:
      case AchievementType.accuracy90:
      case AchievementType.accuracy100:
        final p = totalAttempts >= 20
            ? (accuracy / a.target).clamp(0.0, 1.0)
            : 0.0;
        final extra = totalAttempts < 20
            ? ' (мин. 20 попыток)'
            : '';
        return (
          progress: p,
          progressText: '${accuracy.toStringAsFixed(0)}% / ${a.target}%$extra'
        );

      case AchievementType.grade1Complete:
      case AchievementType.grade2Complete:
      case AchievementType.grade3Complete:
      case AchievementType.grade4Complete:
        final grade = _gradeFromType(a.type);
        final tasks = getTasksByGrade(grade);
        final solved = ProgressService.getSolvedCountForGrade(
            grade, tasks.map((t) => t.id).toList());
        final total = tasks.length;
        final p = total > 0 ? (solved / total).clamp(0.0, 1.0) : 0.0;
        return (progress: p, progressText: '$solved / $total тем');

      case AchievementType.perfectSession:
        return (
          progress: 0.0,
          progressText: '100% в сессии (мин. 5 задач)'
        );
    }
  }

  int _gradeFromType(AchievementType type) {
    switch (type) {
      case AchievementType.grade1Complete:
        return 1;
      case AchievementType.grade2Complete:
        return 2;
      case AchievementType.grade3Complete:
        return 3;
      case AchievementType.grade4Complete:
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementsService.getAll();
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();
    final progress = AchievementsService.getProgress();
    final columns = _getGridColumns(context);

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events_rounded,
                                color: AppColors.accent, size: 32),
                            const SizedBox(width: 12),
                            Text('Награды',
                                style: AppTypography.h1.copyWith(
                                  color:
                                      AppThemeColors.textPrimary(context),
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Собирай достижения за успехи',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppThemeColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Progress Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Icon(Icons.military_tech_rounded,
                                color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Прогресс',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${unlocked.length}',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    ' / ${achievements.length}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child:
                                      CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.3),
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            Colors.white),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Unlocked Section
              if (unlocked.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppThemeColors.successLight(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.success, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Получено (${unlocked.length})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildAchievementCard(unlocked[index], true),
                      childCount: unlocked.length,
                    ),
                  ),
                ),
              ],

              // Locked Section
              if (locked.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppThemeColors.borderLight(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline,
                                  color:
                                      AppThemeColors.textHint(context),
                                  size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Заблокировано (${locked.length})',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppThemeColors.textHint(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAchievementCard(
                          locked[index], false),
                      childCount: locked.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
      Achievement achievement, bool isUnlocked) {
    final pd = _getAchievementProgress(achievement);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAchievementDetail(achievement);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? AppColors.gold
                : AppThemeColors.border(context),
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.gold
                      : AppThemeColors.borderLight(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    isUnlocked ? achievement.icon : Icons.lock_rounded,
                    color: isUnlocked ? Colors.white : AppThemeColors.textHint(context),
                    size: isUnlocked ? 28 : 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked
                      ? AppThemeColors.textPrimary(context)
                      : AppThemeColors.textHint(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Прогресс текст
              if (!isUnlocked) ...[
                Text(
                  pd.progressText,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppThemeColors.textHint(context),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Мини прогресс-бар
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pd.progress,
                      minHeight: 4,
                      backgroundColor: AppThemeColors.borderLight(context),
                      valueColor: AlwaysStoppedAnimation(
                        pd.progress >= 1.0
                            ? AppColors.success
                            : AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    final pd = _getAchievementProgress(achievement);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppThemeColors.surface(dialogContext),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.gold
                      : AppThemeColors.borderLight(dialogContext),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Icon(
                    achievement.isUnlocked
                        ? achievement.icon
                        : Icons.lock_rounded,
                    color: achievement.isUnlocked
                        ? Colors.white
                        : AppThemeColors.textHint(context),
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                achievement.title,
                style: AppTypography.h2.copyWith(
                  color: AppThemeColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 15,
                  color: AppThemeColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),

              // Прогресс-бар для незаблокированных
              if (!achievement.isUnlocked) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pd.progress,
                    minHeight: 10,
                    backgroundColor: AppThemeColors.borderLight(context),
                    valueColor: AlwaysStoppedAnimation(
                      pd.progress >= 1.0
                          ? AppColors.success
                          : AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pd.progressText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ],

              if (achievement.isUnlocked &&
                  achievement.unlockedAt != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppThemeColors.successLight(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Получено ${_formatDate(achievement.unlockedAt!)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!achievement.isUnlocked) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppThemeColors.borderLight(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline,
                          color: AppThemeColors.textHint(context),
                          size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Ещё не получено',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textHint(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Закрыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
