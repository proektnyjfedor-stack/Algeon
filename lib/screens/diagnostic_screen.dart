import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/tasks_data.dart';
import '../models/task.dart';
import '../services/learning_service.dart';
import '../services/progress_service.dart';
import '../widgets/formula_answer_field.dart';
import '../widgets/math_text.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});
  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final history = LearningService.instance;
  final input = TextEditingController();
  bool ready = false, busy = false;
  String? error;
  Map<String, dynamic> session = {};
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> load() async {
    await history.init();
    if (mounted) {
      setState(() {
        session = history.diagnostic;
        ready = true;
      });
    }
  }

  List<Task> get tasks => (session['ids'] as List? ?? [])
      .map((id) => getTaskById(id as String)!)
      .toList();
  Map get answers => session['answers'] as Map? ?? {};
  Task? get current =>
      tasks.where((t) => !answers.containsKey(t.id)).firstOrNull;
  Future<void> start() async {
    setState(() => busy = true);
    try {
      final grade = ProgressService.getCurrentGrade();
      final next = <String, dynamic>{
        'ids': LearningService.diagnosticTasks(grade).map((t) => t.id).toList(),
        'answers': <String, dynamic>{},
        'grade': grade,
        'startedAt': DateTime.now().toIso8601String(),
      };
      await history.saveDiagnostic(next);
      if (mounted) {
        setState(() {
          session = next;
          input.clear();
          error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Не удалось сохранить диагностику.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit({bool skip = false}) async {
    if (busy || current == null || (!skip && input.text.trim().isEmpty)) return;
    final task = current!;
    final value = skip ? '' : input.text;
    final correct = !skip && task.checkAnswer(value);
    setState(() => busy = true);
    try {
      await history.record(
        attemptId: 'diagnostic:${session['startedAt']}:${task.id}',
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: LearningService.taskRef(task),
        correct: correct,
        input: value,
      );
      final updated = <String, dynamic>{
        ...session,
        'answers': <String, dynamic>{
          ...answers,
          task.id: {'correct': correct, 'input': value},
        },
      };
      await history.saveDiagnostic(updated);
      if (mounted) {
        setState(() {
          session = updated;
          input.clear();
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Не удалось сохранить ответ. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = current;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/practice'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Определить уровень'),
      ),
      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (error != null)
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (session.isEmpty) ...[
                      Text(
                        'С чего начать?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '9 заданий ${ProgressService.getCurrentGrade()} класса и соседних уровней.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Решай без подсказок. Сложное задание можно пропустить. Разбор — в конце, ответы сохраняются.',
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: busy ? null : start,
                        child: const Text('Начать диагностику'),
                      ),
                    ] else if (task != null) ...[
                      Text(
                        'Задание ${answers.length + 1} из ${tasks.length} · ${task.grade} класс',
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: answers.length / tasks.length,
                      ),
                      const SizedBox(height: 24),
                      MathText(
                        task.question,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 24),
                      if (task.type == TaskType.multipleChoice)
                        ...(task.options ?? []).map(
                          (option) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () {
                                      input.text = option;
                                      submit();
                                    },
                              child: MathText(option),
                            ),
                          ),
                        )
                      else ...[
                        FormulaAnswerField(
                          controller: input,
                          onSubmitted: (_) => submit(),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: busy ? null : () => submit(),
                          child: const Text('Дальше'),
                        ),
                      ],
                      TextButton(
                        onPressed: busy ? null : () => submit(skip: true),
                        child: const Text('Пока не знаю · пропустить'),
                      ),
                    ] else
                      ...result(),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> result() {
    final wrong = tasks.where((t) => answers[t.id]['correct'] != true).toList();
    final weak = wrong.map((t) => t.topic).toSet();
    return [
      Text(
        'Твоя отправная точка',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 12),
      Text(
        'Верно ${tasks.length - wrong.length} из ${tasks.length}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      for (final grade in tasks.map((t) => t.grade).toSet())
        Text(
          '$grade класс: ${tasks.where((t) => t.grade == grade && answers[t.id]['correct'] == true).length} из ${tasks.where((t) => t.grade == grade).length}',
        ),
      const SizedBox(height: 16),
      Text(
        wrong.isEmpty
            ? 'Всё верно. Переходи к более сложным задачам.'
            : 'Начни с тем: ${weak.join(', ')}. Ошибки уже добавлены в повторение.',
      ),
      const SizedBox(height: 12),
      const Text('Результат — ориентир для дальнейшей практики.'),
      if (wrong.isNotEmpty)
        FilledButton(
          onPressed: () => context.push(
            '/learn/intro',
            extra: {'name': 'Разбор диагностики', 'tasks': wrong},
          ),
          child: const Text('Разобрать ошибки'),
        ),
      TextButton(
        onPressed: () => context.go('/study'),
        child: const Text('Составить план'),
      ),
      ...tasks.map(
        (t) => Card(
          child: ExpansionTile(
            title: Text(
              '${answers[t.id]['correct'] == true ? '✓' : '○'} ${t.topic} · ${t.grade} класс',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MathText(t.question),
                    const SizedBox(height: 8),
                    const Text('Твой ответ:'),
                    MathText(
                      (answers[t.id]['input'] as String).isEmpty
                          ? 'Пропущено'
                          : answers[t.id]['input'] as String,
                    ),
                    const SizedBox(height: 8),
                    const Text('Правильный ответ:'),
                    MathText(t.answer),
                    TextButton(
                      onPressed: () => context.push(
                        '/learn/intro',
                        extra: {
                          'name': t.topic,
                          'tasks': [t],
                        },
                      ),
                      child: const Text('Открыть разбор'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      TextButton(
        onPressed: busy ? null : start,
        child: const Text('Пройти ещё раз'),
      ),
    ];
  }
}
