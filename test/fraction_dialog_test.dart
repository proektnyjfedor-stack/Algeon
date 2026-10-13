import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'design_layout_test.dart' show loadDesignFonts;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/widgets/formula_answer_field.dart';

void main() {
  testWidgets('Fraction dialog fits a narrow screen with enlarged text', (
    tester,
  ) async {
    await tester.runAsync(loadDesignFonts);
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = TextEditingController();
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Inter'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Scaffold(body: MathInputToolbar(controller: controller)),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Вставить дробь'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (Platform.environment['ALGEON_CAPTURE_FRACTION'] == '1') {
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '/tmp/algeon-fraction-dialog.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets('Next focuses denominator and Done inserts the fraction', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MathInputToolbar(controller: controller)),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Вставить дробь'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '3');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).last)
          .focusNode
          .hasFocus,
      isTrue,
    );
    await tester.enterText(find.byType(TextField).last, '4');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.text, '3/4');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('Done keeps a zero denominator in the dialog with an error', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MathInputToolbar(controller: controller)),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Вставить дробь'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '3');
    await tester.enterText(find.byType(TextField).last, '0');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      find.text('Заполните оба поля. Знаменатель не равен нулю.'),
      findsOneWidget,
    );
    expect(controller.text, isEmpty);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('A removed toolbar never writes to its disposed controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    final visible = ValueNotifier(true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (_, show, _) => show
                ? MathInputToolbar(controller: controller)
                : const SizedBox(),
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Вставить дробь'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.enterText(find.byType(TextField).last, '2');
    visible.value = false;
    await tester.pump();
    controller.dispose();
    await tester.tap(find.text('Вставить'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    visible.dispose();
  });
}
