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

      case 'clear':
        controller.clear();
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

      case 'space':
        controller.text = '$text ';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '√':
        controller.text = '$text√(';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '*':
      case '^':
      case '(':
      case ')':
      case 'x':
      case '+':
        controller.text = '$text$key';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '>':
      case '<':
      case '=':
        controller.text = '$text$key';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '≥':
        controller.text = '$text>=';
        controller.selection =
            TextSelection.collapsed(offset: controller.text.length);
        return;

      case '≤':
        controller.text = '$text<=';
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
    return _MathKeyboardBody(
      controller: controller,
      enabled: enabled,
      onPress: _press,
    );
  }

  static Widget buildKey(
      BuildContext context, String key, bool isUltraCompact, VoidCallback onTap) {
    final isBackspace = key == 'backspace';
    final isClear = key == 'clear';
    final isSpace = key == 'space';
    final isSpecial = key == '-' ||
        key == '+' ||
        key == '/' ||
        key == '*' ||
        key == '=' ||
        key == '>' ||
        key == '<' ||
        key == '≥' ||
        key == '≤' ||
        key == '^' ||
        key == '(' ||
        key == ')' ||
        key == 'x' ||
        key == 'y' ||
        key == 'z' ||
        key == 'a' ||
        key == 'b' ||
        key == 'c' ||
        key == 'n' ||
        key == 'π' ||
        key == '√' ||
        key == '±';

    Color bgColor;
    Color borderColor;
    Widget child;

    if (isBackspace) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.25);
      child = Icon(Icons.backspace_rounded, color: AppColors.error, size: isUltraCompact ? 18 : 20);
    } else if (isClear) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.25);
      child = Text(
        'Очистить',
        style: TextStyle(
          fontSize: isUltraCompact ? 12 : 13,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      );
    } else if (isSpace) {
      bgColor = AppThemeColors.surface(context);
      borderColor = AppThemeColors.border(context);
      child = Text(
        'Пробел',
        style: TextStyle(
          fontSize: isUltraCompact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.textSecondary(context),
        ),
      );
    } else if (isSpecial) {
      bgColor = AppThemeColors.accentLight(context);
      borderColor = AppColors.accent.withValues(alpha: 0.3);
      final display = switch (key) {
        '-' => '−',
        '*' => '×',
        '/' => '÷',
        _ => key,
      };
      child = Text(
        display,
        style: TextStyle(
          fontSize: display.length > 1 ? (isUltraCompact ? 14 : 16) : (isUltraCompact ? 18 : 20),
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
          fontSize: isUltraCompact ? 19 : 22,
          fontWeight: FontWeight.w600,
          color: AppThemeColors.textPrimary(context),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: isUltraCompact ? 34 : 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isUltraCompact ? 10 : 12),
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

class _MathKeyboardBody extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final void Function(String key) onPress;

  const _MathKeyboardBody({
    required this.controller,
    required this.enabled,
    required this.onPress,
  });

  @override
  State<_MathKeyboardBody> createState() => _MathKeyboardBodyState();
}

class _MathKeyboardBodyState extends State<_MathKeyboardBody> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isUltraCompact = h < 780;
    final rowGap = isUltraCompact ? 4.0 : 6.0;
    final keyGap = isUltraCompact ? 4.0 : 6.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _tabButton(context, 0, '123'),
            SizedBox(width: keyGap),
            _tabButton(context, 1, 'x,y'),
            SizedBox(width: keyGap),
            _tabButton(context, 2, '><'),
          ],
        ),
        SizedBox(height: rowGap),
        ..._rowsForTab().expand((row) sync* {
          yield _buildRow(context, row, keyGap, isUltraCompact);
          yield SizedBox(height: rowGap);
        }),
        Row(
          children: [
            Expanded(flex: 2, child: _buildKey(context, 'clear', isUltraCompact)),
            SizedBox(width: keyGap),
            Expanded(flex: 3, child: _buildKey(context, 'backspace', isUltraCompact)),
          ],
        ),
      ],
    );
  }

  List<List<String>> _rowsForTab() {
    if (_tab == 1) {
      return const [
        ['x', 'y', 'z', 'a', 'b'],
        ['c', 'n', '(', ')', '^'],
        ['√', 'π', '%', '=', 'space'],
        ['0', '1', '2', '3', '4'],
        ['5', '6', '7', '8', '9'],
      ];
    }
    if (_tab == 2) {
      return const [
        ['>', '<', '≥', '≤', '='],
        ['+', '-', '*', '/', '±'],
        ['(', ')', '^', 'x', 'y'],
        [',', '.', '0', '1', '2'],
        ['3', '4', '5', '6', '7'],
      ];
    }
    return const [
      ['7', '8', '9', '(', ')'],
      ['4', '5', '6', '+', '-'],
      ['1', '2', '3', '*', '/'],
      ['0', '.', 'x', '^', '='],
      ['±', '>', '<', '≥', '≤'],
    ];
  }

  Widget _buildRow(
      BuildContext context, List<String> keys, double keyGap, bool isUltraCompact) {
    return Row(
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) SizedBox(width: keyGap),
          Expanded(child: _buildKey(context, keys[i], isUltraCompact)),
        ],
      ],
    );
  }

  Widget _buildKey(BuildContext context, String key, bool isUltraCompact) {
    return MathKeyboard.buildKey(
      context,
      key,
      isUltraCompact,
      widget.enabled ? () => widget.onPress(key) : () {},
    );
  }

  Widget _tabButton(BuildContext context, int index, String label) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppThemeColors.accentLight(context) : AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppColors.accent.withValues(alpha: 0.35) : AppThemeColors.border(context),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.accent : AppThemeColors.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
