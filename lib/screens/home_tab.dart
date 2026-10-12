/// Home Tab — Главная с прогрессом
/// Величественный дизайн Algeon
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../models/task.dart';
import '../services/learning_service.dart';
import '../services/progress_service.dart';
import '../services/study_session_service.dart';
import '../services/sound_service.dart';
import '../services/language_service.dart';
import '../data/topic_titles_en.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  static const String _installBannerDismissedKey =
      'install_app_banner_dismissed';

  int get _grade => ProgressService.getCurrentGrade();
  bool get _noMotion => kIsWeb;

  late AnimationController _listAnim;

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
          primary: Theme.of(context).colorScheme.primary,
          secondary: Theme.of(context).colorScheme.primary,
          soft: AppThemeColors.accentLight(context),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(
      vsync: this,
      duration: _noMotion
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 700),
    );
    if (_noMotion) {
      _listAnim.value = 1;
    } else {
      _listAnim.forward();
    }
  }

  @override
  void dispose() {
    _listAnim.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageService>().t;
    final topics = getTopicsInfoByGrade(_grade);
    final todayCompleted = ProgressService.getTodayCompletedCount();
    final palette = _equippedPalette();

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        edgeOffset: 8,
        onRefresh: () async {
          SoundService.hapticLight();
          SoundService.playTap();
          _refresh();
          await Future<void>.delayed(const Duration(milliseconds: 220));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: kIsWeb ? ClampingScrollPhysics() : BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildInstallAppBanner()),
            SliverToBoxAdapter(
              child: _buildLearningOverview(topics, todayCompleted),
            ),
            SliverToBoxAdapter(child: _buildDailyGoal(todayCompleted)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.search_rounded),
                    title: const Text('Найти тему или задание'),
                    trailing: IconButton(
                      tooltip: 'Закладки',
                      icon: const Icon(Icons.bookmarks_outlined),
                      onPressed: () => context.push('/library?saved=1'),
                    ),
                    onTap: () => context.push('/library'),
                  ),
                ),
              ),
            ),
            if (StudySessionService.current != null &&
                StudySessionService.tasks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: FilledButton.icon(
                    onPressed: () {
                      final saved = StudySessionService.current!;
                      context
                          .push(
                            '/learn/topic',
                            extra: {
                              'name': saved['topic'],
                              'tasks': StudySessionService.tasks,
                            },
                          )
                          .then((_) => _refresh());
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      context.watch<LanguageService>().isEnglish
                          ? 'Continue unfinished practice'
                          : 'Продолжить: ${StudySessionService.current!["topic"]} · ${(StudySessionService.current!["index"] as int) + 1}/${StudySessionService.tasks.length}',
                    ),
                  ),
                ),
              ),
            if (LearningService.instance.diagnostic.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.explore_outlined),
                      title: const Text('С чего начать?'),
                      subtitle: const Text('Определи уровень за 9 заданий'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/diagnostic'),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _buildNextTopicCard(topics)),

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
                        borderRadius: BorderRadius.circular(2),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('home.topics').replaceAll('{grade}', '$_grade'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeColors.accentLight(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.watch<LanguageService>().isEnglish
                            ? '${topics.length} topics'
                            : '${topics.length} тем',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
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
                    accent: palette.primary,
                  ),
                  childCount: topics.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningOverview(List<TopicInfo> topics, int todayCompleted) {
    final lang = context.watch<LanguageService>();
    final t = lang.t;
    final userName = ProgressService.getUserName().trim();
    final displayName = userName.isEmpty
        ? (lang.isEnglish ? 'Student' : 'Ученик')
        : userName;
    final gradeTasks = getTasksByGrade(_grade);
    final gradeSolved = ProgressService.getSolvedCountForGrade(
      _grade,
      gradeTasks.map((task) => task.id).toList(),
    );
    final total = gradeTasks.length;
    final gradeProgress = total == 0 ? 0.0 : gradeSolved / total;
    final percent = (gradeProgress * 100).round();
    final accuracy = ProgressService.getAccuracy().round();
    final streak = ProgressService.getStreakDays();
    final palette = _equippedPalette();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppThemeColors.border(context)),
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? palette.primary.withValues(alpha: 0.18)
                        : palette.soft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: palette.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('home.greeting').replaceAll('{name}', displayName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        t('home.gradeProgress')
                            .replaceAll('{grade}', '$_grade')
                            .replaceAll('{percent}', '$percent'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: gradeProgress,
                minHeight: 9,
                backgroundColor: AppThemeColors.borderLight(context),
                valueColor: AlwaysStoppedAnimation(palette.primary),
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 430;
                final stats = [
                  _OverviewStatData(
                    icon: Icons.check_circle_rounded,
                    label: t('home.solvedShort'),
                    value: '$gradeSolved/$total',
                    color: AppColors.success,
                  ),
                  _OverviewStatData(
                    icon: Icons.track_changes_rounded,
                    label: t('home.accuracyShort'),
                    value: '$accuracy%',
                    color: AppColors.purple,
                  ),
                  _OverviewStatData(
                    icon: Icons.local_fire_department_rounded,
                    label: t('home.streakShort'),
                    value: '$streak',
                    color: AppColors.orange,
                  ),
                  _OverviewStatData(
                    icon: Icons.today_rounded,
                    label: t('home.todayShort'),
                    value: '$todayCompleted',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ];
                if (narrow) {
                  return Column(
                    children: [
                      Row(
                        children: stats
                            .take(2)
                            .map(
                              (stat) =>
                                  Expanded(child: _OverviewStat(stat: stat)),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: stats
                            .skip(2)
                            .map(
                              (stat) =>
                                  Expanded(child: _OverviewStat(stat: stat)),
                            )
                            .toList(),
                      ),
                    ],
                  );
                }
                return Row(
                  children: stats
                      .map((stat) => Expanded(child: _OverviewStat(stat: stat)))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallAppBanner() {
    if (ProgressService.getBool(_installBannerDismissedKey)) {
      return const SizedBox.shrink();
    }

    final t = context.watch<LanguageService>().t;
    final palette = _equippedPalette();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: palette.primary.withValues(alpha: 0.28),
            width: 1.3,
          ),
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemeColors.accentLight(context),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.install_mobile_rounded,
                    color: palette.primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('install.title'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t('install.subtitle'),
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: t('common.close'),
                  onPressed: () async {
                    SoundService.playTap();
                    await ProgressService.setBool(
                      _installBannerDismissedKey,
                      true,
                    );
                    _refresh();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppThemeColors.textHint(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 560;
                final cards = [
                  _InstallStepsCard(
                    icon: Icons.ios_share_rounded,
                    title: t('install.iosTitle'),
                    steps: [
                      t('install.iosStep1'),
                      t('install.iosStep2'),
                      t('install.iosStep3'),
                    ],
                  ),
                  _InstallStepsCard(
                    icon: Icons.more_vert_rounded,
                    title: t('install.androidTitle'),
                    steps: [
                      t('install.androidStep1'),
                      t('install.androidStep2'),
                      t('install.androidStep3'),
                    ],
                  ),
                ];
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [cards[0], const SizedBox(height: 10), cards[1]],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 10),
                    Expanded(child: cards[1]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoal(int todayCompleted) {
    final t = context.watch<LanguageService>().t;
    final palette = _equippedPalette();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const int dailyGoal = 10;
    final int done = todayCompleted.clamp(0, dailyGoal);
    final double progress = done / dailyGoal;
    final bool goalReached = done >= dailyGoal;

    String message;
    if (goalReached) {
      message = t('home.goalReached');
    } else if (done == 0) {
      message = t('home.startText');
    } else {
      message = t('home.toGoal').replaceAll('{count}', '${dailyGoal - done}');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: goalReached
              ? AppThemeColors.successLight(context)
              : (isDark ? AppThemeColors.surface(context) : palette.soft),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goalReached
                ? AppColors.success.withValues(alpha: 0.55)
                : (isDark
                      ? AppThemeColors.border(context)
                      : palette.primary.withValues(alpha: 0.42)),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (goalReached ? AppColors.success : palette.primary)
                  .withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: goalReached
                    ? AppColors.success.withValues(alpha: 0.16)
                    : palette.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  goalReached ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  size: 24,
                  color: goalReached ? AppColors.success : palette.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Progress info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t('home.dailyGoal'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$done / $dailyGoal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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
                    child: _noMotion
                        ? LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: palette.primary.withValues(
                              alpha: 0.16,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              goalReached ? AppColors.success : palette.primary,
                            ),
                          )
                        : TweenAnimationBuilder<double>(
                            key: ValueKey(
                              'daily_goal_${progress.toStringAsFixed(3)}',
                            ),
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 560),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedProgress, _) {
                              return LinearProgressIndicator(
                                value: animatedProgress,
                                minHeight: 7,
                                backgroundColor: palette.primary.withValues(
                                  alpha: 0.16,
                                ),
                                valueColor: AlwaysStoppedAnimation(
                                  goalReached
                                      ? AppColors.success
                                      : palette.primary,
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppThemeColors.textPrimary(context),
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

  Widget _buildNextTopicCard(List<TopicInfo> topics) {
    final lang = context.watch<LanguageService>();
    final t = lang.t;
    final palette = _equippedPalette();
    TopicInfo? target;
    List<Task> targetTasks = const [];
    var solved = 0;

    for (final topic in topics) {
      final tasks = getTasksByGradeAndTopic(_grade, topic.name);
      final count = ProgressService.getSolvedCountForTopic(
        topic.name,
        tasks.map((task) => task.id).toList(),
      );
      if (count < tasks.length) {
        target = topic;
        targetTasks = tasks;
        solved = count;
        break;
      }
    }

    if (target == null || targetTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: _InfoRouteCard(
          icon: Icons.workspace_premium_rounded,
          title: t('home.gradeDoneTitle'),
          subtitle: t('home.gradeDoneSub'),
          accent: AppColors.success,
          onTap: () => context.go('/practice'),
        ),
      );
    }

    final displayTopic = lang.isEnglish
        ? topicTitleEn(target.name)
        : target.name;
    final total = targetTasks.length;
    final progress = total == 0 ? 0.0 : solved / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: _PressableScale(
        onTap: () => _openTopic(target!.name, targetTasks),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.34),
              width: 1.3,
            ),
            boxShadow: AppShadows.card(context),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppThemeColors.accentLight(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(target.icon, color: palette.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('home.nextStep'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      displayTopic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppThemeColors.borderLight(context),
                        valueColor: AlwaysStoppedAnimation(palette.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$solved/$total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: palette.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: palette.primary,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required TopicInfo topic,
    required int index,
    required Color accent,
  }) {
    final isEnglish = context.watch<LanguageService>().isEnglish;
    final displayTopic = isEnglish ? topicTitleEn(topic.name) : topic.name;
    final tasks = getTasksByGradeAndTopic(_grade, topic.name);
    final taskIds = tasks.map((t) => t.id).toList();
    final solved = ProgressService.getSolvedCountForTopic(topic.name, taskIds);
    final total = topic.taskCount;

    final isComplete = solved >= total && total > 0;
    final progress = total > 0 ? solved / total : 0.0;
    final isStarted = solved > 0 && !isComplete;
    final status = isComplete
        ? context.watch<LanguageService>().t('home.statusDone')
        : isStarted
        ? context.watch<LanguageService>().t('home.statusInProgress')
        : context.watch<LanguageService>().t('home.statusStart');

    final delay = (index * 0.08).clamp(0.0, 0.55);
    final interval = Interval(
      delay,
      (delay + 0.4).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );
    final fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _listAnim, curve: interval));
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _listAnim, curve: interval));

    final card = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _PressableScale(
        onTap: () {
          SoundService.hapticLight();
          _openTopic(topic.name, tasks);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isComplete
                  ? AppColors.success.withValues(alpha: 0.5)
                  : isStarted
                  ? accent.withValues(alpha: 0.38)
                  : AppThemeColors.border(context),
              width: isComplete ? 1.5 : 1,
            ),
            boxShadow: AppShadows.soft(context),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isComplete ? AppColors.success : accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : topic.icon,
                  color: isComplete ? Colors.white : Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Topic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTopic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (isComplete ? AppColors.success : accent)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isComplete ? AppColors.success : accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                      child: _noMotion
                          ? LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: AppThemeColors.borderLight(
                                context,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                isComplete ? AppColors.success : accent,
                              ),
                            )
                          : TweenAnimationBuilder<double>(
                              key: ValueKey(
                                'topic_${topic.name}_${progress.toStringAsFixed(3)}',
                              ),
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.easeOutCubic,
                              builder: (context, animatedProgress, _) {
                                return LinearProgressIndicator(
                                  value: animatedProgress,
                                  minHeight: 4,
                                  backgroundColor: AppThemeColors.borderLight(
                                    context,
                                  ),
                                  valueColor: AlwaysStoppedAnimation(
                                    isComplete ? AppColors.success : accent,
                                  ),
                                );
                              },
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
    );

    if (_noMotion) return card;

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: card),
    );
  }

  void _openTopic(String topicName, List<Task> tasks) {
    SoundService.playNavigate();
    SoundService.hapticMedium();
    context
        .push('/learn/intro', extra: {'name': topicName, 'tasks': tasks})
        .then((_) => _refresh());
  }
}

class _InfoRouteCard extends StatelessWidget {
  const _InfoRouteCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: accent.withValues(alpha: 0.32)),
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppThemeColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: accent, size: 22),
          ],
        ),
      ),
    );
  }
}

class _InstallStepsCard extends StatelessWidget {
  const _InstallStepsCard({
    required this.icon,
    required this.title,
    required this.steps,
  });

  final IconData icon;
  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.background(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppThemeColors.accentLight(context),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.28,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewStatData {
  const _OverviewStatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.stat});

  final _OverviewStatData stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: stat.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat.icon, color: stat.color, size: 18),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const noMotion = kIsWeb;
    final scale = _pressed ? 0.985 : (_hovered ? 1.01 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: noMotion
            ? widget.child
            : AnimatedScale(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                scale: scale,
                child: widget.child,
              ),
      ),
    );
  }
}
