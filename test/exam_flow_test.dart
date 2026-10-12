import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/screens/exam_session_screen.dart';
import 'package:math_pilot/services/exam_progress.dart';

void main() {
  testWidgets(
    'Theory precedes answers, checking persists, proofs use self review',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() => ExamCatalog.load());
      tester.view.physicalSize = const Size(1280, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: ExamSessionScreen(variantId: 'profile-1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('К заданию'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('К заданию'));
      await tester.pumpAndSettle();
      final catalog = await ExamCatalog.load();
      final v = catalog.variants.firstWhere((v) => v['id'] == 'profile-1');
      final q = catalog.questions[(v['questionIds'] as List).first];
      await tester.enterText(find.byType(TextField), q['answer'] as String);
      await tester.tap(find.text('Проверить ответ'));
      await tester.pumpAndSettle();
      expect(find.text('Верно!'), findsOneWidget);
      expect(
        (await ExamProgress.read('profile-1'))['records']['0']['status'],
        'correct',
      );
      await tester.tap(find.widgetWithText(ActionChip, '15'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('К заданию'));
      await tester.pumpAndSettle();
      expect(find.text('Проверить ответ'), findsNothing);
      await tester.ensureVisible(find.text('Перейти к сверке решения'));
      await tester.tap(find.text('Перейти к сверке решения'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Отметить как разобранное'));
      await tester.tap(find.text('Отметить как разобранное'));
      await tester.pumpAndSettle();
      expect(
        (await ExamProgress.read('profile-1'))['records']['14']['status'],
        'reviewed',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        const MaterialApp(home: ExamSessionScreen(variantId: 'profile-1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Задание 15'), findsOneWidget);
      expect(find.text('Разобрано 2 из 20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
