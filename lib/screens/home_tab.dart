/// Home Tab — Главная с прогрессом
/// Величественный дизайн Algeon

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/user_avatar_display.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  int get _grade => ProgressService.getCurrentGrade();

  late AnimationController _listAnim;
  bool _dailyBonusChecked = false;

  ({Color primary, Color secondary, Color soft}) _equippedPalette() {
    final equipped = ProgressService.getEquippedBetaItem();
    switch (equipped) {
      case 'skin_gold_star':
        return (
          primary: const Color(0xFFD4A017),
          secondary: const Color(0xFFB8860B),
          soft: const Color(0xFFFFF7D6),
        );
      case 'theme_space':
        return (
          primary: const Color(0xFF312E81),
          secondary: const Color(0xFF1E1B4B),
          soft: const Color(0xFFEDE9FE),
        );
      case 'skin_neon_blue':
      default:
        return (
          primary: AppColors.accent,
          secondary: const Color(0xFF1E40AF),
          soft: const Color(0xFFEAF2FF),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _listAnim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyBonus();
    });
  }

  @override
  void dispose() {
    _listAnim.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _checkDailyBonus() async {
    if (_dailyBonusChecked) return;
    _dailyBonusChecked = true;
    final bonus = await ProgressService.claimDailyBonusIfAvailable();
    if (!mounted || bonus <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.card_giftcard_rounded, color: AppColors.gold),
            const SizedBox(width: 8),
            Text('Ежедневный бонус: +$bonus монет'),
          ],
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final topics = getTopicsInfoByGrade(_grade);
    final allGradeTasks = getTasksByGrade(_grade);
    final totalTasks = allGradeTasks.length;
    final totalSolved = ProgressService.getSolvedCountForGrade(
      _grade,
      allGradeTasks.map((t) => t.id).toList(),
    );
    final todayCompleted = ProgressService.getTodayCompletedCount();
    final userName = ProgressService.getUserName();
    final coins = ProgressService.getCoins();
    final overallProgress = totalTasks > 0 ? totalSolved / totalTasks : 0.0;
    final palette = _equippedPalette();

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: _buildHeroHeader(userName, todayCompleted, totalSolved, totalTasks, overallProgress, coins),
          ),

          // Daily goal widget
          SliverToBoxAdapter(
            child: _buildDailyGoal(todayCompleted),
          ),
          SliverToBoxAdapter(
            child: _buildQuickActions(topics),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Темы $_grade класса',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppThemeColors.accentLight(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${topics.length} тем',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Topics list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTopicCard(
                  topic: topics[index],
                  index: index,
                  allTopics: topics,
                  accent: palette.primary,
                ),
                childCount: topics.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
    String userName,
    int todayCompleted,
    int solved,
    int total,
    double progress,
    int coins,
  ) {
    final palette = _equippedPalette();
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: palette.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              // Top row: logo + grade / avatar + greeting
              Row(
                children: [
                  const AppLogo(size: 36),
                  const SizedBox(width: 10),
                  const Text(
                    'Algeon',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    behavior: HitTestBehavior.opaque,
                    child: const UserAvatarDisplay(size: 40),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_grade кл.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Greeting row
              Text(
                'Привет, $userName! Сегодня решено: $todayCompleted',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$coins монет',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Progress card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Circle progress
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Прогресс по классу',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$solved',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / $total задач',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Streak indicator
                    Column(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            color: const Color(0xFFFF9600), size: 22),
                        Text(
                          '${ProgressService.getStreakDays()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'дней',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildDailyGoal(int todayCompleted) {
    final palette = _equippedPalette();
    const int dailyGoal = 10;
    final int done = todayCompleted.clamp(0, dailyGoal);
    final double progress = done / dailyGoal;
    final bool goalReached = done >= dailyGoal;

    String message;
    if (goalReached) {
      message = 'Цель достигнута! 🎉';
    } else if (done == 0) {
      message = 'Начни решать — цель $dailyGoal задач в день';
    } else {
      message = 'Ещё ${dailyGoal - done} до цели';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goalReached
                ? AppColors.success.withValues(alpha: 0.4)
                : AppThemeColors.border(context),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: goalReached
                    ? AppThemeColors.successLight(context)
                    : AppThemeColors.accentLight(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  goalReached ? '🏆' : '🎯',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Progress info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Дневная цель',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$done / $dailyGoal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: goalReached
                              ? AppColors.success
                              : palette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: AppThemeColors.border(context),
                      valueColor: AlwaysStoppedAnimation(
                        goalReached ? AppColors.success : palette.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppThemeColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(List<TopicInfo> topics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _QuickHomeButton(
            icon: Icons.play_arrow_rounded,
            title: 'Продолжить',
            subtitle: 'С текущего места',
            onTap: () => _continueLearning(topics),
          ),
          _QuickHomeButton(
            icon: Icons.bolt_rounded,
            title: 'Практика',
            subtitle: 'Быстрые задания',
            onTap: () => context.go('/practice'),
          ),
          _QuickHomeButton(
            icon: Icons.assignment_rounded,
            title: 'Экзамен',
            subtitle: 'Режим ОГЭ/ЕГЭ',
            onTap: () => context.go('/exams'),
          ),
        ],
      ),
    );
  }

  void _continueLearning(List<TopicInfo> topics) {
    TopicInfo? target;
    List<Task> targetTasks = const [];

    for (final topic in topics) {
      final tasks = getTasksByGradeAndTopic(_grade, topic.name);
      final solved = ProgressService.getSolvedCountForTopic(
        topic.name,
        tasks.map((t) => t.id).toList(),
      );
      if (solved < tasks.length) {
        target = topic;
        targetTasks = tasks;
        break;
      }
    }

    if (target == null && topics.isNotEmpty) {
      target = topics.first;
      targetTasks = getTasksByGradeAndTopic(_grade, target.name);
    }

    if (target == null || targetTasks.isEmpty) return;
    _openTopic(target.name, targetTasks);
  }

  Widget _buildTopicCard({
    required TopicInfo topic,
    required int index,
    required List<TopicInfo> allTopics,
    required Color accent,
  }) {
    final tasks = getTasksByGradeAndTopic(_grade, topic.name);
    final taskIds = tasks.map((t) => t.id).toList();
    final solved = ProgressService.getSolvedCountForTopic(topic.name, taskIds);
    final total = topic.taskCount;

    final isComplete = solved >= total && total > 0;
    final progress = total > 0 ? solved / total : 0.0;

    final delay = (index * 0.08).clamp(0.0, 0.55);
    final interval = Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutCubic);
    final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _listAnim, curve: interval),
    );
    final slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _listAnim, curve: interval),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isComplete
                    ? AppColors.success.withValues(alpha: 0.5)
                    : AppThemeColors.border(context),
                width: isComplete ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? AppColors.success
                        : accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isComplete
                        ? Icons.check_rounded
                        : topic.icon,
                    color: isComplete
                        ? Colors.white
                        : Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Topic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Text(
                            '$solved/$total',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isComplete
                                  ? AppColors.success
                                  : AppThemeColors.textHint(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppThemeColors.borderLight(context),
                          valueColor: AlwaysStoppedAnimation(
                            isComplete ? AppColors.success : accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppThemeColors.textHint(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  void _openTopic(String topicName, List<Task> tasks) {
    HapticFeedback.mediumImpact();
    context
        .push('/learn/intro', extra: {'name': topicName, 'tasks': tasks})
        .then((_) => _refresh());
  }
}

class _QuickHomeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickHomeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppThemeColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppThemeColors.accentLight(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppThemeColors.textSecondary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
