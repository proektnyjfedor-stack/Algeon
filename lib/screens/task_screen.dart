/// Task Screen — экран решения задач
///
/// Минималистичный игровой стиль Algeon
/// Чистый дизайн, мягкие закругления

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/achievements_service.dart';
import '../services/ai_service.dart';
import '../data/tasks_data.dart';
import '../widgets/math_text.dart';
import '../widgets/math_keyboard.dart';

class TaskScreen extends StatefulWidget {
  final List<Task> tasks;
  final String topicName;

  const TaskScreen({
    super.key,
    required this.tasks,
    required this.topicName,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _selectedOption;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isChecked = false;
  bool _isCorrect = false;
  int _explanationStep = 0;
  int _wrongAttemptsOnCurrentTask = 0; // счётчик ошибок на текущей задаче

  int _correctCount = 0;
  int _wrongCount = 0;
  int _skippedCount = 0;
  final List<Task> _wrongTasks = [];

  final Stopwatch _stopwatch = Stopwatch();

  bool _hintRevealed = false;
  // tracks if hint was used this task (reserved for future scoring)
  // ignore: unused_field
  bool _hintUsed = false;
  bool _textIsNotEmpty = false;
  bool _aiHintLoading = false;
  String? _aiHintText;

  late AnimationController _cardAnimController;
  late Animation<double> _cardScaleAnim;

  Task get _task => widget.tasks[_currentIndex];
  bool get _hasExplanation => _task.explanationSteps.isNotEmpty;
  double get _progress => (_currentIndex + 1) / widget.tasks.length;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _textController.addListener(_onTextChanged);

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardScaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutBack),
    );
    _cardAnimController.forward();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final notEmpty = _textController.text.isNotEmpty;
    if (notEmpty != _textIsNotEmpty) {
      setState(() => _textIsNotEmpty = notEmpty);
    }
  }

  void _reset() {
    _selectedOption = null;
    _textController.clear();
    _isChecked = false;
    _isCorrect = false;
    _explanationStep = 0;
    _hintRevealed = false;
    _hintUsed = false;
    _textIsNotEmpty = false;
    _aiHintLoading = false;
    _aiHintText = null;
    _wrongAttemptsOnCurrentTask = 0;
    _cardAnimController.forward(from: 0);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      _showExitConfirmation();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_isChecked) {
        if (_isCorrect ||
            !_hasExplanation ||
            _explanationStep >= _task.explanationSteps.length - 1) {
          _goNext();
        } else {
          setState(() => _explanationStep++);
        }
        return KeyEventResult.handled;
      } else if (_task.type == TaskType.textInput && _textIsNotEmpty) {
        _checkAnswer();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Физическая клавиатура для textInput задач
    if (!_isChecked && _task.type == TaskType.textInput) {
      final digits = {
        LogicalKeyboardKey.digit0: '0', LogicalKeyboardKey.numpad0: '0',
        LogicalKeyboardKey.digit1: '1', LogicalKeyboardKey.numpad1: '1',
        LogicalKeyboardKey.digit2: '2', LogicalKeyboardKey.numpad2: '2',
        LogicalKeyboardKey.digit3: '3', LogicalKeyboardKey.numpad3: '3',
        LogicalKeyboardKey.digit4: '4', LogicalKeyboardKey.numpad4: '4',
        LogicalKeyboardKey.digit5: '5', LogicalKeyboardKey.numpad5: '5',
        LogicalKeyboardKey.digit6: '6', LogicalKeyboardKey.numpad6: '6',
        LogicalKeyboardKey.digit7: '7', LogicalKeyboardKey.numpad7: '7',
        LogicalKeyboardKey.digit8: '8', LogicalKeyboardKey.numpad8: '8',
        LogicalKeyboardKey.digit9: '9', LogicalKeyboardKey.numpad9: '9',
      };

      if (digits.containsKey(key)) {
        _textController.text += digits[key]!;
        _textController.selection =
            TextSelection.collapsed(offset: _textController.text.length);
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.backspace) {
        final t = _textController.text;
        if (t.isNotEmpty) {
          _textController.text = t.substring(0, t.length - 1);
          _textController.selection =
              TextSelection.collapsed(offset: _textController.text.length);
        }
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.period ||
          key == LogicalKeyboardKey.numpadDecimal) {
        if (!_textController.text.contains('.')) {
          _textController.text += '.';
          _textController.selection =
              TextSelection.collapsed(offset: _textController.text.length);
        }
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.minus ||
          key == LogicalKeyboardKey.numpadSubtract) {
        final t = _textController.text;
        if (t.startsWith('-')) {
          _textController.text = t.substring(1);
        } else {
          _textController.text = '-$t';
        }
        _textController.selection =
            TextSelection.collapsed(offset: _textController.text.length);
        return KeyEventResult.handled;
      }
    }

    // Быстрый выбор варианта цифрами для multipleChoice
    if (!_isChecked && _task.type == TaskType.multipleChoice) {
      final options = _task.options ?? [];
      int? index;
      if (key == LogicalKeyboardKey.digit1 ||
          key == LogicalKeyboardKey.numpad1) index = 0;
      if (key == LogicalKeyboardKey.digit2 ||
          key == LogicalKeyboardKey.numpad2) index = 1;
      if (key == LogicalKeyboardKey.digit3 ||
          key == LogicalKeyboardKey.numpad3) index = 2;
      if (key == LogicalKeyboardKey.digit4 ||
          key == LogicalKeyboardKey.numpad4) index = 3;

      if (index != null && index < options.length) {
        setState(() => _selectedOption = options[index!]);
        _checkAnswer();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppThemeColors.background(context),
      body: Focus(
        focusNode: _focusNode,
        autofocus: false,
        onKeyEvent: _onKeyEvent,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _isChecked && !_isCorrect && _hasExplanation
                        ? _buildExplanation()
                        : _buildTaskCard(),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Close
          _buildIconButton(
            icon: Icons.close_rounded,
            onTap: _showExitConfirmation,
          ),
          const SizedBox(width: 16),
          // Progress indicator
          Expanded(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppThemeColors.border(context),
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_currentIndex + 1} / ${widget.tasks.length}',
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
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          color: color ?? AppThemeColors.textSecondary(context),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildTaskCard() {
    return ScaleTransition(
      scale: _cardScaleAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Topic label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppThemeColors.accentLight(context),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Text(
                widget.topicName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Question card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft(context),
              ),
              child: Column(
                children: [
                  MathText(
                    _task.question,
                    style: TextStyle(
                      fontSize: _task.type == TaskType.multipleChoice ? 36 : 20,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.textPrimary(context),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!_isChecked) ...[
                    const SizedBox(height: 20),
                    _buildHintSection(),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Answer section
            if (_task.type == TaskType.multipleChoice)
              _buildOptions()
            else
              _buildTextInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHintSection() {
    // Кнопка «Подсказка» — ещё не нажали
    if (!_hintRevealed) {
      return TextButton.icon(
        onPressed: () async {
          setState(() {
            _hintRevealed = true;
            _hintUsed = true;
          });
          // Если статической подсказки нет — запрашиваем у ИИ
          if (_task.hint == null) {
            setState(() => _aiHintLoading = true);
            final grade = ProgressService.getCurrentGrade();
            final hint = await AiService.generateHint(
              question: _task.question,
              grade: grade,
            );
            if (mounted) {
              setState(() {
                _aiHintText = hint;
                _aiHintLoading = false;
              });
            }
          }
        },
        icon: Icon(Icons.auto_awesome_rounded,
            size: 18, color: AppColors.gold),
        label: Text(
          'Подсказка от ИИ',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w500),
        ),
      );
    }

    // Загрузка ИИ-подсказки
    if (_aiHintLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppThemeColors.orangeLight(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ИИ готовит подсказку...',
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    // Показываем подсказку (статическую или от ИИ)
    final hintText = _task.hint ?? _aiHintText ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.orangeLight(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hintText,
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.textPrimary(context),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final options = _task.options ?? [];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = _selectedOption == option;
        final isCorrectOption = option == _task.answer;

        Color bgColor = AppThemeColors.surface(context);
        Color borderColor = AppThemeColors.border(context);
        Color textColor = AppThemeColors.textPrimary(context);

        if (_isChecked) {
          if (isCorrectOption) {
            bgColor = AppThemeColors.successLight(context);
            borderColor = AppColors.success;
            textColor = AppThemeColors.textPrimary(context);
          } else if (isSelected) {
            bgColor = AppThemeColors.errorLight(context);
            borderColor = AppColors.error;
            textColor = AppThemeColors.textPrimary(context);
          }
        } else if (isSelected) {
          bgColor = AppThemeColors.accentLight(context);
          borderColor = AppColors.accent;
          textColor = AppThemeColors.textPrimary(context);
        }

        return GestureDetector(
          onTap: _isChecked
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedOption = option);
                  _checkAnswer();
                },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minWidth: 80, minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput() {
    Color borderColor = AppThemeColors.border(context);
    Color bgColor = AppThemeColors.surface(context);

    if (_isChecked) {
      borderColor = _isCorrect ? AppColors.success : AppColors.error;
      bgColor = _isCorrect
          ? AppThemeColors.successLight(context)
          : AppThemeColors.errorLight(context);
    }

    final text = _textController.text;
    final isEmpty = text.isEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Text(
        isEmpty ? 'Введи ответ' : text,
        style: TextStyle(
          fontSize: 30,
          fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w700,
          color: isEmpty
              ? AppThemeColors.textHint(context)
              : AppThemeColors.textPrimary(context),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildExplanation() {
    final steps = _task.explanationSteps;
    final visible = steps.take(_explanationStep + 1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Разберём вместе',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: MathText(
              _task.question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...visible.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppThemeColors.accentLight(context),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppThemeColors.surface(context),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppThemeColors.textPrimary(context),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          if (_explanationStep < steps.length - 1)
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _explanationStep++),
                icon: Icon(Icons.arrow_downward_rounded, size: 18),
                label: const Text('Следующий шаг'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Математическая клавиатура для textInput (пока не проверено)
            if (!_isChecked && _task.type == TaskType.textInput) ...[
              MathKeyboard(controller: _textController),
              const SizedBox(height: 12),
            ],

            // Кнопка действия
            if (_isChecked && (_isCorrect || !_hasExplanation))
              _buildActionButton(
                label: _currentIndex < widget.tasks.length - 1
                    ? 'Продолжить'
                    : 'Завершить',
                color: _isCorrect ? AppColors.success : AppColors.accent,
                onTap: _goNext,
              )
            else if (_isChecked && _hasExplanation)
              _buildActionButton(
                label: _explanationStep < _task.explanationSteps.length - 1
                    ? 'Далее'
                    : 'Понятно',
                color: AppColors.accent,
                onTap: () {
                  if (_explanationStep < _task.explanationSteps.length - 1) {
                    setState(() => _explanationStep++);
                  } else {
                    _goNext();
                  }
                },
              )
            else if (!_isChecked && _task.type == TaskType.textInput)
              _buildActionButton(
                label: 'Проверить',
                color: _textIsNotEmpty
                    ? AppColors.accent
                    : AppThemeColors.disabled(context),
                onTap: _textIsNotEmpty ? _checkAnswer : null,
              ),
            if (!_isChecked) ...[
              const SizedBox(height: 8),
              // После 2 ошибок на одной задаче — показываем «Не знаю»
              if (_wrongAttemptsOnCurrentTask >= 2)
                _buildDontKnowButton()
              else
                _buildSkipButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _skipTask,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppThemeColors.border(context),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            'Пропустить',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDontKnowButton() {
    return GestureDetector(
      onTap: _revealAnswer,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppThemeColors.errorLight(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline_rounded,
                size: 20, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Не знаю — покажи ответ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAnswer() async {
    String answer;
    if (_task.type == TaskType.multipleChoice) {
      if (_selectedOption == null) return;
      answer = _selectedOption!;
    } else {
      if (_textController.text.isEmpty) return;
      answer = _textController.text;
    }

    final correct = _task.checkAnswer(answer);

    setState(() {
      _isChecked = true;
      _isCorrect = correct;
    });

    if (correct) {
      _correctCount++;
      await ProgressService.markSolved(_task.id);
      SoundService.playCorrect();
    } else {
      _wrongCount++;
      _wrongAttemptsOnCurrentTask++;
      _wrongTasks.add(_task);
      SoundService.playWrong();
    }
  }

  /// «Не знаю» — раскрываем правильный ответ без перехода к следующей задаче
  void _revealAnswer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isChecked = true;
      _isCorrect = false;
      _skippedCount++;
      if (!_wrongTasks.contains(_task)) {
        _wrongCount++;
        _wrongTasks.add(_task);
      }
      // Для textInput показываем правильный ответ в поле
      if (_task.type == TaskType.textInput) {
        _textController.text = _task.answer;
        _textIsNotEmpty = true;
      }
      // Для multipleChoice убираем выделение — только зелёный правильный ответ
      _selectedOption = null;
    });
    SoundService.playWrong();
  }

  void _skipTask() {
    setState(() {
      _skippedCount++;
      _wrongCount++;
      _wrongTasks.add(_task);
    });
    SoundService.playWrong();

    if (_currentIndex < widget.tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _reset();
      });
    } else {
      _showSummary();
    }
  }

  void _goNext() {
    if (_currentIndex < widget.tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _reset();
      });
    } else {
      _showSummary();
    }
  }

  void _showSummary() async {
    _stopwatch.stop();

    final totalSolved = ProgressService.getTotalSolved();
    final streak = ProgressService.getStreakDays();
    final accuracy = ProgressService.getAccuracy();
    final totalAttempts = ProgressService.getTotalAttempts();

    final newAchievements = <Achievement>[];

    newAchievements
        .addAll(await AchievementsService.checkTaskAchievements(totalSolved));
    newAchievements
        .addAll(await AchievementsService.checkStreakAchievements(streak));
    newAchievements.addAll(await AchievementsService.checkAccuracyAchievements(
        accuracy, totalAttempts));

    final perfect = await AchievementsService.checkPerfectSession(
        _correctCount, widget.tasks.length);
    if (perfect != null) newAchievements.add(perfect);

    final grade = ProgressService.getCurrentGrade();
    final gradeTasks = getTasksByGrade(grade);
    final gradeSolved = ProgressService.getSolvedCountForGrade(
        grade, gradeTasks.map((t) => t.id).toList());
    final gradeProgress =
        gradeTasks.isNotEmpty ? gradeSolved / gradeTasks.length : 0.0;
    final gradeAch =
        await AchievementsService.checkGradeComplete(grade, gradeProgress);
    if (gradeAch != null) newAchievements.add(gradeAch);

    if (!mounted) return;

    context.pushReplacement(
      '/summary',
      extra: <String, dynamic>{
        'topicName': widget.topicName,
        'totalCount': widget.tasks.length,
        'correctCount': _correctCount,
        'wrongCount': _wrongCount,
        'skippedCount': _skippedCount,
        'wrongTasks': _wrongTasks,
        'elapsedTime': _stopwatch.elapsed,
        'newAchievements': newAchievements,
      },
    );
  }

  void _showExitConfirmation() {
    if (_currentIndex == 0 && !_isChecked) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppThemeColors.surface(context),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Выйти?', style: TextStyle(color: AppThemeColors.textPrimary(context))),
        content: Text('Твой прогресс будет сохранён.', style: TextStyle(color: AppThemeColors.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Остаться'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) context.pop();
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
