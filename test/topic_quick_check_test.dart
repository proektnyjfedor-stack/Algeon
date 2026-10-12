import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/widgets/topic_quick_check.dart';
import 'package:math_pilot/widgets/math_text.dart';

void main() {
  const length = Task(
    id: 'length',
    grade: 5,
    topic: 'Периметр',
    question: 'Найди периметр квадрата со стороной 3 см.',
    type: TaskType.textInput,
    answer: '12',
    unit: 'см',
    explanationSteps: ['У квадрата четыре равные стороны: 4 × 3 = 12.'],
  );
  const sum = Task(
    id: 'sum',
    grade: 5,
    topic: 'Сложение',
    question: '2 + 3 = ?',
    type: TaskType.textInput,
    answer: '5',
  );
  Widget host(List<Task> tasks) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: TopicQuickCheck(tasks: tasks)),
    ),
  );

  testWidgets('An empty topic offers no empty warmup', (tester) async {
    await tester.pumpWidget(host([]));
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('One-question warmup shows units and requires a numeric answer', (
    tester,
  ) async {
    await tester.pumpWidget(host([length]));
    await tester.tap(find.text('Проверить понимание · 1 вопрос'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.suffixText, 'см');
    expect(field.decoration!.helperText, contains('без единицы'));
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    await tester.tap(find.text('Проверить ответ'));
    await tester.pumpAndSettle();
    expect(find.text('Верно'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is MathText && w.text == 'Ответ: 12 см'),
      findsOneWidget,
    );
    expect(find.text('Завершить разминку'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    await tester.ensureVisible(find.text('Завершить разминку'));
    await tester.tap(find.text('Завершить разминку'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Разминка завершена'), findsOneWidget);
  });

  testWidgets(
    'Changing topic resets a checked answer instead of reusing old questions',
    (tester) async {
      await tester.pumpWidget(host([length]));
      await tester.tap(find.text('Проверить понимание · 1 вопрос'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      await tester.tap(find.text('Проверить ответ'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(host([sum]));
      await tester.pumpAndSettle();
      expect(find.text('Верно'), findsNothing);
      await tester.tap(find.text('Проверить понимание · 1 вопрос'));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      expect(field.decoration!.suffixText, isNull);
      expect(field.readOnly, isFalse);
      expect(
        find.byWidgetPredicate((w) => w is MathText && w.text == '2 + 3 = ?'),
        findsOneWidget,
      );
    },
  );
}
