import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:math_pilot/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/widgets/account_sync_card.dart';
import 'design_layout_test.dart' show loadDesignFonts;

Future<GlobalKey> openAccount(WidgetTester tester, {bool dark = false}) async {
  final boundary = GlobalKey();
  await tester.runAsync(loadDesignFonts);
  tester.view.physicalSize = const Size(320, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: MaterialApp(
        theme: dark ? buildDarkTheme() : buildLightTheme(),
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 844),
            textScaler: TextScaler.linear(1.4),
          ),
          child: Scaffold(
            body: SingleChildScrollView(child: AccountSyncCard()),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Аккаунт'));
  await tester.pumpAndSettle();
  return boundary;
}

Future<void> capture(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  if (Platform.environment['ALGEON_CAPTURE_ACCOUNT'] != '1') return;
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '/tmp/algeon-account-$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets(
    'Empty and malformed login is rejected before contacting authentication',
    (tester) async {
      final boundary = await openAccount(tester);
      final submit = find.widgetWithText(FilledButton, 'Войти');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Укажи электронную почту.'), findsOneWidget);
      expect(find.text('Введи пароль.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'wrong-email');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Проверь адрес: name@example.com'), findsOneWidget);
      expect(find.text('Вход пока недоступен. Попробуй позже.'), findsNothing);
      await capture(tester, boundary, 'login-error');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Registration preserves email, validates password and supports visibility',
    (tester) async {
      final boundary = await openAccount(tester, dark: true);
      await tester.enterText(
        find.byType(TextFormField).first,
        'student@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, '123');
      final mode = find.widgetWithText(TextButton, 'Создать аккаунт');
      await tester.ensureVisible(mode);
      await tester.tap(mode);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        'student@example.com',
      );
      final submit = find.widgetWithText(FilledButton, 'Создать аккаунт');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Нужно не менее 6 символов.'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      await tester.ensureVisible(find.byTooltip('Показать пароль'));
      await tester.tap(find.byTooltip('Показать пароль'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.tap(find.byTooltip('Скрыть пароль'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      expect(find.text('Вход пока недоступен. Попробуй позже.'), findsNothing);
      await capture(tester, boundary, 'registration');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Password reset validates only email and keyboard Next reaches password',
    (tester) async {
      await openAccount(tester);
      final reset = find.widgetWithText(TextButton, 'Забыли пароль?');
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(find.text('Укажи электронную почту.'), findsOneWidget);
      expect(find.text('Введи пароль.'), findsNothing);
      expect(
        find.text('Не удалось запросить письмо. Проверь адрес и соединение.'),
        findsNothing,
      );
      final email = find.byType(TextFormField).first;
      await tester.ensureVisible(email);
      await tester.tap(email);
      await tester.enterText(email, 'student@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).last)
            .focusNode
            .hasFocus,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Recovery action appears only when there is a previous local copy',
    (tester) async {
      await openAccount(tester);
      expect(find.text('Скопировать предыдущую копию'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      SharedPreferences.setMockInitialValues({
        'cloud_local_recovery': jsonEncode({
          'format': 'algeon-progress',
          'version': 1,
          'data': {'current_grade': 5},
        }),
      });
      await openAccount(tester);
      expect(find.text('Скопировать предыдущую копию'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
