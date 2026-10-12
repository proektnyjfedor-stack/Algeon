/// MathKeyboard — кастомная математическая клавиатура
/// Заменяет системную клавиатуру для ввода числовых ответов
library;

import 'formula_answer_field.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import '../services/sound_service.dart';

class MathKeyboard extends StatelessWidget {
  const MathKeyboard({
    super.key,
    required this.controller,
    this.enabled = true,
    this.initialTab = 0,
  });
  final TextEditingController controller;
  final bool enabled;
  final int initialTab;

  void _press(String key) {
    if (!enabled) return;
    SoundService.hapticSelection();
    SoundService.playKey();

    if (key == 'clear') {
      controller.clear();
      return;
    }
    if (key == 'backspace') {
      FormulaEditing.backspace(controller);
      return;
    }
    if (key == '±') {
      final text = controller.text;
      controller.text = text.startsWith('-') ? text.substring(1) : '-$text';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      return;
    }
    FormulaEditing.insert(controller, switch (key) {
      'space' => ' ',
      '√' => '√(',
      '≥' => '>=',
      '≤' => '<=',
      '≠' => '!=',
      _ => key,
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MathKeyboardBody(
      controller: controller,
      enabled: enabled,
      initialTab: initialTab,
      onPress: _press,
    );
  }

  static Widget buildKey(
    BuildContext context,
    String key,
    bool isUltraCompact,
    VoidCallback onTap,
  ) {
    final t = context.read<LanguageService>().t;
    final isBackspace = key == 'backspace';
    final isClear = key == 'clear';
    final isSpace = key == 'space';
    final isSpecial =
        key == '-' ||
        key == '+' ||
        key == '/' ||
        key == '*' ||
        key == '=' ||
        key == '>' ||
        key == '<' ||
        key == '≥' ||
        key == '≤' ||
        key == '≠' ||
        key == '^' ||
        key == '²' ||
        key == '³' ||
        key == '(' ||
        key == ')' ||
        key == '[' ||
        key == ']' ||
        key == ',' ||
        key == ';' ||
        key == 'x' ||
        key == 'y' ||
        key == 'z' ||
        key == 'a' ||
        key == 'b' ||
        key == 'c' ||
        key == 'n' ||
        key == 'π' ||
        key == '√' ||
        key == '±' ||
        key == 'x=' ||
        key == 'y=' ||
        key == 'z=';

    Color bgColor;
    Color borderColor;
    Widget child;

    if (isBackspace) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.25);
      child = Icon(
        Icons.backspace_rounded,
        color: AppColors.error,
        size: isUltraCompact ? 18 : 20,
      );
    } else if (isClear) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.25);
      child = Text(
        t('keyboard.clear'),
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
        t('keyboard.space'),
        style: TextStyle(
          fontSize: isUltraCompact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.textSecondary(context),
        ),
      );
    } else if (isSpecial) {
      bgColor = AppThemeColors.accentLight(context);
      borderColor = Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.3);
      final display = switch (key) {
        '-' => '−',
        '*' => '×',
        '/' => '÷',
        _ => key,
      };
      child = Text(
        display,
        style: TextStyle(
          fontSize: display.length > 1
              ? (isUltraCompact ? 14 : 16)
              : (isUltraCompact ? 18 : 20),
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
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
        height: isUltraCompact ? 36 : 42,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isUltraCompact ? 10 : 12),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _MathKeyboardBody extends StatefulWidget {
  const _MathKeyboardBody({
    required this.controller,
    required this.enabled,
    required this.initialTab,
    required this.onPress,
  });
  final TextEditingController controller;
  final bool enabled;
  final int initialTab;
  final void Function(String key) onPress;

  @override
  State<_MathKeyboardBody> createState() => _MathKeyboardBodyState();
}

class _MathKeyboardBodyState extends State<_MathKeyboardBody> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
  }

  @override
  void didUpdateWidget(covariant _MathKeyboardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialTab.clamp(0, 2);
    if (next != oldWidget.initialTab && next != _tab) {
      setState(() => _tab = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isUltraCompact = h < 780 || isLandscape;
    final rowGap = isUltraCompact ? 4.0 : 6.0;
    final keyGap = isUltraCompact ? 4.0 : 6.0;
    final maxHeight = isUltraCompact ? 244.0 : 288.0;

    return SizedBox(
      height: maxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _tabButton(context, 0, '123'),
              SizedBox(width: keyGap),
              _tabButton(context, 1, 'x,y'),
              SizedBox(width: keyGap),
              _tabButton(context, 2, '≤ ≥'),
            ],
          ),
          SizedBox(height: rowGap),
          ..._rowsForTab().expand((row) sync* {
            yield _buildRow(context, row, keyGap, isUltraCompact);
            yield SizedBox(height: rowGap);
          }),
        ],
      ),
    );
  }

  List<List<String>> _rowsForTab() {
    // 3 clearly separated layouts:
    // 123  -> numbers + basic arithmetic
    // alg  -> variables/equation algebra
    // ≶    -> inequality-focused symbols
    if (_tab == 1) {
      return const [
        ['x=', 'y=', 'z=', '=', 'backspace'],
        ['x', 'y', 'z', 'a', 'b'],
        ['c', 'n', '^', '²', '³'],
        ['(', ')', '√', ',', 'clear'],
        ['+', '-', '*', '/', 'π'],
      ];
    }
    if (_tab == 2) {
      return const [
        ['>', '<', '≥', '≤', '≠'],
        ['x', 'y', 'z', '=', 'backspace'],
        ['(', ')', '[', ']', ','],
        ['7', '8', '9', '+', '-'],
        ['1', '2', '3', '0', 'clear'],
      ];
    }
    return const [
      ['7', '8', '9', 'backspace'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', ',', '/'],
      ['(', ')', '=', 'clear'],
    ];
  }

  Widget _buildRow(
    BuildContext context,
    List<String> keys,
    double keyGap,
    bool isUltraCompact,
  ) {
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
    final h = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    final isUltraCompact = h < 780 || size.width > size.height;
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(vertical: isUltraCompact ? 4 : 6),
          decoration: BoxDecoration(
            color: active
                ? AppThemeColors.accentLight(context)
                : AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.35)
                  : AppThemeColors.border(context),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isUltraCompact ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : AppThemeColors.textSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
