/// MathKeyboard — кастомная математическая клавиатура
/// Заменяет системную клавиатуру для ввода числовых ответов

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class MathKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const MathKeyboard({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  void _press(String key) {
    if (!enabled) return;
    HapticFeedback.lightImpact();

    final text = controller.text;

    switch (key) {
      case 'backspace':
        if (text.isNotEmpty) {
          controller.text = text.substring(0, text.length - 1);
          controller.selection =
              TextSelection.collapsed(offset: controller.text.length);
        }
        return;

      case '±':
        if (text.startsWith('-')) {
          controller.text = text.substring(1);
        } else if (text.isNotEmpty) {
          controller.text = '-$text';
        }
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '.':
        if (text.contains('.')) return;
        if (text.isEmpty || text == '-') {
          controller.text = '${text}0.';
        } else {
          controller.text = '$text.';
        }
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '/':
        if (text.contains('/')) return;
        if (text.isEmpty || text == '-') return;
        controller.text = '$text/';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      default:
        // Digit
        controller.text = text + key;
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['7', '8', '9', 'backspace']),
        const SizedBox(height: 8),
        _buildRow(context, ['4', '5', '6', '-']),
        const SizedBox(height: 8),
        _buildRow(context, ['1', '2', '3', '/']),
        const SizedBox(height: 8),
        // Нижняя строка: ±, широкий 0, .
        Row(
          children: [
            Expanded(child: _buildKey(context, '±')),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _buildKey(context, '0')),
            const SizedBox(width: 8),
            Expanded(child: _buildKey(context, '.')),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _buildKey(context, keys[i])),
        ],
      ],
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final isBackspace = key == 'backspace';
    final isSpecial = key == '-' || key == '/' || key == '±';

    Color bgColor;
    Color borderColor;
    Widget child;

    if (isBackspace) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.25);
      child = Icon(Icons.backspace_rounded, color: AppColors.error, size: 22);
    } else if (isSpecial) {
      bgColor = AppThemeColors.accentLight(context);
      borderColor = AppColors.accent.withValues(alpha: 0.3);
      // Отображаем красивый символ, но вставляем ASCII
      final display = key == '-' ? '−' : key;
      child = Text(
        display,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      );
    } else {
      bgColor = AppThemeColors.surface(context);
      borderColor = AppThemeColors.border(context);
      child = Text(
        key,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppThemeColors.textPrimary(context),
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? () => _press(key) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
