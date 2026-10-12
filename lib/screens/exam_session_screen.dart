import '../widgets/task_report_button.dart';
import '../widgets/bookmark_button.dart';
import '../services/learning_service.dart';
import '../widgets/formula_answer_field.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/exam_catalog.dart';
import '../data/exam_theory.dart';
import '../models/exam_answer.dart';
import '../services/exam_progress.dart';
import '../services/files/exam_link.dart';
import '../widgets/exam_html.dart';
import '../widgets/math_text.dart';

class ExamSessionScreen extends StatefulWidget {
  const ExamSessionScreen({
    super.key,
    required this.variantId,
    this.initialQuestion,
    this.retry = false,
  });
  final String variantId;
  final int? initialQuestion;
  final bool retry;

  @override
  State<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends State<ExamSessionScreen> {
  final String attemptSession = DateTime.now().microsecondsSinceEpoch
      .toString();
  ExamCatalog? catalog;
  Map<String, dynamic>? variant;
  Map<String, dynamic> records = {};
  int index = 0;
  bool theory = true, revealed = false, summary = false, saving = false;
  String? error;
  final answer = TextEditingController();
  final scroll = ScrollController();
  Timer? draftTimer;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant ExamSessionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variantId != widget.variantId ||
        oldWidget.initialQuestion != widget.initialQuestion ||
        oldWidget.retry != widget.retry) {
      draftTimer?.cancel();
      catalog = null;
      variant = null;
      records = {};
      index = 0;
      theory = true;
      revealed = false;
      summary = false;
      error = null;
      answer.clear();
      load();
    }
  }

  Future<void> load() async {
    try {
      final c = await ExamCatalog.load();
      final v = c.variants
          .where((v) => v['id'] == widget.variantId)
          .firstOrNull;
      if (v == null) throw StateError('Вариант не найден');
      final saved = await ExamProgress.read(widget.variantId);
      if (!mounted) return;
      setState(() {
        catalog = c;
        variant = v;
        records = Map<String, dynamic>.from(saved['records'] as Map? ?? {});
        index =
            (widget.initialQuestion != null
                    ? widget.initialQuestion! - 1
                    : ((saved['index'] as int?) ?? 0))
                .clamp(0, (v['questionIds'] as List).length - 1);
      });
      if (widget.retry) records.remove('$index');
      answer.text = (records['$index'] as Map?)?['input'] as String? ?? '';
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Не удалось открыть вариант. Вернитесь к списку и попробуйте снова.',
        );
      }
    }
  }

  @override
  void dispose() {
    draftTimer?.cancel();
    answer.dispose();
    scroll.dispose();
    super.dispose();
  }

  List get ids => variant!['questionIds'] as List;
  Map<String, dynamic> get question =>
      catalog!.questions[ids[index]] as Map<String, dynamic>;
  Map get record => records['$index'] as Map? ?? {};
  bool get automatic => ExamAnswer.canCheck(question);
  Future<void> save() async {
    try {
      await ExamProgress.save(widget.variantId, {
        'index': index,
        'records': records,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Не удалось сохранить прогресс. Проверьте доступность локального хранилища.',
            ),
          ),
        );
      }
    }
  }

  Future<void> check() async {
    if (saving || record['status'] != null || answer.text.trim().isEmpty) {
      return;
    }
    setState(() => saving = true);
    records['$index'] = {
      'input': answer.text,
      'status': ExamAnswer.matches(answer.text, question['answer'] as String)
          ? 'correct'
          : 'wrong',
    };
    await save();
    try {
      await LearningService.instance.record(
        attemptId:
            'training:$attemptSession:$index:${DateTime.now().microsecondsSinceEpoch}',
        id: 'exam:${question['id']}',
        topic: LearningService.examTopic(question),
        ref: LearningService.examRef(question, widget.variantId),
        correct: records['$index']['status'] == 'correct',
        input: answer.text,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ответ проверен, но историю обучения сохранить не удалось.',
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        saving = false;
        revealed = true;
      });
    }
  }

  Future<void> selfAssess(bool correct) async {
    if (saving || record['selfAssessed'] == true) return;
    setState(() => saving = true);
    try {
      await LearningService.instance.record(
        attemptId: 'self:$attemptSession:$index',
        id: 'exam:${question['id']}',
        topic: LearningService.examTopic(question),
        ref: LearningService.examRef(question, widget.variantId),
        correct: correct,
        input: answer.text,
      );
      records['$index'] = {
        ...record,
        'input': answer.text,
        'selfAssessed': true,
        'selfCorrect': correct,
      };
      await save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              correct
                  ? 'Самооценка сохранена.'
                  : 'Задание добавлено в мои ошибки.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить самооценку.')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> move(int next) async {
    if (saving) return;
    final old = Map<String, dynamic>.from(record);
    old['input'] = answer.text;
    records['$index'] = old;
    setState(() {
      index = next;
      theory = true;
      revealed = false;
      summary = false;
      answer.text = (records['$index'] as Map?)?['input'] as String? ?? '';
    });
    if (scroll.hasClients) scroll.jumpTo(0);
    await save();
  }

  Widget source(String url, String label) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: () => openExamLink(url),
      icon: const Icon(Icons.open_in_new, size: 18),
      label: Text(label),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (variant == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/exams'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Экзамены'),
        ),
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Padding(padding: const EdgeInsets.all(24), child: Text(error!)),
        ),
      );
    }
    final q = question;
    final guide = examGuide(variant!['track'] as String, q['slot'] as int);
    final status = record['status'];
    final done = records.values
        .where((r) => (r as Map)['status'] != null)
        .length;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TaskReportButton(
            taskId: 'exam:${q['id']}',
            question:
                'Вариант ${widget.variantId}, задание ${index + 1}\n${q['sourceUrl']}',
          ),
          BookmarkButton(id: 'exam:${widget.variantId}:${index + 1}'),
        ],
        leading: IconButton(
          onPressed: () async {
            await save();
            if (context.mounted) context.go('/exams');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          '${examLabels[variant!['track']]} · №${variant!['number']}',
          style: const TextStyle(fontSize: 17),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(24),
            children: [
              LinearProgressIndicator(value: done / ids.length),
              const SizedBox(height: 12),
              Text('Разобрано $done из ${ids.length}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(ids.length, (i) {
                  final state = (records['$i'] as Map?)?['status'];
                  return ActionChip(
                    label: Text(
                      '${i + 1}${state == 'correct'
                          ? ' ✓'
                          : state == 'wrong'
                          ? ' ×'
                          : state == 'reviewed'
                          ? ' •'
                          : ''}',
                    ),
                    backgroundColor: i == index
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: saving ? null : () => move(i),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (summary) ...[
                const Text(
                  'Результаты тренировки',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Верно автоматически: ${records.values.where((r) => r['status'] == 'correct').length}\nОшибки: ${records.values.where((r) => r['status'] == 'wrong').length}\nСамостоятельно разобрано: ${records.values.where((r) => r['status'] == 'reviewed').length}\nБез проверки: ${ids.length - done}',
                  style: const TextStyle(fontSize: 18, height: 1.8),
                ),
                const Text(
                  'Это учебный результат, а не экзаменационная оценка. Развёрнутые решения требуют проверки по критериям.',
                ),
                TextButton(
                  onPressed: () => setState(() => summary = false),
                  child: const Text('Вернуться к заданиям'),
                ),
              ] else ...[
                Text(
                  'Задание ${index + 1}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Метод · ${guide.title}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MathText(
                          guide.text,
                          style: const TextStyle(fontSize: 17, height: 1.7),
                        ),
                        if (theory) ...[
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () => setState(() => theory = false),
                            child: const Text('К заданию'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!theory) ...[
                  const SizedBox(height: 20),
                  if ((q['contextHtml'] as String).isNotEmpty)
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: const Text('Общие данные к заданиям'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ExamHtml(q['contextHtml'] as String),
                        ),
                      ],
                    ),
                  ExamHtml(q['questionHtml'] as String),
                  source(q['sourceUrl'] as String, 'Источник задания'),
                  const SizedBox(height: 16),
                  FormulaAnswerField(
                    controller: answer,
                    readOnly: status != null,
                    maxLines: automatic ? 1 : 5,
                    maxLength: automatic ? 100 : 10000,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: automatic
                          ? 'Краткий ответ'
                          : 'Ваше решение или заметки',
                      helperText: automatic
                          ? 'Соблюдайте формат ответа из условия.'
                          : 'Можно решать в тетради.',
                    ),
                    onChanged: (value) {
                      final old = Map<String, dynamic>.from(record);
                      old['input'] = value;
                      records['$index'] = old;
                      draftTimer?.cancel();
                      draftTimer = Timer(
                        const Duration(milliseconds: 350),
                        save,
                      );
                    },
                    onSubmitted: automatic ? (_) => check() : null,
                  ),
                  const SizedBox(height: 12),
                  if (automatic && status == null)
                    FilledButton(
                      onPressed: saving ? null : check,
                      child: const Text('Проверить ответ'),
                    ),
                  if (!automatic && status == null && !revealed)
                    FilledButton(
                      onPressed: () => setState(() => revealed = true),
                      child: const Text('Перейти к сверке решения'),
                    ),
                  if (status == 'wrong') ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        final next = catalog!.questions.values
                            .cast<Map<String, dynamic>>()
                            .where(
                              (other) =>
                                  other['track'] == q['track'] &&
                                  other['slot'] == q['slot'] &&
                                  other['id'] != q['id'],
                            )
                            .firstOrNull;
                        if (next == null) return;
                        final v = catalog!.variants.firstWhere(
                          (v) =>
                              (v['questionIds'] as List).contains(next['id']),
                        );
                        context.push(
                          '/exams/${v['id']}?question=${q['slot']}&retry=1',
                        );
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Закрепить похожим заданием'),
                    ),
                  ],
                  if (status != null || revealed) ...[
                    const SizedBox(height: 16),
                    Text(
                      status == 'correct'
                          ? 'Верно!'
                          : status == 'wrong'
                          ? 'Есть ошибка. Сверь решение с образцом.'
                          : 'Самостоятельная проверка',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (automatic)
                      MathText(
                        'Ответ: ${(q['answer'] as String).replaceAll('|', ' или ')}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    if ((q['solutionHtml'] as String).isNotEmpty)
                      ExamHtml(q['solutionHtml'] as String)
                    else
                      const Text('Полное решение — в источнике.'),
                    source(q['sourceUrl'] as String, 'Открыть полное решение'),
                    if (!automatic) ...[
                      const Text(
                        'Сверь с решением источника: условия и ограничения; обоснование каждого шага; вычисления; все пункты ответа. Эта сверка не заменяет проверку учителя и не даёт баллы ЕГЭ.',
                      ),
                      for (final criterion in [
                        'Учтены условия и ограничения',
                        'Обоснован каждый шаг',
                        'Проверены вычисления',
                        'Даны все требуемые ответы',
                      ])
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(criterion),
                          value: (record['criteria'] as List? ?? []).contains(
                            criterion,
                          ),
                          onChanged: saving || record['selfAssessed'] == true
                              ? null
                              : (value) async {
                                  final selected = List<String>.from(
                                    record['criteria'] as List? ?? [],
                                  );
                                  if (value == true) {
                                    selected.add(criterion);
                                  } else {
                                    selected.remove(criterion);
                                  }
                                  setState(
                                    () => records['$index'] = {
                                      ...record,
                                      'input': answer.text,
                                      'criteria': selected,
                                    },
                                  );
                                  await save();
                                },
                        ),
                      if (record['selfAssessed'] == true)
                        const Text('Самооценка сохранена.'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: saving || record['selfAssessed'] == true
                                ? null
                                : () => selfAssess(false),
                            child: const Text('В мои ошибки'),
                          ),
                          TextButton(
                            onPressed:
                                saving ||
                                    record['selfAssessed'] == true ||
                                    (record['criteria'] as List? ?? [])
                                            .length !=
                                        4
                                ? null
                                : () => selfAssess(true),
                            child: const Text('По моей сверке — верно'),
                          ),
                        ],
                      ),
                    ],
                    if (!automatic && status == null) ...[
                      const Text(
                        'Проверь ход решения и все пункты ответа. «Разобрано» отмечает разбор, не правильность.',
                      ),
                      OutlinedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                setState(() => saving = true);
                                records['$index'] = {
                                  ...record,
                                  'input': answer.text,
                                  'status': 'reviewed',
                                };
                                await save();
                                if (mounted) setState(() => saving = false);
                              },
                        child: const Text('Отметить как разобранное'),
                      ),
                    ],
                    if (status == 'wrong')
                      TextButton(
                        onPressed: () {
                          records['$index'] = {'input': ''};
                          setState(() {
                            answer.clear();
                            revealed = false;
                          });
                          save();
                        },
                        child: const Text('Попробовать снова'),
                      ),
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (index > 0)
                        OutlinedButton(
                          onPressed: saving ? null : () => move(index - 1),
                          child: const Text('Назад'),
                        ),
                      if (index < ids.length - 1)
                        FilledButton(
                          onPressed: saving ? null : () => move(index + 1),
                          child: const Text('Следующее задание'),
                        ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () async {
                  await save();
                  if (mounted) setState(() => summary = true);
                },
                child: const Text('Результаты'),
              ),
              source(variant!['sourceUrl'] as String, 'Вариант в источнике'),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
