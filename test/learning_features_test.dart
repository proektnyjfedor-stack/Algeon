import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/mock_exam_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'package:math_pilot/screens/study_hub_screen.dart';
import 'package:math_pilot/screens/diagnostic_screen.dart';
import 'package:math_pilot/screens/mock_exam_screen.dart';
import 'package:math_pilot/widgets/formula_answer_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final h = LearningService.instance;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    h.clock = () => DateTime(2026, 10, 12, 12);
    await h.init();
    await ProgressService.init();
  });
  tearDown(() {
    h.clock = DateTime.now;
  });
  test(
    'Learning attempts are serialized, deduplicated, and reviews respect intervals',
    () async {
      final task = getAllTasks().first;
      Future<void> record(String attempt, bool correct) => h.record(
        attemptId: attempt,
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: LearningService.taskRef(task),
        correct: correct,
        input: correct ? task.answer : '0',
      );
      await Future.wait([
        record('first', false),
        record('first', false),
        record('fix', true),
      ]);
      expect(h.stats[task.id]['attempts'], 2);
      expect(h.mistakes[task.id]['stage'], 1);
      expect(h.reviews(dueOnly: true), isEmpty);
      await record('too-soon', true);
      expect(h.mistakes[task.id]['stage'], 1);
      h.clock = () => DateTime(2026, 10, 13, 12);
      await record('one-day', true);
      expect(h.mistakes[task.id]['stage'], 2);
      h.clock = () => DateTime(2026, 10, 16, 12);
      await record('three-days', true);
      expect(h.mistakes[task.id]['stage'], 3);
      h.clock = () => DateTime(2026, 10, 23, 12);
      await record('seven-days', true);
      expect(h.mistakes[task.id]['stage'], 4);
      expect(h.reviews(), isEmpty);
      await record('new-error', false);
      expect(h.mistakes[task.id]['stage'], 0);
      await h.init();
      expect(h.stats[task.id]['attempts'], 7);
      expect(h.topicStats().single['attempts'], 7);
      expect(h.topicStats().single['recent'], isA<List<bool>>());
    },
  );
  test(
    'Plan prioritizes due errors, balances topics, stays stable, and refreshes daily',
    () async {
      final catalog = await ExamCatalog.load();
      final task = getTasksByGrade(7).last;
      await h.record(
        attemptId: 'due',
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: LearningService.taskRef(task),
        correct: false,
        input: '0',
      );
      await h.configurePlan({
        'track': 'school',
        'grade': 7,
        'daily': 10,
        'goal': 'Подтянуть математику',
        'target': '2027-06-01',
      });
      final today = await h.dailyTasks(catalog);
      expect(today.length, 10);
      expect(today.first['id'], task.id);
      expect(today.map((r) => r['id']).toSet().length, 10);
      expect(
        today.map((r) => getTaskById(r['id'])!.topic).toSet().length,
        greaterThan(3),
      );
      expect(await h.dailyTasks(catalog), today);
      await h.configurePlan({
        'track': 'profile',
        'grade': 11,
        'daily': 10,
        'goal': 'Профиль',
        'target': '2027-06-01',
      });
      final exam = await h.dailyTasks(catalog);
      expect(exam.map((r) => r['slot']).toSet().length, 10);
      expect(exam.every(LearningService.validRef), true);
      h.clock = () => DateTime(2026, 10, 13);
      expect((await h.dailyTasks(catalog)).length, 10);
    },
  );
  test(
    'Daily school plan rotates solved tasks and excludes reviews from another class',
    () async {
      final catalog = await ExamCatalog.load();
      final other = getTasksByGrade(3).first;
      await h.record(
        attemptId: 'other-class',
        id: other.id,
        topic: LearningService.taskTopic(other),
        ref: LearningService.taskRef(other),
        correct: false,
        input: '0',
      );
      await h.configurePlan({
        'track': 'school',
        'grade': 7,
        'daily': 5,
        'goal': 'Регулярная практика',
        'target': '2027-06-01',
      });
      final first = await h.dailyTasks(catalog);
      expect(first.every((r) => getTaskById(r['id'])!.grade == 7), true);
      for (final ref in first) {
        final task = getTaskById(ref['id'])!;
        await h.record(
          attemptId: 'today:${task.id}',
          id: task.id,
          topic: LearningService.taskTopic(task),
          ref: ref,
          correct: true,
          input: task.answer,
        );
      }
      expect(first.every(h.completedToday), true);
      expect(await h.dailyTasks(catalog), first);
      h.clock = () => DateTime(2026, 10, 13, 12);
      expect(first.any(h.completedToday), false);
      final next = await h.dailyTasks(catalog);
      expect(
        next
            .map((r) => r['id'])
            .toSet()
            .intersection(first.map((r) => r['id']).toSet()),
        isEmpty,
      );
    },
  );

  testWidgets('Diagnostic selection stays editable until confirmation', (
    tester,
  ) async {
    final task = getTasksByGrade(
      5,
    ).firstWhere((t) => t.options != null && t.options!.length > 1);
    await h.saveDiagnostic({
      'ids': [task.id],
      'answers': <String, dynamic>{},
      'grade': 5,
      'startedAt': '2026-10-12T12:30:00',
    });
    await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
    await tester.pumpAndSettle();
    final choices = find.byType(OutlinedButton);
    await tester.ensureVisible(choices.first);
    await tester.tap(choices.first);
    await tester.pumpAndSettle();
    expect((h.diagnostic['answers'] as Map), isEmpty);
    await tester.ensureVisible(choices.at(1));
    await tester.tap(choices.at(1));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Посмотреть результат'));
    await tester.tap(find.text('Посмотреть результат'));
    await tester.pumpAndSettle();
    expect(h.diagnostic['answers'][task.id]['input'], task.options![1]);
    expect(h.stats[task.id]['attempts'], 1);
    expect(tester.takeException(), isNull);
  });

  test(
    'Diagnostics cover as many distinct topics as their per-class allocation permits',
    () {
      for (var grade = 1; grade <= 11; grade++) {
        final selected = LearningService.diagnosticTasks(grade);
        for (final g in grade == 1 ? [1] : [grade - 1, grade]) {
          final available = getTasksByGrade(
            g,
          ).map((t) => t.topic).toSet().length;
          final allocation = g == grade ? (grade == 1 ? 9 : 6) : 3;
          expect(
            selected
                .where((t) => t.grade == g)
                .map((t) => t.topic)
                .toSet()
                .length,
            available < allocation ? available : allocation,
            reason: 'Diagnostic for class $grade, material of class $g',
          );
        }
      }
    },
  );

  test(
    'Diagnostic uses nine unique tasks from different topics and persists',
    () async {
      for (final grade in [1, 5, 11]) {
        final tasks = LearningService.diagnosticTasks(grade);
        expect(tasks.length, 9);
        expect(tasks.every((task) => task.grade <= grade), true);
        expect(tasks.map((t) => t.id).toSet().length, 9);
        expect(tasks.map((t) => t.topic).toSet().length, greaterThan(2));
      }
      final tasks = LearningService.diagnosticTasks(5);
      await h.saveDiagnostic({
        'ids': tasks.map((t) => t.id).toList(),
        'answers': {
          tasks.first.id: {'correct': true, 'input': tasks.first.answer},
        },
        'grade': 5,
        'startedAt': '2026-10-12T12:00:00',
      });
      await h.init();
      expect((h.diagnostic['answers'] as Map).length, 1);
      final raw =
          jsonDecode(
                (await SharedPreferences.getInstance()).getString(
                  LearningService.key,
                )!,
              )
              as Map;
      raw['dailyPlan'] = {
        'day': '2026-10-12',
        'items': [
          {'kind': 'exam', 'id': 'fake', 'variant': '../../bad'},
        ],
      };
      expect(
        () => LearningService.validate(jsonEncode(raw)),
        throwsFormatException,
      );
    },
  );
  test(
    'Timer survives reloads and rejects malformed imported deadlines',
    () async {
      final now = DateTime(2026, 10, 12, 12);
      final s = MockExamService.start('profile-1', now);
      s['answers']['0'] = '1/2';
      await MockExamService.save(s);
      final read = (await MockExamService.read('profile-1'))!;
      expect(read['answers']['0'], '1/2');
      expect(
        MockExamService.remaining(
          read,
          now.add(const Duration(minutes: 10)),
        ).inMinutes,
        225,
      );
      expect(
        MockExamService.remaining(read, now.add(const Duration(hours: 4))),
        Duration.zero,
      );
      expect(MockExamService.minutes('base'), 180);
      s['deadline'] += 1;
      expect(
        () => MockExamService.validate(jsonEncode(s), 'profile-1'),
        throwsFormatException,
      );
    },
  );
  test(
    'Backups include the learning journal and mock, reset clears both',
    () async {
      final task = getAllTasks().first;
      await h.record(
        attemptId: 'one',
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: LearningService.taskRef(task),
        correct: false,
        input: '0',
      );
      await MockExamService.save(
        MockExamService.start('oge-1', DateTime(2026, 10, 12)),
      );
      final backup = await BackupService.export();
      expect(
        BackupService.validate(backup).containsKey(LearningService.key),
        true,
      );
      await ProgressService.resetProgress();
      expect(h.stats, isEmpty);
      expect(await MockExamService.read('oge-1'), isNull);
      await BackupService.restore(backup);
      expect(h.mistakes.length, 1);
      expect(await MockExamService.read('oge-1'), isNotNull);
    },
  );
  test('Formula editing replaces selection and preserves cursor', () {
    final c = TextEditingController(text: '12+34')
      ..selection = const TextSelection(baseOffset: 3, extentOffset: 5);
    FormulaEditing.insert(c, '1/2');
    expect(c.text, '12+1/2');
    expect(c.selection.baseOffset, 6);
    FormulaEditing.backspace(c);
    expect(c.text, '12+1/');
    expect(FormulaEditing.fraction('a+b', 'c+d'), '(a+b)/(c+d)');
    expect(FormulaEditing.fraction('1', '2'), '1/2');
    c.dispose();
  });
  testWidgets(
    'Fraction builder validates denominator and creates a visible preview',
    (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FormulaAnswerField(controller: controller)),
        ),
      );
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), '1');
      await tester.enterText(fields.at(2), '0');
      await tester.tap(find.text('Вставить'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Знаменатель не равен нулю'), findsOneWidget);
      await tester.enterText(fields.at(2), '2');
      await tester.tap(find.text('Вставить'));
      await tester.pumpAndSettle();
      expect(controller.text, '1/2');
      expect(find.text('Запись ответа'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
  testWidgets('Study sections and diagnostic intro fit a narrow phone', (
    tester,
  ) async {
    await tester.runAsync(() => ExamCatalog.load());
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = getTasksByGrade(7).first;
    await h.record(
      attemptId: 'phone',
      id: task.id,
      topic: LearningService.taskTopic(task),
      ref: LearningService.taskRef(task),
      correct: false,
      input: '1/2',
    );
    await h.configurePlan({
      'track': 'school',
      'grade': 7,
      'daily': 10,
      'goal': 'Подготовка',
      'target': '2027-06-01',
    });
    for (var tab = 0; tab < 3; tab++) {
      await tester.pumpWidget(
        MaterialApp(
          home: StudyHubScreen(key: ValueKey(tab), initialTab: tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Начать диагностику'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Mock hides all solutions until submission and expired attempts finish once',
    (tester) async {
      await tester.runAsync(() => ExamCatalog.load());
      final now = DateTime.now();
      final s = MockExamService.start(
        'base-1',
        now.subtract(const Duration(minutes: 179)),
      );
      s['answers']['0'] = '0';
      await MockExamService.save(s);
      await tester.pumpWidget(
        const MaterialApp(home: MockExamScreen(variantId: 'base-1')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Полное решение в источнике'), findsNothing);
      expect(find.text('Проверить ответ'), findsNothing);
      expect(find.text('Ответ для сверки:'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      final expired = MockExamService.start(
        'base-2',
        now.subtract(const Duration(hours: 4)),
      );
      await MockExamService.save(expired);
      await tester.pumpWidget(
        const MaterialApp(home: MockExamScreen(variantId: 'base-2')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Экзамен завершён'), findsOneWidget);
      expect((await MockExamService.read('base-2'))!['submitted'], isNotNull);
      final count = h.stats.values.fold<int>(
        0,
        (sum, r) => sum + (r['attempts'] as int),
      );
      expect(count, 21);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        const MaterialApp(home: MockExamScreen(variantId: 'base-2')),
      );
      await tester.pumpAndSettle();
      expect(
        h.stats.values.fold<int>(0, (sum, r) => sum + (r['attempts'] as int)),
        21,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'A first diagnostic starts in the selected class without replacing a result',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('7 класс').last);
      await tester.tap(find.text('7 класс').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Начать диагностику'));
      await tester.tap(find.text('Начать диагностику'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(h.diagnostic['grade'], 7);
      expect(find.textContaining('Задание 1 из 9'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Restarting a completed diagnostic can be cancelled and preserves the selected class',
    (tester) async {
      final tasks = LearningService.diagnosticTasks(7);
      await h.saveDiagnostic({
        'ids': tasks.map((t) => t.id).toList(),
        'answers': {
          for (final t in tasks) t.id: {'correct': true, 'input': t.answer},
        },
        'grade': 7,
        'startedAt': '2026-10-12T12:00:00',
      });
      await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Пройти ещё раз'),
        300,
      );
      await tester.tap(find.text('Пройти ещё раз'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect((h.diagnostic['answers'] as Map).length, 9);
      await tester.tap(find.text('Пройти ещё раз'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Пройти заново'));
      await tester.pumpAndSettle();
      expect(h.diagnostic['grade'], 7);
      expect(h.diagnostic['answers'], isEmpty);
      expect(find.textContaining('Задание 1 из 9'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Recommendations keep the same topic in different classes separate',
    (tester) async {
      final all = getAllTasks();
      final first = all.firstWhere(
        (a) => all.any((b) => b.topic == a.topic && b.grade != a.grade),
      );
      final second = all.firstWhere(
        (b) => b.topic == first.topic && b.grade != first.grade,
      );
      await h.saveDiagnostic({
        'ids': [first.id, second.id],
        'answers': {
          for (final t in [first, second])
            t.id: {'correct': false, 'input': ''},
        },
        'grade': 11,
        'startedAt': '2026-10-12T12:00:00',
      });
      await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
      await tester.pumpAndSettle();
      expect(
        find.text('${first.grade} класс · повторить и закрепить'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('${second.grade} класс · повторить и закрепить'),
        200,
      );
      expect(
        find.text('${second.grade} класс · повторить и закрепить'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Diagnostic resumes saved answers and finishes with a real error review',
    (tester) async {
      final tasks = LearningService.diagnosticTasks(5);
      final answers = <String, dynamic>{};
      for (final task in tasks.take(8)) {
        answers[task.id] = {'correct': true, 'input': task.answer};
        await h.record(
          attemptId: 'diagnostic:2026-10-12T12:00:00:${task.id}',
          id: task.id,
          topic: LearningService.taskTopic(task),
          ref: LearningService.taskRef(task),
          correct: true,
          input: task.answer,
        );
      }
      await h.saveDiagnostic({
        'ids': tasks.map((t) => t.id).toList(),
        'answers': answers,
        'grade': 5,
        'startedAt': '2026-10-12T12:00:00',
      });
      await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Задание 9 из 9'), findsOneWidget);
      await tester.ensureVisible(find.text('Пока не знаю · пропустить'));
      await tester.tap(find.text('Пока не знаю · пропустить'));
      await tester.pumpAndSettle();
      expect(find.text('Верно 8 из 9'), findsOneWidget);
      expect(h.mistakes.containsKey(tasks.last.id), true);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MaterialApp(home: DiagnosticScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Твоя отправная точка'), findsOneWidget);
      expect(h.stats[tasks.last.id]['attempts'], 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Mock final submission checks a short answer and locks it', (
    tester,
  ) async {
    final catalog = (await tester.runAsync(() => ExamCatalog.load()))!;
    tester.view.physicalSize = const Size(1280, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final variant = catalog.variants.firstWhere((v) => v['id'] == 'profile-1');
    final q = catalog.questions[(variant['questionIds'] as List).first];
    await MockExamService.save(
      MockExamService.start('profile-1', DateTime.now()),
    );
    await tester.pumpWidget(
      const MaterialApp(home: MockExamScreen(variantId: 'profile-1')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), q['answer'] as String);
    await tester.ensureVisible(find.text('Завершить экзамен'));
    await tester.tap(find.text('Завершить экзамен'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Без ответа: 19'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Завершить'));
    await tester.pumpAndSettle();
    expect(find.text('Экзамен завершён'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.textContaining('Краткие ответы: 1 из 13 верно.'),
      findsOneWidget,
    );
    expect(h.stats['exam:${q['id']}']['correct'], 1);
    expect((await MockExamService.read('profile-1'))!['journaled'], true);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
