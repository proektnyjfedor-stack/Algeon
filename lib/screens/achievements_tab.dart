/// Achievements Tab — Награды
///
/// Grid достижений с прогрессом и описанием что нужно сделать
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../data/tasks_data.dart';
import '../services/achievements_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

bool _newAchievementsIncludeStreak(List<Achievement> list) {
  for (final a in list) {
    switch (a.type) {
      case AchievementType.streak3:
      case AchievementType.streak7:
      case AchievementType.streak14:
      case AchievementType.streak30:
        return true;
      default:
        break;
    }
  }
  return false;
}

class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  bool _isSyncing = true;

  @override
  void initState() {
    super.initState();
    _syncAchievementsWithProgress();
  }

  Future<void> _evaluateAchievements() async {
    final totalSolved = ProgressService.getTotalSolved();
    final streak = ProgressService.getStreakDays();
    final accuracy = ProgressService.getAccuracy();
    final totalAttempts = ProgressService.getTotalAttempts();
    final grade = ProgressService.getCurrentGrade();
    final gradeTasks = getTasksByGrade(grade);
    final gradeSolved = ProgressService.getSolvedCountForGrade(
      grade,
      gradeTasks.map((t) => t.id).toList(),
    );
    final gradeProgress =
        gradeTasks.isNotEmpty ? gradeSolved / gradeTasks.length : 0.0;

    final newly = await AchievementsService.evaluateProgress(
      totalSolved: totalSolved,
      streak: streak,
      accuracy: accuracy,
      totalAttempts: totalAttempts,
      grade: grade,
      gradeProgress: gradeProgress,
    );
    if (!mounted) return;
    if (newly.isNotEmpty) {
      if (_newAchievementsIncludeStreak(newly)) {
        unawaited(SoundService.playStreak());
      } else {
        unawaited(SoundService.playAchievement());
      }
    }
  }

  Future<void> _syncAchievementsWithProgress() async {
    await _evaluateAchievements();
    if (!mounted) return;
    setState(() => _isSyncing = false);
  }

  Future<void> _pullRefreshAchievements() async {
    await _evaluateAchievements();
    if (!mounted) return;
    setState(() {});
  }

  /// Акцент карточки по категории достижения.
  Color _accentForAchievement(Achievement a) {
    switch (a.type) {
      case AchievementType.firstTask:
      case AchievementType.tasksSolved10:
      case AchievementType.tasksSolved50:
      case AchievementType.tasksSolved100:
      case AchievementType.tasksSolved200:
        return AppColors.accent;
      case AchievementType.streak3:
      case AchievementType.streak7:
      case AchievementType.streak14:
      case AchievementType.streak30:
        return AppColors.orange;
      case AchievementType.accuracy80:
      case AchievementType.accuracy90:
      case AchievementType.accuracy100:
        return AppColors.purple;
      case AchievementType.grade5Complete:
      case AchievementType.grade7Complete:
      case AchievementType.grade9Complete:
      case AchievementType.grade11Complete:
        return AppColors.success;
      case AchievementType.perfectSession:
        return AppColors.pink;
    }
  }

  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 430) return 2;
    if (width < 700) return 2;
    if (width > 900) return 4;
    return 3;
  }

  bool _isPhone(BuildContext context) => MediaQuery.of(context).size.width <= 430;

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

      case AchievementType.grade5Complete:
      case AchievementType.grade7Complete:
      case AchievementType.grade9Complete:
      case AchievementType.grade11Complete:
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
      case AchievementType.grade5Complete:
        return 5;
      case AchievementType.grade7Complete:
        return 7;
      case AchievementType.grade9Complete:
        return 9;
      case AchievementType.grade11Complete:
        return 11;
      default:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = _isPhone(context);
    if (_isSyncing) {
      return Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              children: [
                _skeletonBox(context, height: 34, width: 180),
                const SizedBox(height: 14),
                _skeletonBox(context, height: 14, width: 240),
                const SizedBox(height: 20),
                _skeletonBox(context, height: 160),
                const SizedBox(height: 16),
                _skeletonBox(context, height: 18, width: 150),
                const SizedBox(height: 12),
                ...List.generate(6, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _skeletonBox(context, height: 86),
                    )),
              ],
            ),
          ),
        ),
      );
    }

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
          child: RefreshIndicator(
            color: AppColors.accent,
            edgeOffset: 12,
            onRefresh: _pullRefreshAchievements,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
              // Header
              SliverToBoxAdapter(
                child: _StaggeredReveal(
                  delayMs: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isPhone ? 16 : 24, 20, isPhone ? 16 : 24, 0),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.emoji_events_rounded,
                                color: AppColors.gold, size: isPhone ? 26 : 32),
                            SizedBox(width: isPhone ? 8 : 10),
                            Text('Награды',
                                style: AppTypography.h1.copyWith(
                                  fontSize: isPhone ? 28 : AppTypography.h1.fontSize,
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
                        const SizedBox(height: 8),
                      ],
                      ),
                    ),
                  ),
                ),
              ),

              // Progress Card
              SliverToBoxAdapter(
                child: _StaggeredReveal(
                  delayMs: 40,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isPhone ? 14 : 20, 16, isPhone ? 14 : 20, 8),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(isPhone ? 16 : 24),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 430;
                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildProgressBadge(progress, compact: true),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Прогресс',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${unlocked.length} / ${achievements.length}',
                                          style: TextStyle(
                                            fontSize: isPhone ? 22 : 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Прогресс',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.9),
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
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildProgressBadge(progress),
                          ],
                        );
                      },
                    ),
                    ),
                  ),
                ),
              ),

              // Unlocked Section
              if (unlocked.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _StaggeredReveal(
                    delayMs: 80,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isPhone ? 14 : 20, 24, isPhone ? 14 : 20, 12),
                      child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.gold, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Получено (${unlocked.length})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
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
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isPhone ? 14 : 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: isPhone ? 8 : 12,
                      crossAxisSpacing: isPhone ? 8 : 12,
                      childAspectRatio: isPhone ? 0.92 : 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _StaggeredReveal(
                            delayMs: 100 + (index * 26).clamp(0, 240),
                            child: _buildAchievementCard(
                            unlocked[index],
                            true,
                            _accentForAchievement(unlocked[index]),
                            compact: isPhone,
                          ),
                          ),
                      childCount: unlocked.length,
                    ),
                  ),
                ),
              ],

              // Locked Section
              if (locked.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _StaggeredReveal(
                    delayMs: 90,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isPhone ? 14 : 20, 24, isPhone ? 14 : 20, 12),
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
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(isPhone ? 14 : 20, 0, isPhone ? 14 : 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: isPhone ? 8 : 12,
                      crossAxisSpacing: isPhone ? 8 : 12,
                      childAspectRatio: isPhone ? 0.92 : 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _StaggeredReveal(
                        delayMs: 120 + (index * 22).clamp(0, 240),
                        child: _buildAchievementCard(
                            locked[index],
                            false,
                            _accentForAchievement(locked[index]),
                            compact: isPhone,
                          ),
                      ),
                      childCount: locked.length,
                    ),
                  ),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeletonBox(
    BuildContext context, {
    required double height,
    double? width,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppThemeColors.borderLight(context),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildProgressBadge(double progress, {bool compact = false}) {
    final box = compact ? 60.0 : 72.0;
    final ring = compact ? 52.0 : 64.0;
    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: ring,
              height: ring,
              child: TweenAnimationBuilder<double>(
                key: ValueKey('ach_progress_${progress.toStringAsFixed(3)}'),
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, _) {
                  return CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: compact ? 5 : 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  );
                },
              ),
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: compact ? 13 : 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAchievementCard(
    Achievement achievement,
    bool isUnlocked,
    Color accent,
    {bool compact = false}
  ) {
    final pd = _getAchievementProgress(achievement);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(compact ? 16 : 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        onTap: () {
          SoundService.hapticMedium();
          _showAchievementDetail(achievement);
        },
        child: Ink(
          decoration: BoxDecoration(
            color: AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(compact ? 16 : 20),
            border: Border.all(
              color: isUnlocked
                  ? accent
                  : AppThemeColors.border(context),
              width: isUnlocked ? 2 : 1,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: compact ? 8 : 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 42 : 52,
                  height: compact ? 42 : 52,
                  decoration: isUnlocked
                      ? BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(compact ? 12 : 16),
                        )
                      : BoxDecoration(
                          color: AppThemeColors.borderLight(context),
                          borderRadius: BorderRadius.circular(compact ? 12 : 16),
                        ),
                  child: Center(
                    child: Icon(
                      isUnlocked ? achievement.icon : Icons.lock_rounded,
                      color: isUnlocked ? Colors.white : AppThemeColors.textHint(context),
                      size: compact ? (isUnlocked ? 22 : 20) : (isUnlocked ? 28 : 24),
                    ),
                  ),
                ),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
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
                  SizedBox(height: compact ? 4 : 6),
                  // Мини прогресс-бар
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('ach_card_${achievement.key}_${pd.progress.toStringAsFixed(3)}'),
                        tween: Tween(begin: 0, end: pd.progress),
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedProgress, _) {
                          return LinearProgressIndicator(
                            value: animatedProgress,
                            minHeight: 4,
                            backgroundColor: AppThemeColors.borderLight(context),
                            valueColor: AlwaysStoppedAnimation(
                              pd.progress >= 1.0
                                  ? AppColors.success
                                  : accent,
                            ),
                          );
                        },
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
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    final pd = _getAchievementProgress(achievement);

    SoundService.playPop();

    if (achievement.isUnlocked) {
      unawaited(SoundService.hapticBurst(steps: 5));
    } else {
      SoundService.hapticSelection();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('ach_detail_${achievement.key}_${pd.progress.toStringAsFixed(3)}'),
                    tween: Tween(begin: 0, end: pd.progress),
                    duration: const Duration(milliseconds: 560),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedProgress, _) {
                      return LinearProgressIndicator(
                        value: animatedProgress,
                        minHeight: 10,
                        backgroundColor: AppThemeColors.borderLight(context),
                        valueColor: AlwaysStoppedAnimation(
                          pd.progress >= 1.0
                              ? AppColors.success
                              : AppColors.accent,
                        ),
                      );
                    },
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
                  onPressed: () {
                    SoundService.hapticLight();
                    SoundService.playTap();
                    Navigator.of(dialogContext).pop();
                  },
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

class _StaggeredReveal extends StatefulWidget {

  const _StaggeredReveal({
    required this.child,
    this.delayMs = 0,
  });
  final Widget child;
  final int delayMs;

  @override
  State<_StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<_StaggeredReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.03),
        child: widget.child,
      ),
    );
  }
}
