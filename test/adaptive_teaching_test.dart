import 'package:math_pilot/widgets/account_sync_card.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/models/exam_answer.dart';
import 'package:math_pilot/screens/exam_session_screen.dart';
import 'package:math_pilot/services/exam_progress.dart';
import 'design_layout_test.dart' show loadDesignFonts;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/services/adaptive_practice.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/cloud_sync_service.dart';
import 'package:math_pilot/widgets/topic_quick_check.dart';
import 'package:math_pilot/widgets/task_report_button.dart';

Task task(String id, String question, String answer, {List<String>? options}) =>
    Task(
      id: id,
      grade: 6,
      topic: 'Дроби',
      question: question,
      answer: answer,
      type: options == null ? TaskType.textInput : TaskType.multipleChoice,
      options: options,
    );
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LearningService.instance.init();
  });
  test(
    'Feedback identifies verified numerical patterns and handles invalid input',
    () {
      expect(
        AdaptivePractice.feedback(task('sign', '−3 + 1 = ?', '-2'), '2'),
        contains('знак противоположный'),
      );
      expect(
        AdaptivePractice.feedback(
          task('fraction', '1/2 + 1/3 = ?', '5/6'),
          '2/5',
        ),
        contains('числителей и знаменателей'),
      );
      expect(
        AdaptivePractice.feedback(
          task('percent', 'Найди 20% от 50', '10'),
          '1000',
        ),
        contains('100 раз'),
      );
      expect(
        AdaptivePractice.feedback(
          task('fraction', '1/2 + 1/3 = ?', '5/6'),
          '5/6',
        ),
        isEmpty,
      );
      expect(
        AdaptivePractice.feedback(
          task('invalid', '1/2 + 1/3 = ?', '5/6'),
          '1/0',
        ),
        isNotEmpty,
      );
      expect(
        AdaptivePractice.feedback(
          task('words', 'Как называется фигура?', 'Квадрат'),
          'Круг',
        ),
        isNot(contains('знак')),
      );
    },
  );
  test(
    'Sequence keeps all tasks and orders basic exercises before multi-step ones',
    () {
      final tasks = [
        task('hard', '(1 + 2) × (3 + 4) = ?', '21'),
        task('easy', '1 + 2 = ?', '3'),
      ];
      expect(AdaptivePractice.sequence(tasks).map((t) => t.id), [
        'easy',
        'hard',
      ]);
      expect(tasks.first.id, 'hard');
    },
  );
  test(
    'Cloud payload validation excludes credentials and enforces a smaller document limit',
    () {
      String backup(Map<String, dynamic> data) =>
          jsonEncode({'format': 'algeon-progress', 'version': 1, 'data': data});
      CloudSyncService.validateSize(backup({'current_grade': 6}));
      expect(
        () => CloudSyncService.validateSize(backup({'password': 'secret'})),
        throwsFormatException,
      );
      expect(
        () =>
            CloudSyncService.validateSize(backup({'user_name': 'x' * 800000})),
        throwsFormatException,
      );
    },
  );
  testWidgets(
    'Warmup confirms choices and ends after two questions without recording assessment',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicQuickCheck(
                tasks: [
                  task('a', '2 + 1 = ?', '3', options: ['3', '4']),
                  task('b', '2 + 2 = ?', '4', options: ['4', '5']),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Проверить понимание · 2 вопроса'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, '3'));
      await tester.pump();
      expect(find.text('Верно'), findsNothing);
      await tester.tap(find.text('Проверить ответ'));
      await tester.pumpAndSettle();
      expect(find.text('Верно'), findsOneWidget);
      await tester.ensureVisible(find.text('Следующий вопрос'));
      await tester.tap(find.text('Следующий вопрос'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, '4'));
      await tester.pump();
      await tester.tap(find.text('Проверить ответ'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Завершить разминку'));
      await tester.tap(find.text('Завершить разминку'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Разминка завершена'), findsOneWidget);
      expect(LearningService.instance.stats, isEmpty);
    },
  );
  testWidgets(
    'Reports show task identity and require explicit external submission',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskReportButton(taskId: 'test-42', question: '2 + 2 = ?'),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Сообщить об ошибке'));
      await tester.pumpAndSettle();
      expect(find.text('Задание: test-42'), findsOneWidget);
      expect(find.textContaining('Отправку нужно подтвердить'), findsOneWidget);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
    },
  );
  testWidgets(
    'Extended solution criteria persist and self assessment is counted once',
    (tester) async {
      await tester.runAsync(loadDesignFonts);
      final catalog = await tester.runAsync(ExamCatalog.load);
      final variant = catalog!.variants.firstWhere(
        (v) => v['id'] == 'profile-1',
      );
      final ids = variant['questionIds'] as List;
      final index = ids.indexWhere(
        (id) =>
            !ExamAnswer.canCheck(catalog.questions[id] as Map<String, dynamic>),
      );
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ExamSessionScreen(
            variantId: 'profile-1',
            initialQuestion: index + 1,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final theoryButton = find.text('К заданию');
      if (theoryButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(theoryButton);
        await tester.tap(theoryButton);
        await tester.pumpAndSettle();
      }
      final check = find.text('Перейти к сверке решения');
      await tester.ensureVisible(check);
      await tester.tap(check);
      await tester.pumpAndSettle();
      final correct = find.widgetWithText(TextButton, 'По моей сверке — верно');
      await tester.ensureVisible(correct);
      expect(tester.widget<TextButton>(correct).onPressed, isNull);
      for (final criterion in [
        'Учтены условия и ограничения',
        'Обоснован каждый шаг',
        'Проверены вычисления',
        'Даны все требуемые ответы',
      ]) {
        final tile = find.widgetWithText(CheckboxListTile, criterion);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }
      expect(
        (await ExamProgress.read('profile-1'))['records']['$index']['criteria'],
        hasLength(4),
      );
      await tester.ensureVisible(correct);
      await tester.tap(correct);
      await tester.pumpAndSettle();
      expect(tester.widget<TextButton>(correct).onPressed, isNull);
      expect(
        LearningService.instance.stats['exam:${ids[index]}']['attempts'],
        1,
      );
      final reviewed = find.text('Отметить как разобранное');
      await tester.ensureVisible(reviewed);
      await tester.tap(reviewed);
      await tester.pumpAndSettle();
      expect(
        (await ExamProgress.read(
          'profile-1',
        ))['records']['$index']['selfAssessed'],
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Account form fits a narrow screen with enlarged text', (
    tester,
  ) async {
    await tester.runAsync(loadDesignFonts);
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Inter'),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: Scaffold(
            body: SingleChildScrollView(child: AccountSyncCard()),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Аккаунт'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.ensureVisible(find.text('Создать аккаунт'));
    await tester.tap(find.text('Создать аккаунт'));
    await tester.pumpAndSettle();
    expect(find.text('Уже есть аккаунт? Войти'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
