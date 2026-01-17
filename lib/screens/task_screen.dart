/// Экран задачи — ТОЧНАЯ КОПИЯ макета
/// 
/// Левый макет: варианты в ряд
/// Правый макет: текстовое поле с линиями

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../services/progress_service.dart';

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

class _TaskScreenState extends State<TaskScreen> {
  int _currentIndex = 0;
  String? _selectedOption;
  final _textController = TextEditingController();
  
  bool _isChecked = false;
  bool _isCorrect = false;
  int _explanationStep = 0;

  Task get _task => widget.tasks[_currentIndex];
  
  int get _solvedCount {
    final ids = widget.tasks.map((t) => t.id).toList();
    return ProgressService.getSolvedCountForTopic(widget.topicName, ids);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _reset() {
    _selectedOption = null;
    _textController.clear();
    _isChecked = false;
    _isCorrect = false;
    _explanationStep = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Крестик сверху слева
            _buildHeader(),
            
            // Контент
            Expanded(
              child: _isChecked && !_isCorrect
                  ? _buildExplanation()
                  : _buildTaskContent(),
            ),
            
            // Прогресс снизу
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  /// Хедер с крестиком
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Контент задачи
  Widget _buildTaskContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          
          // Текст задачи
          Text(
            _task.question,
            style: _task.type == TaskType.multipleChoice
                ? const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  )
                : const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
            textAlign: _task.type == TaskType.multipleChoice
                ? TextAlign.center
                : TextAlign.left,
          ),
          
          const Spacer(flex: 2),
          
          // Ввод ответа
          if (_task.type == TaskType.multipleChoice)
            _buildOptionsRow()
          else
            _buildTextInputField(),
          
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  /// Варианты в ряд (как на левом макете)
  Widget _buildOptionsRow() {
    final options = _task.options ?? [];
    
    return Column(
      children: [
        // Метки Frame 1, Frame 2... (как на макете)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: options.asMap().entries.map((entry) {
            return Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Frame ${entry.key + 1}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 8),
        
        // Варианты
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: options.map((option) {
            final isSelected = _selectedOption == option;
            final isCorrectOption = option == _task.answer;
            
            Color bgColor = AppColors.white;
            Color borderColor = AppColors.borderDark;
            Color textColor = AppColors.textPrimary;
            
            if (_isChecked) {
              if (isCorrectOption) {
                bgColor = AppColors.success.withOpacity(0.1);
                borderColor = AppColors.success;
                textColor = AppColors.success;
              } else if (isSelected) {
                bgColor = AppColors.error.withOpacity(0.1);
                borderColor = AppColors.error;
                textColor = AppColors.error;
              }
            } else if (isSelected) {
              bgColor = AppColors.accentLight;
              borderColor = AppColors.accent;
            }
            
            return GestureDetector(
              onTap: _isChecked ? null : () {
                setState(() => _selectedOption = option);
                _checkAnswer();
              },
              child: Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Текстовое поле с линиями (как на правом макете)
  Widget _buildTextInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: _isChecked
            ? Border.all(
                color: _isCorrect ? AppColors.success : AppColors.error,
                width: 2,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Линии
          Positioned.fill(
            child: CustomPaint(
              painter: _LinesPainter(),
            ),
          ),
          
          // Поле ввода
          TextField(
            controller: _textController,
            maxLines: 4,
            enabled: !_isChecked,
            style: const TextStyle(
              fontSize: 18,
              height: 2.0,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _task.hint ?? 'Решите задачу...',
              hintStyle: TextStyle(color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              filled: false,
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
        ],
      ),
    );
  }

  /// Объяснение ошибки
  Widget _buildExplanation() {
    final steps = _task.explanationSteps;
    final visible = steps.take(_explanationStep + 1).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Давай разберём',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Шаги
          ...visible.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Кнопки
          if (_explanationStep < steps.length - 1)
            TextButton.icon(
              onPressed: () => setState(() => _explanationStep++),
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Следующий шаг'),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goNext,
                child: Text(_currentIndex < widget.tasks.length - 1 ? 'Дальше' : 'Завершить'),
              ),
            ),
        ],
      ),
    );
  }

  /// Прогресс-бар снизу (как на макете)
  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / widget.tasks.length;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Текст "решено X из Y"
          Text(
            'решено $_solvedCount из ${widget.tasks.length}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Прогресс-бар
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 10,
            ),
          ),
          
          // Кнопка "Дальше" если правильно
          if (_isChecked && _isCorrect) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: Text(
                  _currentIndex < widget.tasks.length - 1 ? 'Дальше' : 'Завершить',
                ),
              ),
            ),
          ],
          
          // Кнопка проверки для текстового ввода
          if (!_isChecked && _task.type == TaskType.textInput) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _textController.text.isNotEmpty ? _checkAnswer : null,
                child: const Text('Проверить'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _checkAnswer() {
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
      ProgressService.markSolved(_task.id);
    }
  }

  void _goNext() {
    if (_currentIndex < widget.tasks.length - 1) {
      setState(() {
        _currentIndex++;
        _reset();
      });
    } else {
      _showComplete();
    }
  }

  void _showComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Готово!', textAlign: TextAlign.center),
        content: Text(
          'Решено $_solvedCount из ${widget.tasks.length}',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Вернуться'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Рисует горизонтальные линии (как в тетради)
class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inputLine
      ..strokeWidth = 1;
    
    const lineHeight = 36.0; // Высота строки
    const startY = 44.0; // Начало первой линии
    
    for (double y = startY; y < size.height; y += lineHeight) {
      canvas.drawLine(
        Offset(16, y),
        Offset(size.width - 16, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
