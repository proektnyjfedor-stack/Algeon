import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/widgets/formula_answer_field.dart';

void main() {
  test('Backspace removes a whole mathematical Unicode symbol', () {
    final controller = TextEditingController(text: '2𝑥+1');
    controller.selection = const TextSelection.collapsed(offset: 3);
    FormulaEditing.backspace(controller);
    expect(controller.text, '2+1');
    expect(controller.selection.baseOffset, 1);
    controller.dispose();
  });
  test('Backspace removes combining marks together with their character', () {
    final controller = TextEditingController(text: 'a\u0301+2');
    controller.selection = const TextSelection.collapsed(offset: 2);
    FormulaEditing.backspace(controller);
    expect(controller.text, '+2');
    expect(controller.selection.baseOffset, 0);
    controller.dispose();
  });
  test(
    'Selection deletion and cursor at the start preserve surrounding text',
    () {
      final controller = TextEditingController(text: '12/34');
      controller.selection = const TextSelection(
        baseOffset: 4,
        extentOffset: 1,
      );
      FormulaEditing.backspace(controller);
      expect(controller.text, '14');
      expect(controller.selection.baseOffset, 1);
      controller.selection = const TextSelection.collapsed(offset: 0);
      FormulaEditing.backspace(controller);
      expect(controller.text, '14');
      controller.dispose();
    },
  );
}
