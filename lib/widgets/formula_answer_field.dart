import 'package:flutter/material.dart';
import 'math_text.dart';

/// All toolbar edits respect the current selection, including replacements.
class FormulaEditing {
  static void insert(TextEditingController controller, String text) {
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : controller.text.length;
    final end = selection.isValid ? selection.end : controller.text.length;
    controller.value = TextEditingValue(
      text: controller.text.replaceRange(start, end, text),
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  static void backspace(TextEditingController controller) {
    final s = controller.selection;
    final end = s.isValid ? s.end : controller.text.length;
    final start = s.isValid && !s.isCollapsed
        ? s.start
        : (end - 1).clamp(0, end);
    controller.value = TextEditingValue(
      text: controller.text.replaceRange(start, end, ''),
      selection: TextSelection.collapsed(offset: start),
    );
  }

  static String fraction(String numerator, String denominator) {
    String wrap(String s) =>
        RegExp(r'^-?[\d.,]+$|^[a-zA-Z]$').hasMatch(s) ? s : '($s)';
    return '${wrap(numerator.trim())}/${wrap(denominator.trim())}';
  }
}

class MathInputToolbar extends StatelessWidget {
  const MathInputToolbar({
    super.key,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  void insert(String value) {
    FormulaEditing.insert(controller, value);
    onChanged?.call(controller.text);
  }

  Future<void> fraction(BuildContext context) async {
    final numerator = TextEditingController(
      text: controller.selection.isValid
          ? controller.selection.textInside(controller.text)
          : '',
    );
    final denominator = TextEditingController();
    String? error;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void submit() {
            final d = denominator.text.trim();
            if (numerator.text.trim().isEmpty ||
                d.isEmpty ||
                double.tryParse(d.replaceAll(',', '.')) == 0) {
              setState(
                () => error = 'Заполните оба поля. Знаменатель не равен нулю.',
              );
              return;
            }
            Navigator.pop(context, FormulaEditing.fraction(numerator.text, d));
          }

          return AlertDialog(
            title: const Text('Дробь'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: numerator,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Числитель'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(thickness: 2),
                  ),
                  TextField(
                    controller: denominator,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Знаменатель',
                      errorText: error,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(onPressed: submit, child: const Text('Вставить')),
            ],
          );
        },
      ),
    );
    // Controllers remain alive while the dialog's closing animation runs.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    numerator.dispose();
    denominator.dispose();
    if (value == null || !context.mounted) return;
    final current = context.widget;
    if (current is MathInputToolbar &&
        current.enabled &&
        identical(current.controller, controller)) {
      current.insert(value);
    }
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      OutlinedButton(
        onPressed: enabled ? () => fraction(context) : null,
        child: Semantics(
          label: 'Вставить дробь',
          excludeSemantics: true,
          child: const MathText(r'$\frac{a}{b}$'),
        ),
      ),
      for (final entry in {
        'x²': '^2',
        '√': '√()',
        '(': '(',
        ')': ')',
        '−': '-',
      }.entries)
        OutlinedButton(
          onPressed: enabled
              ? () {
                  final selected = controller.selection.isValid
                      ? controller.selection.textInside(controller.text)
                      : '';
                  if (entry.key == '√') {
                    insert('√($selected)');
                    if (selected.isEmpty) {
                      controller.selection = TextSelection.collapsed(
                        offset: controller.selection.baseOffset - 1,
                      );
                    }
                  } else if (entry.key == 'x²' && selected.isNotEmpty) {
                    insert('($selected)^2');
                  } else {
                    insert(entry.value);
                  }
                }
              : null,
          child: Semantics(
            label: const {
              'x²': 'Возвести в квадрат',
              '√': 'Квадратный корень',
              '(': 'Открыть скобку',
              ')': 'Закрыть скобку',
              '−': 'Минус',
            }[entry.key],
            excludeSemantics: true,
            child: Text(entry.key),
          ),
        ),
    ],
  );
}

class FormulaAnswerField extends StatelessWidget {
  const FormulaAnswerField({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength = 100,
    this.decoration = const InputDecoration(
      labelText: 'Ответ',
      border: OutlineInputBorder(),
    ),
    this.onChanged,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final bool readOnly;
  final int maxLines, maxLength;
  final InputDecoration decoration;
  final ValueChanged<String>? onChanged, onSubmitted;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: decoration.copyWith(counterText: maxLines == 1 ? '' : null),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      if (!readOnly)
        MathInputToolbar(controller: controller, onChanged: onChanged),
      const SizedBox(height: 10),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) =>
            (value.text.trim().isEmpty ||
                !RegExp(r'[/^√²³=()]').hasMatch(value.text))
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Запись ответа', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    MathText(value.text, style: const TextStyle(fontSize: 22)),
                  ],
                ),
              ),
      ),
    ],
  );
}
