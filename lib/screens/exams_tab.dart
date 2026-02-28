/// Exams Tab — Экзамены / Итоговые тесты
/// Минималистичный чистый дизайн

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../data/oge_ege_data.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import 'oge_ege_exam_screen.dart';

class ExamsTab extends StatefulWidget {
  const ExamsTab({super.key});

  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  @override
  Widget build(BuildContext context) {
    final grade = ProgressService.getCurrentGrade();
    final ogeVariants = getOgeVariants();
    final egeVariants = getEgeVariants();
    final showOge = grade == 9;
    final showEge = grade == 11;

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Icon(Icons.assignment_rounded, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Экзамен',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grade exam card
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, showOge || showEge ? 0 : 100),
                  sliver: SliverToBoxAdapter(
                    child: _buildExamCard(context, grade),
                  ),
                ),

                // ── ОГЭ (только для 9 класса) ───────────────────────────
                if (showOge) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      icon: Icons.school_rounded,
                      title: 'ОГЭ — Математика',
                      subtitle: '9 класс • ${ogeVariants.length} варианта • 235 мин',
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildVariantCard(ctx, ogeVariants[i],
                            color: const Color(0xFF7C3AED)),
                        childCount: ogeVariants.length,
                      ),
                    ),
                  ),
                ],

                // ── ЕГЭ (только для 11 класса) ──────────────────────────
                if (showEge) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      icon: Icons.workspace_premium_rounded,
                      title: 'ЕГЭ — Профильная математика',
                      subtitle: '11 класс • ${egeVariants.length} варианта • 235 мин',
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildVariantCard(ctx, egeVariants[i],
                            color: const Color(0xFFDC2626)),
                        childCount: egeVariants.length,
                      ),
                    ),
                  ),
                ],

                // ── Подсказка для других классов ────────────────────────
                if (!showOge && !showEge)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppThemeColors.surface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppThemeColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppThemeColors.textHint(context), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ОГЭ доступен для 9 класса,\nЕГЭ — для 11 класса.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppThemeColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemeColors.textHint(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(BuildContext context, ExamVariant variant, {required Color color}) {
    final isPassed = ProgressService.getBool('exam_${variant.id}_passed');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.mediumImpact();
            _startVariantExam(context, variant);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPassed
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppThemeColors.border(context),
                width: isPassed ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPassed ? Icons.check_circle_rounded : Icons.play_circle_rounded,
                    color: isPassed ? AppColors.success : color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${variant.tasks.length} заданий • ${variant.timeMinutes} мин',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeColors.textHint(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPassed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Сдан',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  )
                else
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
    );
  }

  void _startVariantExam(BuildContext context, ExamVariant variant) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OgeEgeExamScreen(variant: variant),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _buildExamCard(BuildContext context, int grade) {
    final allTasks = getTasksByGrade(grade);
    final topics = getTopicsInfoByGrade(grade);
    final totalSolved = ProgressService.getSolvedCountForGrade(
        grade, allTasks.map((t) => t.id).toList());
    final progress = allTasks.isNotEmpty
        ? (totalSolved / allTasks.length).clamp(0.0, 1.0)
        : 0.0;

    final examQuestions = _examQuestionCount(grade);
    final examTime = _examTimeMinutes(grade);

    final gradeNames = ['Первый', 'Второй', 'Третий', 'Четвёртый'];
    final isPassed = ProgressService.getBool('exam_grade_${grade}_passed');

    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: [
          // Grade header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$grade',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gradeNames[grade - 1]} класс',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Итоговый тест',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPassed)
                  Icon(Icons.verified_rounded,
                      color: Colors.white, size: 28),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(Icons.quiz_rounded, '$examQuestions', 'вопросов'),
                    _buildInfoItem(Icons.timer_rounded, '$examTime', 'минут'),
                    _buildInfoItem(Icons.category_rounded, '${topics.length}', 'тем'),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppThemeColors.borderLight(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Подготовка',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: progress >= 0.7
                                  ? AppColors.success
                                  : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppThemeColors.surface(context),
                          valueColor: AlwaysStoppedAnimation(
                            progress >= 0.7
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _startExam(context, grade, allTasks, examQuestions, examTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isPassed ? 'Пересдать' : 'Начать экзамен',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (isPassed) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Экзамен сдан',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppThemeColors.textHint(context),
          ),
        ),
      ],
    );
  }

  int _examQuestionCount(int grade) {
    switch (grade) {
      case 1: return 15;
      case 2: return 20;
      case 3: return 20;
      case 4: return 25;
      default: return 15;
    }
  }

  int _examTimeMinutes(int grade) {
    switch (grade) {
      case 1: return 15;
      case 2: return 20;
      case 3: return 25;
      case 4: return 30;
      default: return 20;
    }
  }

  void _startExam(BuildContext context, int grade, List<Task> allTasks,
      int count, int timeMinutes) {
    final rng = Random();
    final shuffled = List<Task>.from(allTasks)..shuffle(rng);
    final examTasks = shuffled.take(count).toList();

    context.push('/exam', extra: {
      'grade': grade,
      'tasks': examTasks,
      'timeMinutes': timeMinutes,
    });
  }
}

// ============================================================
// EXAM SCREEN
// ============================================================

class ExamScreen extends StatefulWidget {
  final int grade;
  final List<Task> tasks;
  final int timeMinutes;
  final String? variantId;

  const ExamScreen({
    super.key,
    required this.grade,
    required this.tasks,
    required this.timeMinutes,
    this.variantId,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _examFinished = false;
  final _textController = TextEditingController();
  bool _textIsNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeMinutes * 60;
    _textController.addListener(_onTextChanged);
    _startTimer();
  }

  void _onTextChanged() {
    final notEmpty = _textController.text.isNotEmpty;
    if (notEmpty != _textIsNotEmpty) {
      setState(() => _textIsNotEmpty = notEmpty);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_examFinished) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds <= 0 && !_examFinished) {
        _finishExam(); // fire-and-forget intentional: timer callback can't be async
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  Task get _currentTask => widget.tasks[_currentIndex];

  void _selectAnswer(String answer) {
    if (_showResult) return;

    HapticFeedback.lightImpact();

    final normalized = answer.trim().toLowerCase().replaceAll(',', '.').replaceAll(RegExp(r'\s+'), ' ');
    final correctNormalized = _currentTask.answer.trim().toLowerCase().replaceAll(',', '.').replaceAll(RegExp(r'\s+'), ' ');

    setState(() {
      _selectedAnswer = answer;
      _showResult = true;

      if (normalized == correctNormalized) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted && _showResult) {
        _nextQuestion();
      }
    });
  }

  void _checkTextAnswer() {
    if (_textController.text.isEmpty) return;
    _selectAnswer(_textController.text);
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < widget.tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _textController.clear();
        _textIsNotEmpty = false;
      });
    } else {
      await _finishExam();
    }
  }

  Future<void> _finishExam() async {
    _timer.cancel();
    setState(() {
      _examFinished = true;
    });

    final passed = (_correctCount / widget.tasks.length) >= 0.7;
    if (passed) {
      if (widget.variantId != null) {
        await ProgressService.setBool('exam_${widget.variantId}_passed', true);
      } else {
        await ProgressService.setBool('exam_grade_${widget.grade}_passed', true);
      }
    }

    _showResultsDialog();
  }

  void _showResultsDialog() {
    final percentage = ((_correctCount / widget.tasks.length) * 100).toInt();
    final passed = percentage >= 70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeColors.surface(ctx),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              size: 48,
              color: passed ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              passed ? 'Экзамен сдан!' : 'Попробуй ещё',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(ctx),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: passed ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, color: AppColors.success, size: 18),
                Text(' $_correctCount  ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.textPrimary(ctx),
                    )),
                Icon(Icons.close_rounded, color: AppColors.error, size: 18),
                Text(' $_wrongCount',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.textPrimary(ctx),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // close dialog
                  context.pop(); // go back from exam
                },
                child: const Text('Готово'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final h  = seconds ~/ 3600;
    final m  = (seconds % 3600) ~/ 60;
    final s  = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.tasks.length;
    final isLowTime = _remainingSeconds < 60;

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _showExitConfirmation,
                        icon: Icon(Icons.close_rounded,
                            color: AppThemeColors.textSecondary(context)),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_currentIndex + 1} / ${widget.tasks.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: AppThemeColors.borderLight(context),
                                valueColor: AlwaysStoppedAnimation(AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLowTime
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppThemeColors.borderLight(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: isLowTime
                                ? AppColors.error
                                : AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Question
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppThemeColors.surface(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppThemeColors.border(context)),
                          ),
                          child: Text(
                            _currentTask.question,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Answer section: options or text input
                        if (_currentTask.type == TaskType.multipleChoice)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: (_currentTask.options ?? []).map((option) {
                              final isSelected = _selectedAnswer == option;
                              final isCorrect = option == _currentTask.answer;

                              Color bgColor = AppThemeColors.surface(context);
                              Color borderColor = AppThemeColors.border(context);

                              if (_showResult) {
                                if (isCorrect) {
                                  bgColor = AppColors.success.withValues(alpha: 0.15);
                                  borderColor = AppColors.success;
                                } else if (isSelected) {
                                  bgColor = AppColors.error.withValues(alpha: 0.15);
                                  borderColor = AppColors.error;
                                }
                              }

                              return Material(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => _selectAnswer(option),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                  constraints: const BoxConstraints(minWidth: 70),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: borderColor, width: 2),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppThemeColors.textPrimary(context),
                                    ),
                                  ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else ...[
                          // Text input for textInput tasks
                          _buildExamTextInput(),
                          const SizedBox(height: 12),
                          if (!_showResult)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _textIsNotEmpty ? _checkTextAnswer : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _textIsNotEmpty
                                      ? AppColors.accent
                                      : AppThemeColors.borderLight(context),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Проверить',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _textIsNotEmpty
                                        ? Colors.white
                                        : AppThemeColors.textHint(context),
                                  ),
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 32),

                        // Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                color: AppColors.success, size: 18),
                            Text(
                              ' $_correctCount  ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.textPrimary(context),
                              ),
                            ),
                            Icon(Icons.close_rounded,
                                color: AppColors.error, size: 18),
                            Text(
                              ' $_wrongCount',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppThemeColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamTextInput() {
    Color borderColor = AppThemeColors.border(context);
    Color bgColor = AppThemeColors.surface(context);

    if (_showResult) {
      final normalized = (_selectedAnswer ?? '').trim().toLowerCase().replaceAll(',', '.').replaceAll(RegExp(r'\s+'), ' ');
      final correctNormalized = _currentTask.answer.trim().toLowerCase().replaceAll(',', '.').replaceAll(RegExp(r'\s+'), ' ');
      final isCorrect = normalized == correctNormalized;
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      bgColor = isCorrect
          ? AppColors.success.withValues(alpha: 0.15)
          : AppColors.error.withValues(alpha: 0.15);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: TextField(
        controller: _textController,
        enabled: !_showResult,
        style: TextStyle(
          fontSize: 18,
          color: AppThemeColors.textPrimary(context),
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Введи ответ',
          hintStyle: TextStyle(color: AppThemeColors.textHint(context)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        onSubmitted: (_) => _checkTextAnswer(),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeColors.surface(ctx),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Выйти?',
          style: TextStyle(color: AppThemeColors.textPrimary(ctx)),
        ),
        content: Text(
          'Прогресс будет потерян',
          style: TextStyle(color: AppThemeColors.textSecondary(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              context.pop(); // go back from exam
            },
            child: Text('Выйти', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
