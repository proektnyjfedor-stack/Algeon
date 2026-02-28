/// Экзаменационный экран ОГЭ / ЕГЭ
///
/// Навигация между задачами, таймер ЧЧ:ММ:СС,
/// сохранение ответов, итоговая проверка

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/oge_ege_data.dart';
import '../models/task.dart';
import '../services/progress_service.dart';
import '../widgets/math_text.dart';

class OgeEgeExamScreen extends StatefulWidget {
  final ExamVariant variant;

  const OgeEgeExamScreen({super.key, required this.variant});

  @override
  State<OgeEgeExamScreen> createState() => _OgeEgeExamScreenState();
}

class _OgeEgeExamScreenState extends State<OgeEgeExamScreen> {
  int _currentIndex = 0;
  late List<String?> _answers;          // ответ на каждую задачу
  late List<bool?> _results;            // null=не проверено, true=верно, false=неверно
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _finished = false;
  bool _submitted = false;

  // Контроллеры текстовых полей — один на задачу
  late List<TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    final n = widget.variant.tasks.length;
    _answers         = List.filled(n, null);
    _results         = List.filled(n, null);
    _remainingSeconds = widget.variant.timeMinutes * 60;
    _textControllers = List.generate(n, (_) => TextEditingController());

    // Восстанавливаем сохранённые ответы в поля ввода
    for (var i = 0; i < n; i++) {
      _textControllers[i].text = _answers[i] ?? '';
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0 && !_finished) {
        setState(() => _remainingSeconds--);
      } else if (_remainingSeconds <= 0 && !_finished) {
        _submitAll();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final c in _textControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Сохранить ответ на текущую задачу ───────────────────────
  void _saveCurrentAnswer(String value) {
    final task = widget.variant.tasks[_currentIndex];
    if (task.type == TaskType.textInput) {
      setState(() => _answers[_currentIndex] = value.trim().isEmpty ? null : value.trim());
    }
  }

  // ── Выбрать вариант ──────────────────────────────────────────
  void _selectOption(String option) {
    if (_submitted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _answers[_currentIndex] = option;
      _textControllers[_currentIndex].text = option;
    });
  }

  // ── Перейти к задаче ─────────────────────────────────────────
  void _goTo(int index) {
    // Сохраняем текстовый ответ текущей задачи
    final cur = widget.variant.tasks[_currentIndex];
    if (cur.type == TaskType.textInput) {
      _saveCurrentAnswer(_textControllers[_currentIndex].text);
    }
    setState(() => _currentIndex = index);
  }

  // ── Проверить всё и показать результат ──────────────────────
  void _submitAll() {
    if (_finished) return;
    _timer.cancel();
    setState(() {
      _finished = true;
      _submitted = true;
    });

    // Проверяем каждый ответ
    for (var i = 0; i < widget.variant.tasks.length; i++) {
      final task  = widget.variant.tasks[i];
      final given = (_answers[i] ?? '').trim().toLowerCase().replaceAll(',', '.');
      final right = task.answer.trim().toLowerCase().replaceAll(',', '.');
      _results[i] = given == right;
    }

    final correct = _results.where((r) => r == true).length;
    final passed  = correct / widget.variant.tasks.length >= 0.7;

    if (passed) {
      ProgressService.setBool('exam_${widget.variant.id}_passed', true);
    }

    _showResultDialog(correct, widget.variant.tasks.length, passed);
  }

  // ── Диалог итогов ────────────────────────────────────────────
  void _showResultDialog(int correct, int total, bool passed) {
    final pct = ((correct / total) * 100).toInt();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeColors.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              size: 56,
              color: passed ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              passed ? 'Отлично! Сдано!' : 'Попробуй ещё раз',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(ctx),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: passed ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$correct из $total заданий верно',
              style: TextStyle(
                fontSize: 15,
                color: AppThemeColors.textSecondary(ctx),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      // Остаться — посмотреть разбор
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Разбор'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Готово'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Форматирование таймера ЧЧ:ММ:СС ────────────────────────
  String _formatTime(int s) {
    final h  = s ~/ 3600;
    final m  = (s % 3600) ~/ 60;
    final sc = s % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sc.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${sc.toString().padLeft(2, '0')}';
  }

  // ── Цвет кружка навигации ────────────────────────────────────
  Color _dotColor(int i) {
    if (_submitted) {
      if (_results[i] == true)  return AppColors.success;
      if (_results[i] == false) return AppColors.error;
      return Colors.grey.shade300;
    }
    if (i == _currentIndex) return AppColors.accent;
    if (_answers[i] != null)   return AppColors.accent.withValues(alpha: 0.35);
    return Colors.grey.shade200;
  }

  Color _dotTextColor(int i) {
    if (_submitted) {
      if (_results[i] != null) return Colors.white;
    }
    if (i == _currentIndex) return Colors.white;
    if (_answers[i] != null) return AppColors.accent;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final tasks     = widget.variant.tasks;
    final task      = tasks[_currentIndex];
    final isLowTime = _remainingSeconds < 300; // < 5 min

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Шапка ────────────────────────────────────────────
            _buildHeader(isLowTime),

            // ── Навигатор по задачам ──────────────────────────────
            _buildNavigator(tasks),

            // ── Разделитель ───────────────────────────────────────
            Divider(height: 1, color: AppThemeColors.border(context)),

            // ── Задача + ответ ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskNumber(),
                    const SizedBox(height: 14),
                    _buildQuestion(task),
                    const SizedBox(height: 24),
                    _buildAnswer(task),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Кнопки навигации ──────────────────────────────────
            _buildNavButtons(tasks.length),
          ],
        ),
      ),
    );
  }

  // ── Шапка ────────────────────────────────────────────────────
  Widget _buildHeader(bool isLowTime) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        border: Border(bottom: BorderSide(color: AppThemeColors.border(context))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showExitDialog,
            icon: Icon(Icons.close_rounded, color: AppThemeColors.textSecondary(context)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.variant.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
                Text(
                  widget.variant.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppThemeColors.textHint(context),
                  ),
                ),
              ],
            ),
          ),
          // Таймер
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLowTime
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isLowTime ? AppColors.error : AppThemeColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Кнопка завершить
          TextButton(
            onPressed: _submitted ? null : () {
              HapticFeedback.mediumImpact();
              _showSubmitDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text(
              'Сдать',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Навигатор по задачам ──────────────────────────────────────
  Widget _buildNavigator(List<Task> tasks) {
    return Container(
      color: AppThemeColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(tasks.length, (i) {
          final isAnswered = _answers[i] != null;
          final isCurrent  = i == _currentIndex;

          return GestureDetector(
            onTap: () => _goTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _dotColor(i),
                borderRadius: BorderRadius.circular(9),
                border: isCurrent
                    ? Border.all(color: AppColors.accent, width: 2.5)
                    : isAnswered && !_submitted
                        ? Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5)
                        : null,
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _dotTextColor(i),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Номер задачи ──────────────────────────────────────────────
  Widget _buildTaskNumber() {
    final answered = _answers.where((a) => a != null).length;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Задание ${_currentIndex + 1} из ${widget.variant.tasks.length}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Отвечено: $answered',
          style: TextStyle(
            fontSize: 12,
            color: AppThemeColors.textHint(context),
          ),
        ),
      ],
    );
  }

  // ── Текст задачи ──────────────────────────────────────────────
  Widget _buildQuestion(Task task) {
    Color? borderColor;
    if (_submitted && _results[_currentIndex] != null) {
      borderColor = _results[_currentIndex]! ? AppColors.success : AppColors.error;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppThemeColors.border(context),
          width: borderColor != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Тема задачи
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.topic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.textHint(context),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Текст задачи (с LaTeX-рендерингом формул)
          MathText(
            task.question,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.55,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          // Подсказка
          if (task.hint != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task.hint!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          // Верный ответ (после сдачи)
          if (_submitted) ...[
            const SizedBox(height: 14),
            Divider(color: AppThemeColors.border(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _results[_currentIndex] == true
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: _results[_currentIndex] == true ? AppColors.success : AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Верный ответ: ${task.answer}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _results[_currentIndex] == true
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Поле ответа ───────────────────────────────────────────────
  Widget _buildAnswer(Task task) {
    if (task.type == TaskType.multipleChoice) {
      return _buildOptions(task);
    } else {
      return _buildTextInput(task);
    }
  }

  Widget _buildOptions(Task task) {
    final options = task.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите ответ:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSelected = _answers[_currentIndex] == opt;
            final isCorrect  = _submitted && opt == task.answer;
            final isWrong    = _submitted && isSelected && opt != task.answer;

            Color bg    = AppThemeColors.surface(context);
            Color border = AppThemeColors.border(context);
            Color text  = AppThemeColors.textPrimary(context);

            if (_submitted) {
              if (isCorrect) { bg = AppColors.success.withValues(alpha: 0.12); border = AppColors.success; text = AppColors.success; }
              if (isWrong)   { bg = AppColors.error.withValues(alpha: 0.12);   border = AppColors.error;   text = AppColors.error; }
            } else if (isSelected) {
              bg = AppColors.accent.withValues(alpha: 0.1);
              border = AppColors.accent;
              text = AppColors.accent;
            }

            return GestureDetector(
              onTap: () => _selectOption(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                constraints: const BoxConstraints(minWidth: 80),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: isSelected || isCorrect ? 2 : 1.5),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextInput(Task task) {
    final isCorrect = _submitted && _results[_currentIndex] == true;
    final isWrong   = _submitted && _results[_currentIndex] == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Введите ответ:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.success.withValues(alpha: 0.08)
                : isWrong
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCorrect
                  ? AppColors.success
                  : isWrong
                      ? AppColors.error
                      : AppThemeColors.border(context),
              width: _submitted ? 2 : 1.5,
            ),
          ),
          child: TextField(
            controller: _textControllers[_currentIndex],
            enabled: !_submitted,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textPrimary(context),
            ),
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(
              hintText: 'Ваш ответ',
              hintStyle: TextStyle(color: AppThemeColors.textHint(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              suffixIcon: isCorrect
                  ? Icon(Icons.check_circle_rounded, color: AppColors.success)
                  : isWrong
                      ? Icon(Icons.cancel_rounded, color: AppColors.error)
                      : null,
            ),
            onChanged: _saveCurrentAnswer,
            onSubmitted: (_) => _goNext(),
          ),
        ),
      ],
    );
  }

  // ── Кнопки назад/вперёд ───────────────────────────────────────
  Widget _buildNavButtons(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        border: Border(top: BorderSide(color: AppThemeColors.border(context))),
      ),
      child: Row(
        children: [
          // Назад
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentIndex > 0 ? _goPrev : null,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Назад'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Вперёд / Сдать
          Expanded(
            flex: 2,
            child: _currentIndex < total - 1
                ? ElevatedButton.icon(
                    onPressed: _goNext,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Далее'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _submitted ? null : _showSubmitDialog,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Сдать работу'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _goPrev() {
    if (_currentIndex > 0) _goTo(_currentIndex - 1);
  }

  void _goNext() {
    final total = widget.variant.tasks.length;
    if (_currentIndex < total - 1) _goTo(_currentIndex + 1);
  }

  void _showSubmitDialog() {
    final answered = _answers.where((a) => a != null).length;
    final total    = widget.variant.tasks.length;
    final missing  = total - answered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeColors.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Сдать работу?'),
        content: Text(
          missing > 0
              ? 'Вы ответили на $answered из $total заданий.\nОсталось без ответа: $missing.'
              : 'Вы ответили на все $total заданий.',
          style: TextStyle(color: AppThemeColors.textSecondary(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Продолжить'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitAll();
            },
            child: const Text('Сдать'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeColors.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Выйти?'),
        content: Text(
          'Прогресс экзамена будет потерян.',
          style: TextStyle(color: AppThemeColors.textSecondary(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
