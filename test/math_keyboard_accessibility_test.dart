import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/widgets/math_keyboard.dart';

void main() {
  Future<void> showKeyboard(
    WidgetTester tester,
    TextEditingController controller, {
    bool enabled = true,
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: LanguageService.instance,
        child: MaterialApp(
          home: Scaffold(
            body: MathKeyboard(controller: controller, enabled: enabled),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Keys expose actions and the active keyboard tab', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController(text: '12');
    addTearDown(controller.dispose);
    await showKeyboard(tester, controller);
    final backspace = tester.getSemantics(
      find.bySemanticsLabel('Удалить предыдущий символ'),
    );
    expect(backspace.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(backspace.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Числа и действия'))
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull(),
      isTrue,
    );
    await tester.tap(find.bySemanticsLabel('Удалить предыдущий символ'));
    expect(controller.text, '1');
    await tester.tap(find.bySemanticsLabel('Переменные и степени'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Квадратный корень'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Переменные и степени'))
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull(),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('Tab, Enter and Space operate keys without a pointer', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await showKeyboard(tester, controller);
    // Three layout tabs precede the first numeric key.
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(controller.text, '7');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(controller.text, '77');
  });

  testWidgets(
    'Disabled keys have no tap action and cannot edit or change tabs',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = TextEditingController(text: '12');
      addTearDown(controller.dispose);
      await showKeyboard(tester, controller, enabled: false);
      final clear = tester.getSemantics(
        find.bySemanticsLabel('Очистить ответ'),
      );
      expect(
        clear.getSemanticsData().flagsCollection.isEnabled.toBoolOrNull(),
        isFalse,
      );
      expect(clear.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      await tester.tap(find.bySemanticsLabel('Очистить ответ'));
      await tester.tap(find.bySemanticsLabel('Переменные и степени'));
      await tester.pumpAndSettle();
      expect(controller.text, '12');
      expect(find.bySemanticsLabel('Квадратный корень'), findsNothing);
      semantics.dispose();
    },
  );
}
