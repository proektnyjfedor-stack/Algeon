/// Summary Screen — итоги сессии
/// Величественный дизайн Algeon

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import '../services/achievements_service.dart';
import '../services/ai_service.dart';

class SummaryScreen extends StatefulWidget {
  final String topicName;
  final int totalCount;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final List<Task> wrongTasks;
  final Duration? elapsedTime;
  final List<Achievement> newAchievements;

  const SummaryScreen({
    super.key,
    required this.topicName,
    required this.totalCount,
    required this.correctCount,
    required this.wrongCount,
    this.skippedCount = 0,
    required this.wrongTasks,
    this.elapsedTime,
    this.newAchievements = const [],
  });

  factory SummaryScreen.fromMap(Map<String, dynamic> map) {
    return SummaryScreen(
      topicName: map['topicName'] as String? ?? '',
      totalCount: map['totalCount'] as int? ?? 0,
      correctCount: map['correctCount'] as int? ?? 0,
      wrongCount: map['wrongCount'] as int? ?? 0,
      skippedCount: map['skippedCount'] as int? ?? 0,
      wrongTasks: (map['wrongTasks'] as List?)?.cast<Task>() ?? [],
      elapsedTime: map['elapsedTime'] as Duration?,
      newAchievements:
          (map['newAchievements'] as List?)?.cast<Achievement>() ?? [],
    );
  }

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  bool _aiAnalysisLoading = false;
  String? _aiAnalysisText;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  double get _successRate =>
      widget.totalCount > 0 ? widget.correctCount / widget.totalCount : 0;

  bool get _isPerfect => _successRate >= 1.0;
  bool get _isGood => _successRate >= 0.7;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _getTitle() {
    if (_successRate >= 1.0) return 'Превосходно!';
    if (_successRate >= 0.8) return 'Отличная работа!';
    if (_successRate >= 0.6) return 'Хороший результат!';
    if (_successRate >= 0.4) return 'Неплохо!';
    return 'Продолжай учиться!';
  }

  Color get _primaryColor {
    if (_isPerfect) return AppColors.gold;
    if (_isGood) return AppColors.success;
    return AppColors.accent;
  }

  IconData get _primaryIcon {
    if (_isPerfect) return Icons.star_rounded;
    if (_isGood) return Icons.check_circle_rounded;
    return Icons.trending_up_rounded;
  }

  Future<void> _requestAnalysis() async {
    setState(() => _aiAnalysisLoading = true);
    final grade = ProgressService.getCurrentGrade();
    final analysis = await AiService.analyzeErrors(
      wrongTasks: widget.wrongTasks,
      grade: grade,
    );
    if (mounted) {
      setState(() {
        _aiAnalysisText = analysis;
        _aiAnalysisLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildResultHeader()),
                  SliverToBoxAdapter(child: _buildScoreCard()),
                  SliverToBoxAdapter(child: _buildDetailsRow()),
                  if (widget.newAchievements.isNotEmpty)
                    SliverToBoxAdapter(child: _buildAchievementsCard()),
                  if (widget.wrongTasks.isNotEmpty)
                    SliverToBoxAdapter(child: _buildAiCard()),
                  SliverToBoxAdapter(child: _buildActions()),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      width: double.infinity,
      color: _primaryColor,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/learn');
              },
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),

          const SizedBox(height: 4),

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_primaryIcon, color: Colors.white, size: 44),
          ),

          const SizedBox(height: 16),

          Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.topicName,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppThemeColors.border(context)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(_successRate * 100).round()}',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: _primaryColor,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _successRate,
                minHeight: 10,
                backgroundColor: AppThemeColors.borderLight(context),
                valueColor: AlwaysStoppedAnimation(_primaryColor),
              ),
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                _buildScoreStat('${widget.correctCount}', 'Верно', AppColors.success),
                _buildDividerV(),
                _buildScoreStat('${widget.wrongCount}', 'Ошибок', AppColors.error),
                _buildDividerV(),
                _buildScoreStat('${widget.totalCount}', 'Задач', AppColors.accent),
                if (widget.elapsedTime != null) ...[
                  _buildDividerV(),
                  _buildScoreStat(
                    _formatDuration(widget.elapsedTime!),
                    'Время',
                    AppThemeColors.textSecondary(context),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerV() {
    return Container(
      width: 1,
      height: 40,
      color: AppThemeColors.border(context),
    );
  }

  Widget _buildScoreStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow() {
    final xpEarned = widget.correctCount * 10;
    final streak = ProgressService.getStreakDays();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildPillCard(
            icon: Icons.bolt_rounded,
            value: '+$xpEarned XP',
            color: AppColors.accent,
            bg: AppThemeColors.accentLight(context),
          ),
          const SizedBox(width: 10),
          _buildPillCard(
            icon: Icons.local_fire_department_rounded,
            value: '$streak дней',
            color: AppColors.orange,
            bg: AppColors.orange.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildPillCard({
    required IconData icon,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Новые достижения!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...widget.newAchievements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppThemeColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              a.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppThemeColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCard() {
    if (_aiAnalysisText == null && !_aiAnalysisLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _requestAnalysis();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppThemeColors.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemeColors.accentLight(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Разбор ошибок с ИИ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Получи персональные подсказки',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppThemeColors.textHint(context), size: 22),
              ],
            ),
          ),
        ),
      );
    }

    if (_aiAnalysisLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeColors.accentLight(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ИИ анализирует ошибки...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemeColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeColors.accentLight(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Анализ от ИИ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _aiAnalysisText!,
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.textPrimary(context),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          if (widget.wrongTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _retryWrong(context),
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: Text(
                    'Повторить ошибки (${widget.wrongTasks.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 1.5),
                    foregroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.go('/learn');
              },
              icon: const Icon(Icons.home_rounded, size: 20),
              label: const Text(
                'На главную',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isGood ? AppColors.success : AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _retryWrong(BuildContext context) {
    context.pushReplacement(
      '/learn/topic',
      extra: {'name': 'Работа над ошибками', 'tasks': widget.wrongTasks},
    );
  }
}
