import '../widgets/learning_note.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/exam_catalog.dart';
import '../data/tasks_data.dart';
import '../services/learning_service.dart';
import '../services/progress_service.dart';
import '../widgets/math_text.dart';

class StudyLinks extends StatelessWidget {
  const StudyLinks({super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        for (final item in [
          (
            '/study',
            'План подготовки',
            'Задания на каждый день',
            Icons.calendar_month,
          ),
          (
            '/study?tab=1',
            'Мои ошибки',
            'Повторение через 1, 3 и 7 дней',
            Icons.history_edu,
          ),
          (
            '/study?tab=2',
            'Темы и результаты',
            'Точность по темам',
            Icons.insights,
          ),
          (
            '/diagnostic',
            'Определить уровень',
            '9 заданий и рекомендации',
            Icons.explore,
          ),
        ])
          ListTile(
            leading: Icon(item.$4),
            title: Text(item.$2),
            subtitle: Text(item.$3),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(item.$1),
          ),
      ],
    ),
  );
}

void openLearningRef(BuildContext context, Map ref) {
  if (ref['kind'] == 'school') {
    final task = getTaskById(ref['id'] as String);
    if (task != null) {
      context.push(
        '/learn/intro',
        extra: {
          'name': task.topic,
          'restart': true,
          'tasks': [task],
        },
      );
    }
  } else {
    context.push('/exams/${ref['variant']}?question=${ref['slot']}&retry=1');
  }
}

class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen> {
  final history = LearningService.instance;
  ExamCatalog? catalog;
  List<Map<String, dynamic>> items = [];
  bool dueOnly = false, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      await history.init();
      final c = await ExamCatalog.load();
      final daily = await history.dailyTasks(c);
      if (mounted) {
        setState(() {
          catalog = c;
          items = daily;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Не удалось загрузить подготовку. Попробуйте ещё раз.',
        );
      }
    }
  }

  Future<void> configure() async {
    var track = history.plan['track'] as String? ?? 'oge';
    var daily = history.plan['daily'] as int? ?? 10;
    var grade =
        history.plan['grade'] as int? ?? ProgressService.getCurrentGrade();
    var target =
        DateTime.tryParse(history.plan['target'] as String? ?? '') ??
        DateTime.now().add(const Duration(days: 90));
    final goal = TextEditingController(
      text: history.plan['goal'] as String? ?? 'Уверенно решать свой вариант',
    );
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Мой план'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: track,
                    decoration: const InputDecoration(
                      labelText: 'К чему готовимся',
                    ),
                    items: {'school': 'Школьная математика', ...examLabels}
                        .entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => update(() => track = v!),
                  ),
                  if (track == 'school')
                    DropdownButtonFormField<int>(
                      initialValue: grade,
                      decoration: const InputDecoration(labelText: 'Класс'),
                      items: List.generate(
                        11,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1} класс'),
                        ),
                      ),
                      onChanged: (v) => update(() => grade = v!),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: goal,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Твоя цель'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Дата цели'),
                    subtitle: Text(studyDateLabel(target)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final now = DateUtils.dateOnly(DateTime.now());
                      final date = await showDatePicker(
                        context: context,
                        initialDate: target.isBefore(now) ? now : target,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 1095)),
                      );
                      if (date != null) update(() => target = date);
                    },
                  ),
                  const Text('Заданий в день'),
                  Wrap(
                    spacing: 6,
                    children: [5, 10, 15, 20, 30]
                        .map(
                          (n) => ChoiceChip(
                            label: Text('$n'),
                            selected: daily == n,
                            onSelected: (_) => update(() => daily = n),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, {
                'track': track,
                'grade': grade,
                'daily': daily,
                'target': target.toIso8601String(),
                'goal': goal.text.trim(),
              }),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    goal.dispose();
    if (result == null || !mounted) return;
    setState(() => busy = true);
    try {
      await history.configurePlan(result);
      final next = await history.dailyTasks(catalog!);
      if (mounted) setState(() => items = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить план.')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget panel(String title, String text, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
  Widget planView() {
    final p = history.plan;
    if (p.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          panel(
            'Твой план',
            'Выбери цель, срок и количество заданий в день.',
            Icons.calendar_month,
          ),
          FilledButton(onPressed: configure, child: const Text('Создать план')),
        ],
      );
    }
    final days = DateUtils.dateOnly(
      DateTime.parse(p['target'] as String),
    ).difference(DateUtils.dateOnly(DateTime.now())).inDays;
    final completed = items
        .where(
          (r) =>
              history.stats[r['kind'] == 'exam'
                  ? 'exam:${r['id']}'
                  : r['id']]?['lastDay'] ==
              history.today,
        )
        .length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        panel(
          p['goal'] as String,
          '${p['track'] == 'school' ? '${p['grade']} класс' : examLabels[p['track']]} · ${days > 0
              ? 'Осталось $days дн.'
              : days == 0
              ? 'Цель на сегодня'
              : 'Обнови дату цели'}\n${p['daily']} заданий в день',
          Icons.flag_outlined,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: busy ? null : configure,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Изменить план'),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Сегодня · $completed из ${items.length}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: items.isEmpty ? 0 : completed / items.length,
        ),
        const SizedBox(height: 12),
        ...items.map((r) {
          final task = r['kind'] == 'school'
              ? getTaskById(r['id'] as String)
              : null;
          final done =
              history.stats[r['kind'] == 'exam'
                  ? 'exam:${r['id']}'
                  : r['id']]?['lastDay'] ==
              history.today;
          return Card(
            child: ListTile(
              leading: Icon(done ? Icons.check_circle : Icons.circle_outlined),
              title: Text(
                task?.topic ??
                    '${examLabels[r['track']]} · Задание ${r['slot']}',
              ),
              subtitle: task == null
                  ? Text('Вариант ${(r['variant'] as String).split('-').last}')
                  : Text(
                      'Задание ${items.indexOf(r) + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openLearningRef(context, r),
            ),
          );
        }),
        const SizedBox(height: 12),
        const LearningNote(
          title: 'Как устроен план',
          text:
              'Сначала — ошибки, которые пора повторить, затем разные темы. Задание отмечается выполненным после попытки сегодня. Ошибки остаются в повторении до освоения.',
        ),
      ],
    );
  }

  Widget errorsView() {
    final reviews = history.reviews(dueOnly: dueOnly);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        panel(
          'Повторение ошибок',
          'Разбери ошибку и повтори задание через 1, 3 и 7 дней.',
          Icons.history_edu,
        ),
        const LearningNote(
          title: 'Как засчитывается повторение',
          text:
              'Сначала исправь ошибку, затем реши задание верно через 1, 3 и 7 дней. После четырёх успешных проверок оно освоено. Ранние повторы не ускоряют зачёт; новая ошибка начинает цикл заново.',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Только на сегодня'),
          value: dueOnly,
          onChanged: (v) => setState(() => dueOnly = v),
        ),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Пока нет заданий для повторения. Ошибки появятся здесь после решения.',
            ),
          ),
        ...reviews.map((e) {
          final r = e.value as Map;
          final due = DateTime.parse(r['due'] as String);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    r['topic'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Повторов: ${r['stage']}/4 · ${due.isAfter(DateTime.now()) ? 'Повторить ${studyDateLabel(due)}' : 'Пора повторить'}',
                  ),
                  if ((r['input'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Твой ответ:'),
                    MathText(r['input'] as String),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          openLearningRef(context, r['ref'] as Map),
                      icon: const Icon(Icons.replay),
                      label: const Text('Повторить'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        Text(
          'Освоено: ${history.mistakes.values.where((r) => r['stage'] == 4).length}',
        ),
      ],
    );
  }

  Widget topicsView() {
    final topics = history.topicStats();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        panel(
          'Результаты по темам',
          'Сначала темы, которым нужно больше практики.',
          Icons.insights,
        ),
        const LearningNote(
          title: 'Как считается точность',
          text:
              'Учитываются новые попытки и твоя самооценка развёрнутых решений. При одной-двух попытках выводы предварительные. Старые ошибки из общих счётчиков восстановить нельзя.',
        ),
        if (topics.isEmpty) ...[
          const Text('Реши несколько заданий, чтобы увидеть результаты.'),
          TextButton(
            onPressed: () => context.push('/diagnostic'),
            child: const Text('Определить уровень'),
          ),
        ],
        ...topics.map((r) {
          final accuracy = r['correct'] / r['attempts'] as double;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['topic'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${r['correct']} из ${r['attempts']} верно · ${(accuracy * 100).round()}%${r['attempts'] < 3 ? ' · Мало данных' : ''}',
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: accuracy),
                  TextButton(
                    onPressed: () {
                      final source = history.stats.values.firstWhere(
                        (s) => s['topic'] == r['topic'],
                      );
                      openLearningRef(context, source['ref'] as Map);
                    },
                    child: const Text('Потренироваться'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    key: ValueKey(widget.initialTab),
    length: 3,
    initialIndex: widget.initialTab.clamp(0, 2),
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/practice'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Моя подготовка'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'План'),
            Tab(text: 'Ошибки'),
            Tab(text: 'Темы'),
          ],
        ),
      ),
      body: catalog == null
          ? Center(
              child: error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!),
                        TextButton(
                          onPressed: load,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: AnimatedBuilder(
                  animation: history,
                  builder: (context, _) => TabBarView(
                    children: [planView(), errorsView(), topicsView()],
                  ),
                ),
              ),
            ),
    ),
  );
}
