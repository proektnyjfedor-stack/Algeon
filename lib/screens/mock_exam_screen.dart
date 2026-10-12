import '../widgets/learning_note.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/exam_catalog.dart';
import '../data/exam_theory.dart';
import '../models/exam_answer.dart';
import '../services/mock_exam_service.dart';
import '../services/learning_service.dart';
import '../services/files/exam_link.dart';
import '../widgets/exam_html.dart';
import '../widgets/formula_answer_field.dart';
import '../widgets/math_text.dart';

class MockExamScreen extends StatefulWidget {
  const MockExamScreen({super.key, required this.variantId});
  final String variantId;
  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  ExamCatalog? catalog;
  Map<String, dynamic>? variant, session;
  final input = TextEditingController();
  final scroll = ScrollController();
  Timer? timer;
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    timer?.cancel();
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  List get ids => variant!['questionIds'] as List;
  int get index => session?['index'] as int? ?? 0;
  bool get submitted => session?['submitted'] != null;
  Map<String, dynamic> get question =>
      catalog!.questions[ids[index]] as Map<String, dynamic>;
  Map get answers => session?['answers'] as Map? ?? {};
  List get flags => session?['flags'] as List? ?? [];
  Future<void> load() async {
    try {
      final c = await ExamCatalog.load();
      final v = c.variants
          .where((v) => v['id'] == widget.variantId)
          .firstOrNull;
      if (v == null) throw StateError('Missing variant');
      final saved = await MockExamService.read(widget.variantId);
      if (!mounted) return;
      setState(() {
        catalog = c;
        variant = v;
        session = saved;
        input.text = answers['$index'] as String? ?? '';
      });
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || session == null || submitted) return;
        if (MockExamService.remaining(session!, DateTime.now()) ==
            Duration.zero) {
          finish(expired: true);
        } else {
          setState(() {});
        }
      });
      if (saved != null) {
        if (submitted) {
          setState(() => busy = true);
          try {
            await recordResults();
          } finally {
            if (mounted) setState(() => busy = false);
          }
        } else if (MockExamService.remaining(saved, DateTime.now()) ==
            Duration.zero) {
          await finish(expired: true);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Не удалось открыть экзамен. Попробуйте ещё раз.',
        );
      }
    }
  }

  Future<bool> persist() async {
    try {
      await MockExamService.save(session!);
      return true;
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Не удалось сохранить ответы. Проверьте локальное хранилище.',
        );
      }
      return false;
    }
  }

  Future<void> start() async {
    if (busy) return;
    setState(() => busy = true);
    session = MockExamService.start(widget.variantId, DateTime.now());
    input.clear();
    final saved = await persist();
    if (!saved) session = null;
    if (mounted) setState(() => busy = false);
  }

  void draft(String value) {
    answers['$index'] = value;
    unawaited(persist());
  }

  Future<void> move(int next) async {
    if (busy) return;
    if (!submitted) answers['$index'] = input.text;
    setState(() {
      session!['index'] = next;
      input.text = answers['$next'] as String? ?? '';
    });
    if (scroll.hasClients) scroll.jumpTo(0);
    await persist();
  }

  Future<void> recordResults() async {
    if (session!['journaled'] == true) return;
    for (var i = 0; i < ids.length; i++) {
      final q = catalog!.questions[ids[i]] as Map<String, dynamic>;
      if (!ExamAnswer.canCheck(q)) continue;
      final answer = answers['$i'] as String? ?? '';
      await LearningService.instance.record(
        attemptId: 'mock:${session!['started']}:${widget.variantId}:${q['id']}',
        id: 'exam:${q['id']}',
        topic: LearningService.examTopic(q),
        ref: LearningService.examRef(q, widget.variantId),
        correct:
            answer.trim().isNotEmpty &&
            ExamAnswer.matches(answer, q['answer'] as String),
        input: answer,
      );
    }
    session!['journaled'] = true;
    if (!await persist()) session!.remove('journaled');
  }

  Future<void> finish({bool expired = false}) async {
    if (busy || submitted || session == null) return;
    setState(() => busy = true);
    try {
      if (!expired) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Завершить экзамен?'),
            content: Text(
              'Без ответа: ${ids.length - answers.values.where((v) => (v as String).trim().isNotEmpty).length}. После завершения изменить ответы нельзя.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Продолжить'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Завершить'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      answers['$index'] = input.text;
      session!['submitted'] = DateTime.now().millisecondsSinceEpoch;
      if (!await persist()) {
        session!.remove('submitted');
        return;
      }
      await recordResults();
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Результат сохранён, но история обучения не обновилась. Открой экзамен снова для повторной записи.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String timeLabel() {
    final duration = MockExamService.remaining(session!, DateTime.now());
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget chips() => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: List.generate(
      ids.length,
      (i) => ActionChip(
        backgroundColor: i == index
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        label: Text(
          '${i + 1}${flags.contains(i)
              ? ' ⚑'
              : (answers['$i'] as String? ?? '').trim().isNotEmpty
              ? ' •'
              : ''}',
        ),
        onPressed: busy ? null : () => move(i),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () async {
          if (session != null) await persist();
          if (context.mounted) context.go('/exams');
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        variant == null
            ? 'Пробный экзамен'
            : '${examLabels[variant!['track']]} · №${variant!['number']}',
      ),
    ),
    body: variant == null
        ? Center(
            child: error == null
                ? const CircularProgressIndicator()
                : Text(error!),
          )
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(24),
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (session == null) ...[
                    Text(
                      'Пробный экзамен',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${ids.length} заданий · ${MockExamService.minutes(variant!['track'] as String)} минут',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Без подсказок. Можно пропускать задания и возвращаться к ним. Разбор откроется после завершения.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Таймер идёт и после закрытия страницы. Ответы сохраняются.',
                    ),
                    const LearningNote(
                      title: 'Как проверяется результат',
                      text:
                          'Краткие ответы проверяются автоматически. Развёрнутые решения сверь с источником. Официальный балл не выставляется.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: busy ? null : start,
                      child: const Text('Начать экзамен'),
                    ),
                  ] else ...[
                    if (!submitted) ...[
                      Text(
                        timeLabel(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Text('Осталось времени'),
                      const SizedBox(height: 12),
                      chips(),
                      const SizedBox(height: 20),
                      Text(
                        'Задание ${index + 1}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if ((question['contextHtml'] as String? ?? '').isNotEmpty)
                        ExamHtml(question['contextHtml'] as String),
                      ExamHtml(question['questionHtml'] as String),
                      const SizedBox(height: 20),
                      FormulaAnswerField(
                        controller: input,
                        maxLines: ExamAnswer.canCheck(question) ? 1 : 5,
                        maxLength: ExamAnswer.canCheck(question) ? 100 : 10000,
                        onChanged: draft,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: ExamAnswer.canCheck(question)
                              ? 'Краткий ответ'
                              : 'Решение или заметки',
                          helperText: 'Формат ответа — в условии.',
                        ),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Вернуться к заданию'),
                        value: flags.contains(index),
                        onChanged: busy
                            ? null
                            : (value) {
                                setState(() {
                                  if (value == true) {
                                    flags.add(index);
                                  } else {
                                    flags.remove(index);
                                  }
                                });
                                unawaited(persist());
                              },
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton(
                            onPressed: busy || index == 0
                                ? null
                                : () => move(index - 1),
                            child: const Text('Назад'),
                          ),
                          FilledButton(
                            onPressed: busy || index == ids.length - 1
                                ? null
                                : () => move(index + 1),
                            child: const Text('Дальше'),
                          ),
                          TextButton(
                            onPressed: busy ? null : () => finish(),
                            child: const Text('Завершить экзамен'),
                          ),
                        ],
                      ),
                    ] else
                      ...results(),
                  ],
                ],
              ),
            ),
          ),
  );
  List<Widget> results() {
    final automatic = ids
        .map((id) => catalog!.questions[id] as Map<String, dynamic>)
        .where(ExamAnswer.canCheck)
        .length;
    var correct = 0, empty = 0;
    for (var i = 0; i < ids.length; i++) {
      final q = catalog!.questions[ids[i]] as Map<String, dynamic>;
      final value = answers['$i'] as String? ?? '';
      if (value.trim().isEmpty) {
        empty++;
      } else if (ExamAnswer.canCheck(q) &&
          ExamAnswer.matches(value, q['answer'] as String)) {
        correct++;
      }
    }
    final q = question;
    final value = answers['$index'] as String? ?? '';
    final canCheck = ExamAnswer.canCheck(q);
    final ok =
        value.trim().isNotEmpty &&
        canCheck &&
        ExamAnswer.matches(value, q['answer'] as String);
    final guide = examGuide(q['track'] as String, q['slot'] as int);
    return [
      Text(
        'Экзамен завершён',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 12),
      Text(
        'Краткие ответы: $correct из $automatic верно.\nБез ответа: $empty. Для самостоятельной сверки: ${ids.length - automatic}.',
      ),
      const SizedBox(height: 8),
      const Text('Это не официальный балл. Ошибки — в разделе «Мои ошибки».'),
      const SizedBox(height: 20),
      chips(),
      const SizedBox(height: 24),
      Text(
        'Разбор задания ${index + 1}',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      if ((q['contextHtml'] as String? ?? '').isNotEmpty)
        ExamHtml(q['contextHtml'] as String),
      ExamHtml(q['questionHtml'] as String),
      const SizedBox(height: 14),
      Text(
        canCheck
            ? (ok
                  ? '✓ Верно'
                  : value.isEmpty
                  ? 'Ответ пропущен'
                  : 'Есть ошибка')
            : 'Развёрнутое решение · проверь самостоятельно',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      const Text('Твой ответ:'),
      MathText(value.isEmpty ? 'Не записан' : value),
      const SizedBox(height: 8),
      const Text('Ответ для сверки:'),
      MathText(
        (q['answer'] as String).isEmpty
            ? 'Смотри полное решение в источнике'
            : q['answer'] as String,
      ),
      const SizedBox(height: 18),
      Text(guide.title, style: Theme.of(context).textTheme.titleLarge),
      MathText(guide.text),
      if (canCheck && (q['solutionHtml'] as String? ?? '').isNotEmpty)
        ExamHtml(q['solutionHtml'] as String),
      TextButton.icon(
        onPressed: () => openExamLink(q['sourceUrl'] as String),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Полное решение в источнике'),
      ),
      TextButton(
        onPressed: () => context.push(
          '/exams/${widget.variantId}?question=${index + 1}&retry=1',
        ),
        child: const Text('Открыть разбор'),
      ),
      TextButton(
        onPressed: () => context.go('/study?tab=1'),
        child: const Text('Открыть мои ошибки'),
      ),
      const Divider(),
      TextButton(
        onPressed: busy
            ? null
            : () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Начать новую попытку?'),
                    content: const Text(
                      'Ответы текущей попытки заменятся. Статистика и ошибки останутся в истории обучения.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Начать'),
                      ),
                    ],
                  ),
                );
                if (yes == true && mounted) await start();
              },
        child: const Text('Решить вариант заново'),
      ),
    ];
  }
}
