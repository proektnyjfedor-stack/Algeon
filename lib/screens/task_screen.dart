/// Task Screen — экран решения задач
///
/// Минималистичный игровой стиль Algeon
/// Чистый дизайн, мягкие закругления
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/achievements_service.dart';
import '../services/language_service.dart';
import '../services/localized_text_service.dart';
import '../data/tasks_data.dart';
import '../data/topic_titles_en.dart';
import '../widgets/math_text.dart';
import '../widgets/math_keyboard.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
    required this.tasks,
    required this.topicName,
  });
  final List<Task> tasks;
  final String topicName;

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
  Color? _answerFlashColor;
  bool _showMathKeyboard = false;
  final Map<String, List<String>> _optionsCache = <String, List<String>>{};

  late AnimationController _cardAnimController;
  late Animation<double> _cardScaleAnim;

  Task get _task => widget.tasks[_currentIndex];
  List<String> get _explanationSteps => _task.explanationSteps.isNotEmpty
      ? _task.explanationSteps
      : _fallbackStepsFor(_task);
  bool get _hasExplanation => _explanationSteps.isNotEmpty;
  double get _progress => (_currentIndex + 1) / widget.tasks.length;
  bool get _isInequalityTask {
    final q = _task.question;
    final a = _task.answer;
    return q.contains('>') ||
        q.contains('<') ||
        q.contains('≥') ||
        q.contains('≤') ||
        a.contains('>=') ||
        a.contains('<=') ||
        a.contains('≥') ||
        a.contains('≤');
  }

  bool get _isLandscape {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  bool get _isLowPerfMobileWeb {
    final size = MediaQuery.of(context).size;
    return kIsWeb && size.width < 700;
  }

  bool get _noMotion => kIsWeb;

  int get _keyboardInitialTab {
    final combined = '${_task.question} ${_task.answer}'.toLowerCase();
    final hasIneq = _isInequalityTask ||
        combined.contains('>=') ||
        combined.contains('<=') ||
        combined.contains('>') ||
        combined.contains('<');
    if (hasIneq) return 2;
    final hasVars = combined.contains('x') ||
        combined.contains('y') ||
        combined.contains('z') ||
        combined.contains('π') ||
        combined.contains('sqrt') ||
        combined.contains('корень');
    if (hasVars) return 1;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _textController.addListener(_onTextChanged);

    _cardAnimController = AnimationController(
      vsync: this,
      duration: _noMotion
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 300),
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
    // Для текстовых задач поле и превью рисуются через Text(controller.text), без
    // TextField — поэтому нужен setState на каждое изменение, иначе после 1-го символа
    // экран не перерисовывается (раньше setState был только при смене пусто↔не пусто).
    if (_task.type == TaskType.textInput) {
      setState(() => _textIsNotEmpty = notEmpty);
    } else if (notEmpty != _textIsNotEmpty) {
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
    _wrongAttemptsOnCurrentTask = 0;
    _answerFlashColor = null;
    _showMathKeyboard = false;
    _cardAnimController.forward(from: 0);
  }

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
            _explanationStep >= _explanationSteps.length - 1) {
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
        LogicalKeyboardKey.digit0: '0',
        LogicalKeyboardKey.numpad0: '0',
        LogicalKeyboardKey.digit1: '1',
        LogicalKeyboardKey.numpad1: '1',
        LogicalKeyboardKey.digit2: '2',
        LogicalKeyboardKey.numpad2: '2',
        LogicalKeyboardKey.digit3: '3',
        LogicalKeyboardKey.numpad3: '3',
        LogicalKeyboardKey.digit4: '4',
        LogicalKeyboardKey.numpad4: '4',
        LogicalKeyboardKey.digit5: '5',
        LogicalKeyboardKey.numpad5: '5',
        LogicalKeyboardKey.digit6: '6',
        LogicalKeyboardKey.numpad6: '6',
        LogicalKeyboardKey.digit7: '7',
        LogicalKeyboardKey.numpad7: '7',
        LogicalKeyboardKey.digit8: '8',
        LogicalKeyboardKey.numpad8: '8',
        LogicalKeyboardKey.digit9: '9',
        LogicalKeyboardKey.numpad9: '9',
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

      if ((key == LogicalKeyboardKey.period &&
              !HardwareKeyboard.instance.isShiftPressed) ||
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

      if (key == LogicalKeyboardKey.equal ||
          key == LogicalKeyboardKey.numpadEqual) {
        _textController.text += '=';
        _textController.selection =
            TextSelection.collapsed(offset: _textController.text.length);
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.comma) {
        _textController.text += '<';
        _textController.selection =
            TextSelection.collapsed(offset: _textController.text.length);
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.period) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          _textController.text += '>';
          _textController.selection =
              TextSelection.collapsed(offset: _textController.text.length);
          return KeyEventResult.handled;
        }
      }
    }

    // Быстрый выбор варианта цифрами для multipleChoice
    if (!_isChecked && _task.type == TaskType.multipleChoice) {
      final options = _task.options ?? [];
      int? index;
      if (key == LogicalKeyboardKey.digit1 ||
          key == LogicalKeyboardKey.numpad1) {
        index = 0;
      }
      if (key == LogicalKeyboardKey.digit2 ||
          key == LogicalKeyboardKey.numpad2) {
        index = 1;
      }
      if (key == LogicalKeyboardKey.digit3 ||
          key == LogicalKeyboardKey.numpad3) {
        index = 2;
      }
      if (key == LogicalKeyboardKey.digit4 ||
          key == LogicalKeyboardKey.numpad4) {
        index = 3;
      }

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
    final keyboardFocusMode =
        _showMathKeyboard && !_isChecked && _task.type == TaskType.textInput;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppThemeColors.background(context),
      body: Focus(
        focusNode: _focusNode,
        autofocus: false,
        onKeyEvent: _onKeyEvent,
        child: GestureDetector(
          onTap: () {
            if (_showMathKeyboard) {
              setState(() => _showMathKeyboard = false);
            }
          },
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: keyboardFocusMode
                          ? _buildKeyboardFocusCard()
                          : (_isChecked && !_isCorrect && _hasExplanation
                              ? _buildExplanation()
                              : _buildTaskCard()),
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final landscape = _isLandscape;
    return Container(
      margin:
          EdgeInsets.fromLTRB(12, landscape ? 6 : 10, 12, landscape ? 4 : 8),
      padding:
          EdgeInsets.fromLTRB(12, landscape ? 8 : 10, 12, landscape ? 8 : 10),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          // Close
          _buildIconButton(
            icon: Icons.close_rounded,
            onTap: _showExitConfirmation,
          ),
          SizedBox(width: landscape ? 10 : 16),
          // Progress indicator
          Expanded(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: _noMotion
                      ? LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: AppThemeColors.border(context),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.accent),
                          minHeight: 8,
                        )
                      : TweenAnimationBuilder<double>(
                          key: ValueKey(
                              'task_progress_${_progress.toStringAsFixed(3)}'),
                          tween: Tween(begin: 0, end: _progress),
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedProgress, _) {
                            return LinearProgressIndicator(
                              value: animatedProgress,
                              backgroundColor: AppThemeColors.border(context),
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.accent),
                              minHeight: 8,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_currentIndex + 1} / ${widget.tasks.length}',
                  style: TextStyle(
                    fontSize: landscape ? 12 : 13,
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
    final landscape = _isLandscape;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: landscape ? 40 : 44,
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppThemeColors.border(context)),
        ),
        child: Icon(
          icon,
          color: color ?? AppThemeColors.textSecondary(context),
          size: landscape ? 20 : 22,
        ),
      ),
    );
  }

  Widget _buildTaskCard() {
    final t = context.watch<LanguageService>().t;
    final isEnglish = context.watch<LanguageService>().isEnglish;
    final landscape = _isLandscape;
    final lowPerf = _isLowPerfMobileWeb;
    final content = NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(landscape ? 14 : 24),
        child: Column(
          children: [
            // Topic label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppThemeColors.accentLight(context),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.32),
                ),
              ),
              child: Text(
                isEnglish ? topicTitleEn(widget.topicName) : widget.topicName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
            SizedBox(height: landscape ? 14 : 32),

            // Question card
            AnimatedSwitcher(
              duration: _noMotion
                  ? Duration.zero
                  : Duration(milliseconds: lowPerf ? 140 : 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: AnimatedContainer(
                duration: _noMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                key: ValueKey('${_task.id}_${_isChecked}_$_explanationStep'),
                width: double.infinity,
                padding: EdgeInsets.all(landscape ? 18 : 26),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: _answerFlashColor != null
                        ? _answerFlashColor!.withValues(alpha: 0.9)
                        : AppThemeColors.border(context),
                    width: _answerFlashColor == null ? 1 : 2,
                  ),
                  boxShadow: lowPerf ? null : AppShadows.soft(context),
                ),
                child: Column(
                  children: [
                    _buildQuestionPresentation(
                      _localizedDynamicText(_clarifiedQuestion(_task)),
                      fontSize: _task.type == TaskType.multipleChoice
                          ? (landscape ? 28 : 36)
                          : (landscape ? 18 : 20),
                    ),
                    if (!_isChecked) ...[
                      const SizedBox(height: 20),
                      _buildHintSection(),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: landscape ? 14 : 28),

            // Answer section
            if (_task.type == TaskType.multipleChoice)
              _buildOptions()
            else
              Column(
                children: [
                  if (!(_showMathKeyboard && !_isChecked)) _buildTextInput(),
                  if (_isInequalityTask) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppThemeColors.accentLight(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        t('task.inequalityHint'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );

    if (_noMotion) return content;
    return ScaleTransition(scale: _cardScaleAnim, child: content);
  }

  Widget _buildHintSection() {
    final t = context.watch<LanguageService>().t;
    if (_task.hint == null || _task.hint!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Кнопка «Подсказка» — ещё не нажали
    if (!_hintRevealed) {
      return TextButton.icon(
        onPressed: () {
          setState(() {
            _hintRevealed = true;
            _hintUsed = true;
          });
        },
        icon: const Icon(Icons.lightbulb_outline_rounded,
            size: 18, color: AppColors.gold),
        label: Text(
          t('task.showHint'),
          style: const TextStyle(
              color: AppColors.gold, fontWeight: FontWeight.w500),
        ),
      );
    }

    final hintText = _task.hint!.trim();
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
          const Icon(Icons.lightbulb_outline_rounded,
              size: 20, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _localizedDynamicText(hintText),
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
    final landscape = _isLandscape;
    final lowPerf = _isLowPerfMobileWeb;
    final options = _optionsForCurrentTask();

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
                  SoundService.hapticLight();
                  setState(() => _selectedOption = option);
                  _checkAnswer();
                },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration:
                _noMotion ? Duration.zero : const Duration(milliseconds: 200),
            constraints:
                BoxConstraints(minWidth: 80, minHeight: landscape ? 48 : 56),
            padding: EdgeInsets.symmetric(
                horizontal: landscape ? 16 : 20, vertical: landscape ? 10 : 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor, width: 1.8),
              boxShadow: lowPerf
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                _localizedDynamicText(option),
                style: TextStyle(
                  fontSize: landscape ? 16 : 17,
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

  List<String> _optionsForCurrentTask() {
    final task = _task;
    final original = task.options;
    if (original == null) return const <String>[];
    if (original.length <= 1) return List<String>.from(original);

    final cached = _optionsCache[task.id];
    if (cached != null) return cached;

    final shuffled = List<String>.from(original);
    final random = Random(task.id.hashCode);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = tmp;
    }

    _optionsCache[task.id] = shuffled;
    return shuffled;
  }

  Widget _buildTextInput() {
    final t = context.watch<LanguageService>().t;
    final landscape = _isLandscape;
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

    return GestureDetector(
      onTap: _isChecked ? null : () => setState(() => _showMathKeyboard = true),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: landscape ? 18 : 24, vertical: landscape ? 14 : 22),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Text(
          isEmpty ? t('task.enterAnswer') : text,
          style: TextStyle(
            fontSize: landscape ? 24 : 30,
            fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w700,
            color: isEmpty
                ? AppThemeColors.textHint(context)
                : AppThemeColors.textPrimary(context),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    final t = context.watch<LanguageService>().t;
    final steps = _explanationSteps;
    final visible = steps.take(_explanationStep + 1).toList();

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return true;
      },
      child: SingleChildScrollView(
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
                  const Icon(Icons.school_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    t('task.explainTogether'),
                    style: const TextStyle(
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
              child: _buildQuestionPresentation(
                _localizedDynamicText(_clarifiedQuestion(_task)),
                fontSize: 18,
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
                            style: const TextStyle(
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
                            _localizedDynamicText(e.value),
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
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  label: Text(t('task.nextStep')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final t = context.watch<LanguageService>().t;
    final landscape = _isLandscape;
    final keyboardMode =
        _showMathKeyboard && !_isChecked && _task.type == TaskType.textInput;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        keyboardMode ? (landscape ? 2 : 4) : (landscape ? 10 : 16),
        16,
        keyboardMode ? (landscape ? 4 : 8) : (landscape ? 10 : 20),
      ),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        border: Border(
          top: BorderSide(color: AppThemeColors.border(context)),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (keyboardMode) ...[
              _buildKeyboardInputPreview(),
              SizedBox(height: landscape ? 2 : 4),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => setState(() => _showMathKeyboard = false),
                  icon: const Icon(Icons.keyboard_hide_rounded, size: 20),
                  tooltip: t('task.hideKeyboard'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              MathKeyboard(
                controller: _textController,
                initialTab: _keyboardInitialTab,
              ),
              const SizedBox(height: 2),
            ],
            if (!keyboardMode) ...[
              // Кнопка действия
              AnimatedSwitcher(
                duration: _noMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _buildPrimaryAction(),
              ),
              if (!_isChecked && _wrongAttemptsOnCurrentTask >= 2) ...[
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: _noMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: _buildDontKnowButton(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardFocusCard() {
    final landscape = _isLandscape;
    return SingleChildScrollView(
      padding: EdgeInsets.all(landscape ? 12 : 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppThemeColors.accentLight(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.32),
              ),
            ),
            child: Text(
              context.watch<LanguageService>().isEnglish
                  ? topicTitleEn(widget.topicName)
                  : widget.topicName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(landscape ? 14 : 16),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppThemeColors.border(context)),
            ),
            child: _buildQuestionPresentation(
              _localizedDynamicText(_clarifiedQuestion(_task)),
              fontSize: landscape ? 18 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction() {
    final t = context.watch<LanguageService>().t;
    if (_isChecked && (_isCorrect || !_hasExplanation)) {
      return _buildActionButton(
        key: const ValueKey('primary_continue'),
        label: _currentIndex < widget.tasks.length - 1
            ? t('task.continue')
            : t('task.finish'),
        color: _isCorrect ? AppColors.success : AppColors.accent,
        onTap: _goNext,
      );
    }
    if (_isChecked && _hasExplanation) {
      final steps = _explanationSteps;
      return _buildActionButton(
        key: const ValueKey('primary_explain'),
        label: _explanationStep < steps.length - 1
            ? t('task.next')
            : t('task.gotIt'),
        color: AppColors.accent,
        onTap: () {
          SoundService.playTap();
          if (_explanationStep < steps.length - 1) {
            setState(() => _explanationStep++);
          } else {
            _goNext();
          }
        },
      );
    }
    if (!_isChecked && _task.type == TaskType.textInput) {
      return _buildActionButton(
        key: const ValueKey('primary_check'),
        label: t('task.check'),
        color: _textIsNotEmpty
            ? AppColors.accent
            : AppThemeColors.disabled(context),
        onTap: _textIsNotEmpty ? _checkAnswer : null,
      );
    }
    return const SizedBox.shrink(key: ValueKey('primary_empty'));
  }

  Widget _buildQuestionPresentation(String question,
      {required double fontSize}) {
    final extracted = _extractExampleFromQuestion(question);
    if (extracted == null) {
      return MathText(
        question,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.textPrimary(context),
          height: 1.25,
        ),
        textAlign: TextAlign.center,
      );
    }

    final intro = question.replaceFirst(extracted, '').trim();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (intro.isNotEmpty) ...[
            Text(
              intro,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize * 0.58,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppThemeColors.accentLight(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.45),
                  width: 1.4,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MathText(
                      extracted,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedDynamicText(String text) {
    if (!context.read<LanguageService>().isEnglish) return text;
    return LocalizedTextService.forEnglishUi(text);
  }

  String? _extractExampleFromQuestion(String question) {
    final q = question.trim();
    if (q.isEmpty) return null;

    bool looksLikeExpression(String v) {
      final s = v.trim();
      if (s.length < 3) return false;
      if (RegExp(r'[А-Яа-яA-Za-w]')
          .hasMatch(s.replaceAll(RegExp(r'[xyzXYZ]'), ''))) {
        return false;
      }
      return RegExp(r'[0-9xyzXYZ]').hasMatch(s) &&
          RegExp(r'[=+\-*/<>≤≥^√]').hasMatch(s);
    }

    final colon = q.lastIndexOf(':');
    if (colon != -1 && colon < q.length - 1) {
      final tail = q.substring(colon + 1).trim();
      if (looksLikeExpression(tail)) return tail;
    }

    if (looksLikeExpression(q)) return q;

    final m =
        RegExp(r'([xyzXYZ0-9][xyzXYZ0-9\s+\-*/=<>≤≥^√().,]+)').firstMatch(q);
    if (m != null) {
      final candidate = (m.group(1) ?? '').trim();
      if (looksLikeExpression(candidate)) return candidate;
    }
    return null;
  }

  String _clarifiedQuestion(Task task) {
    final q = task.question.trim();
    final isEnglish = context.read<LanguageService>().isEnglish;
    final topic = isEnglish ? topicTitleEn(task.topic) : task.topic;

    final gcdMatch = RegExp(
      r'^НОД\((\d+),\s*(\d+)\)\s*=\s*\?$',
      caseSensitive: false,
    ).firstMatch(q);
    if (gcdMatch != null) {
      if (isEnglish) {
        return 'Find the GCD of ${gcdMatch.group(1)} and ${gcdMatch.group(2)}.\n'
            'GCD means greatest common divisor: the largest number that divides both numbers without a remainder.';
      }
      return 'Найдите НОД чисел ${gcdMatch.group(1)} и ${gcdMatch.group(2)}.\n'
          'НОД — это наибольший общий делитель: самое большое число, на которое оба числа делятся без остатка.';
    }

    final lcmMatch = RegExp(
      r'^НОК\((\d+),\s*(\d+)\)\s*=\s*\?$',
      caseSensitive: false,
    ).firstMatch(q);
    if (lcmMatch != null) {
      if (isEnglish) {
        return 'Find the LCM of ${lcmMatch.group(1)} and ${lcmMatch.group(2)}.\n'
            'LCM means least common multiple: the smallest positive number divisible by both given numbers.';
      }
      return 'Найдите НОК чисел ${lcmMatch.group(1)} и ${lcmMatch.group(2)}.\n'
          'НОК — это наименьшее общее кратное: самое маленькое положительное число, которое делится на оба данных числа.';
    }

    final terseExpression = RegExp(r'^[\d\s+\-*/×÷().,]+=\s*\?$').hasMatch(q);
    if (terseExpression) {
      if (isEnglish) {
        return 'Calculate the expression and enter only the answer:\n$q';
      }
      return 'Вычислите выражение и запишите только ответ:\n$q';
    }

    final terseFraction = RegExp(r'^\d+/\d+\s+от\s+числа\s+\d+\s*=\s*\?$')
        .hasMatch(q.toLowerCase());
    if (terseFraction) {
      if (isEnglish) {
        return 'Find the requested fraction of the number. First divide by the denominator, then multiply by the numerator:\n$q';
      }
      return 'Найдите указанную долю числа. Сначала разделите число на знаменатель, затем умножьте на числитель:\n$q';
    }

    if (q.length <= 22 && q.endsWith('?') && task.type == TaskType.textInput) {
      if (isEnglish) {
        return 'Complete the task from “$topic” and enter the answer:\n$q';
      }
      return 'Выполните задание по теме "${task.topic}" и запишите ответ:\n$q';
    }

    return q;
  }

  Widget _buildKeyboardInputPreview() {
    final t = context.watch<LanguageService>().t;
    final text = _textController.text;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppThemeColors.background(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_rounded,
              size: 14, color: AppThemeColors.textHint(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.isEmpty ? t('task.inputPreview') : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: text.isEmpty ? FontWeight.w500 : FontWeight.w700,
                color: text.isEmpty
                    ? AppThemeColors.textHint(context)
                    : AppThemeColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    Key? key,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final lowPerf = _isLowPerfMobileWeb;
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: enabled && !lowPerf
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color:
                  enabled ? Colors.white : Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDontKnowButton() {
    final t = context.watch<LanguageService>().t;
    final lowPerf = _isLowPerfMobileWeb;
    return GestureDetector(
      key: const ValueKey('secondary_dontknow'),
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
            width: 1.8,
          ),
          boxShadow: lowPerf
              ? null
              : [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline_rounded,
                size: 20, color: AppColors.error),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                t('task.dontKnow'),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAnswer() async {
    SoundService.playTap();
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
      _showMathKeyboard = false;
    });
    _triggerAnswerFlash(correct);

    if (correct) {
      _correctCount++;
      await ProgressService.markSolved(_task.id);
      final newAchievements = await _checkProgressAchievements();
      if (newAchievements.isNotEmpty) {
        if (_newAchievementsIncludeStreak(newAchievements)) {
          unawaited(SoundService.playStreak());
        } else {
          unawaited(SoundService.playAchievement());
        }
        await _showAchievementsUnlockedDialog(newAchievements);
      }
      await SoundService.playCorrect();
    } else {
      _wrongCount++;
      _wrongAttemptsOnCurrentTask++;
      _wrongTasks.add(_task);
      await ProgressService.recordAttempt(false);
      SoundService.playWrong();
    }
  }

  void _triggerAnswerFlash(bool correct) {
    final flash = correct ? AppColors.success : AppColors.error;
    setState(() => _answerFlashColor = flash);
    Timer(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _answerFlashColor = null);
    });
  }

  Future<List<Achievement>> _checkProgressAchievements({
    int? sessionCorrect,
    int? sessionTotal,
  }) async {
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

    return AchievementsService.evaluateProgress(
      totalSolved: totalSolved,
      streak: streak,
      accuracy: accuracy,
      totalAttempts: totalAttempts,
      sessionCorrect: sessionCorrect,
      sessionTotal: sessionTotal,
      grade: grade,
      gradeProgress: gradeProgress,
    );
  }

  /// «Не знаю» — раскрываем правильный ответ без перехода к следующей задаче
  void _revealAnswer() {
    SoundService.hapticMedium();
    SoundService.playTap();
    setState(() {
      _isChecked = true;
      _isCorrect = false;
      _showMathKeyboard = false;
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
    _triggerAnswerFlash(false);
    SoundService.playWrong();
  }

  void _goNext() {
    if (_currentIndex < widget.tasks.length - 1) {
      SoundService.playNext();
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
    await SoundService.playComplete();
    final newAchievements = await _checkProgressAchievements(
      sessionCorrect: _correctCount,
      sessionTotal: widget.tasks.length,
    );

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
    final t = context.read<LanguageService>().t;
    if (_currentIndex == 0 && !_isChecked) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppThemeColors.surface(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: Text(t('task.exitTitle'),
            style: TextStyle(color: AppThemeColors.textPrimary(context))),
        content: Text(t('task.exitBody'),
            style: TextStyle(color: AppThemeColors.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('task.stay')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) context.pop();
            },
            child: Text(t('task.exit')),
          ),
        ],
      ),
    );
  }

  Future<void> _showAchievementsUnlockedDialog(
      List<Achievement> achievements) async {
    final t = context.read<LanguageService>().t;
    if (!mounted || achievements.isEmpty) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppThemeColors.surface(ctx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          title: Text(t('task.newAchievement')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: achievements
                  .take(3)
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(a.icon, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (AchievementsService.getAvatarSkinUnlockedBy(
                                  a.type) !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  t('task.skin'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SoundService.playTap();
                Navigator.of(ctx).pop();
              },
              child: Text(t('task.cool')),
            ),
          ],
        );
      },
    );
  }

  List<String> _fallbackStepsFor(Task task) {
    final answer = _localizedDynamicText(task.answer).trim();
    if (answer.isEmpty) return const <String>[];

    final specific = _specificFallbackStepsFor(task, answer);
    if (specific.isNotEmpty) return specific;

    final steps = <String>[];
    final isEnglish = context.read<LanguageService>().isEnglish;
    final topic = isEnglish ? topicTitleEn(task.topic) : task.topic;

    if (task.type == TaskType.multipleChoice &&
        (task.options?.isNotEmpty ?? false)) {
      steps.add(isEnglish
          ? 'First read the question and decide which rule from “$topic” applies.'
          : 'Сначала прочитай условие и определи, какое правило из темы "$topic" нужно применить.');
      steps.add(isEnglish
          ? 'Check the options one by one: wrong options usually break the sign, operation order, units, or domain restrictions.'
          : 'Проверь варианты по очереди: неподходящие варианты обычно нарушают знак, порядок действий, единицы измерения или область допустимых значений.');
    } else {
      steps.add(isEnglish
          ? 'First write down the given data and choose the rule from “$topic”.'
          : 'Сначала выпиши данные из условия и выбери правило из темы "$topic".');
      steps.add(isEnglish
          ? 'Carry out the calculation carefully: watch operation order, signs, and units.'
          : 'Выполни вычисление аккуратно: соблюдай порядок действий, знаки и единицы измерения.');
    }

    steps.add(
        isEnglish ? 'Correct answer: $answer.' : 'Правильный ответ: $answer.');
    return steps;
  }

  List<String> _specificFallbackStepsFor(Task task, String answer) {
    final q = task.question.trim();
    final isEnglish = context.read<LanguageService>().isEnglish;

    final gcdMatch = RegExp(
      r'НОД\((\d+),\s*(\d+)\)',
      caseSensitive: false,
    ).firstMatch(q);
    if (gcdMatch != null) {
      final a = int.parse(gcdMatch.group(1)!);
      final b = int.parse(gcdMatch.group(2)!);
      final divisorsA = _divisors(a).join(', ');
      final divisorsB = _divisors(b).join(', ');
      if (isEnglish) {
        return [
          'List the divisors of the first number: $a → $divisorsA.',
          'List the divisors of the second number: $b → $divisorsB.',
          'Common divisors appear in both lists. The greatest one is $answer.',
        ];
      }
      return [
        'Выпишем делители первого числа: $a → $divisorsA.',
        'Выпишем делители второго числа: $b → $divisorsB.',
        'Общие делители есть в обоих списках. Самый большой из них — $answer.',
      ];
    }

    final lcmMatch = RegExp(
      r'НОК\((\d+),\s*(\d+)\)',
      caseSensitive: false,
    ).firstMatch(q);
    if (lcmMatch != null) {
      final a = int.parse(lcmMatch.group(1)!);
      final b = int.parse(lcmMatch.group(2)!);
      final gcd = _gcd(a, b);
      if (isEnglish) {
        return [
          'First find the GCD of $a and $b: it is $gcd.',
          'Use the relationship GCD(a, b) × LCM(a, b) = a × b.',
          'LCM($a, $b) = $a × $b / $gcd = $answer.',
        ];
      }
      return [
        'Сначала найдём НОД чисел $a и $b: он равен $gcd.',
        'Используем связь НОД и НОК: НОК(a, b) = a × b / НОД(a, b).',
        'НОК($a, $b) = $a × $b / $gcd = $answer.',
      ];
    }

    final shareMatch = RegExp(
      r'(\d+)/(\d+)\s+от\s+числа\s+(\d+)',
      caseSensitive: false,
    ).firstMatch(q);
    if (shareMatch != null) {
      final n = int.parse(shareMatch.group(1)!);
      final d = int.parse(shareMatch.group(2)!);
      final whole = int.parse(shareMatch.group(3)!);
      if (isEnglish) {
        return [
          'The fraction $n/$d means: split the number into $d equal parts and take $n of them.',
          'First find one $d-th part: $whole / $d.',
          'Then multiply the result by $n. The answer is $answer.',
        ];
      }
      return [
        'Дробь $n/$d означает: число нужно разделить на $d равных частей и взять $n таких частей.',
        'Сначала найдём одну $d-ю часть: $whole / $d.',
        'Затем умножим результат на $n. Получаем ответ: $answer.',
      ];
    }

    final percentMatch =
        RegExp(r'(\d+(?:[.,]\d+)?)%\s+от\s+(\d+(?:[.,]\d+)?)').firstMatch(q);
    if (percentMatch != null) {
      final percent = percentMatch.group(1)!.replaceAll(',', '.');
      final whole = percentMatch.group(2)!.replaceAll(',', '.');
      if (isEnglish) {
        return [
          '$percent% means $percent/100 of a quantity.',
          'To find $percent% of $whole, calculate $whole × $percent / 100.',
          'After the calculation, the answer is $answer.',
        ];
      }
      return [
        '$percent% означает $percent/100 от величины.',
        'Чтобы найти $percent% от $whole, нужно вычислить $whole × $percent / 100.',
        'После вычисления получаем ответ: $answer.',
      ];
    }

    final equationMatch =
        RegExp(r'(^|[\s:])([xyz])\s*[+\-*/=]').firstMatch(q.toLowerCase());
    if (equationMatch != null && q.contains('=')) {
      if (isEnglish) {
        return [
          'This is an equation: find the value of the unknown that makes the equality true.',
          'Use equivalent transformations: you may add, subtract, multiply, or divide both sides by the same non-zero number.',
          'Check by substituting the value back into the equation. Correct answer: $answer.',
        ];
      }
      return [
        'Это уравнение: нужно найти значение неизвестной буквы, при котором равенство станет верным.',
        'Переноси числа и буквенные слагаемые по правилам равносильных преобразований: к обеим частям можно прибавлять, вычитать, умножать или делить на одно и то же ненулевое число.',
        'Проверка делается подстановкой найденного значения. Правильный ответ: $answer.',
      ];
    }

    final coordinateMatch = RegExp(r'\((-?\d+),\s*(-?\d+)\)').firstMatch(q);
    if (coordinateMatch != null &&
        task.topic.toLowerCase().contains('координ')) {
      if (isEnglish) {
        return [
          'In coordinates (x, y), the first coordinate shows movement right or left; the second shows movement up or down.',
          'Check the signs: positive means right/up, negative means left/down.',
          'After checking the condition, the answer is $answer.',
        ];
      }
      return [
        'В координатах (x, y) первая координата показывает движение вправо или влево, вторая — вверх или вниз.',
        'Определи знаки координат: положительная координата идёт вправо/вверх, отрицательная — влево/вниз.',
        'После проверки условия получаем ответ: $answer.',
      ];
    }

    return const <String>[];
  }

  List<int> _divisors(int value) {
    final out = <int>[];
    for (var i = 1; i <= value; i++) {
      if (value % i == 0) out.add(i);
    }
    return out;
  }

  int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final r = x % y;
      x = y;
      y = r;
    }
    return x;
  }
}
