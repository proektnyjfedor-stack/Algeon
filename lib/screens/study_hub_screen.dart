import '../widgets/learning_note.dart';
import '../widgets/day_boundary_observer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/exam_catalog.dart';
import '../data/tasks_data.dart';
import '../services/learning_service.dart';
import '../services/progress_service.dart';
import '../models/task.dart';
import '../widgets/math_text.dart';

class StudyLinks extends StatefulWidget {
  const StudyLinks({super.key});
  @override
  State<StudyLinks> createState() => _StudyLinksState();
}

class _StudyLinksState extends State<StudyLinks>
    with WidgetsBindingObserver, DayBoundaryObserver {
  String? loadedDay;
  final history = LearningService.instance;
  List<Map<String, dynamic>> daily = [];
  String? error;
  bool ready = false;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  DateTime get dayClock => history.clock();

  @override
  void onDayBoundary() {
    if (mounted && loadedDay != null && loadedDay != history.today) {
      refresh();
    }
  }

  Future<void> refresh() async {
    try {
      await history.init();
      final next = history.plan.isEmpty
          ? <Map<String, dynamic>>[]
          : await history.dailyTasks(await ExamCatalog.load());
      if (mounted) {
        setState(() {
          daily = next;
          loadedDay = history.today;
          ready = true;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Подготовка не загрузилась';
          ready = true;
        });
      }
    }
  }

  Future<void> open(String route) async {
    await context.push(route);
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: history,
    builder: (context, _) {
      final diagnostic = history.diagnostic;
      final answered = (diagnostic['answers'] as Map? ?? {}).length;
      final total = (diagnostic['ids'] as List? ?? []).length;
      final inProgress = total > answered;
      final hasPlan = history.plan.isNotEmpty;
      final done = daily.where(history.completedToday).length;
      final remaining = daily.where((r) => !history.completedToday(r)).toList();
      final due = history.reviews(dueOnly: true).length;
      final title = hasPlan
          ? remaining.isEmpty && daily.isNotEmpty
                ? 'На сегодня всё готово'
                : 'Твоя практика на сегодня'
          : inProgress
          ? 'Продолжим диагностику'
          : total > 0
          ? 'Превратим результат в план'
          : 'Начни с понятной цели';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    hasPlan ? 'ПЛАН НА СЕГОДНЯ' : 'ТВОЙ СЛЕДУЮЩИЙ ШАГ',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    hasPlan
                        ? '${history.plan['track'] == 'school' ? '${history.plan['grade']} класс' : examLabels[history.plan['track']]} · выполнено $done из ${daily.length}'
                        : inProgress
                        ? 'Сохранено $answered из $total ответов. Можно продолжить с того же места.'
                        : total > 0
                        ? 'Результаты уже сохранены. Выбери цель и удобную нагрузку.'
                        : 'Диагностика покажет, что повторить. Или сразу создай план по своему классу или экзамену.',
                  ),
                  if (hasPlan) ...[
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: daily.isEmpty ? 0 : done / daily.length,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (!ready)
                    const LinearProgressIndicator()
                  else if (error != null)
                    TextButton(
                      onPressed: refresh,
                      child: Text('$error · повторить'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () {
                        if (hasPlan && remaining.isNotEmpty) {
                          openDailyPractice(context, remaining).then((_) {
                            if (mounted) refresh();
                          });
                        } else {
                          open(
                            hasPlan || total > 0 && !inProgress
                                ? '/study'
                                : '/diagnostic',
                          );
                        }
                      },
                      icon: Icon(
                        hasPlan && remaining.isEmpty
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        hasPlan
                            ? remaining.isEmpty
                                  ? 'Посмотреть план'
                                  : 'Продолжить план'
                            : inProgress
                            ? 'Продолжить диагностику'
                            : total > 0
                            ? 'Создать план'
                            : 'Пройти диагностику',
                      ),
                    ),
                  if (!hasPlan && total == 0)
                    TextButton(
                      onPressed: () => open('/study'),
                      child: const Text('Выбрать цель без диагностики'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history_edu),
                  title: const Text('Мои ошибки'),
                  subtitle: Text(
                    due == 0
                        ? 'На сегодня повторений нет'
                        : 'Пора повторить: $due',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open('/study?tab=1'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.insights),
                  title: const Text('Темы и результаты'),
                  subtitle: Text(
                    history.topicStats().isEmpty
                        ? 'Появятся после первых ответов'
                        : 'Тем с результатами: ${history.topicStats().length}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open('/study?tab=2'),
                ),
                if (hasPlan || total > 0) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.explore_outlined),
                    title: const Text('Диагностика'),
                    subtitle: Text(
                      inProgress
                          ? '$answered из $total · продолжить'
                          : total > 0
                          ? 'Посмотреть результат'
                          : 'Найти темы для повторения',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open('/diagnostic'),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    },
  );
}

Future<void> openDailyPractice(
  BuildContext context,
  List<Map<String, dynamic>> items,
) async {
  if (items.isEmpty) return;
  if (items.first['kind'] == 'school') {
    final tasks = items
        .where((r) => r['kind'] == 'school')
        .map((r) => getTaskById(r['id'] as String))
        .whereType<Task>()
        .toList();
    await context.push(
      '/learn/topic',
      extra: {'name': 'План на сегодня', 'tasks': tasks, 'restart': true},
    );
  } else {
    await context.push('/study/run');
  }
}

Future<void> openLearningRef(BuildContext context, Map ref) async {
  if (ref['kind'] == 'school') {
    final task = getTaskById(ref['id'] as String);
    if (task != null) {
      await context.push(
        '/learn/intro',
        extra: {
          'name': task.topic,
          'restart': true,
          'tasks': [task],
        },
      );
    }
  } else {
    await context.push(
      '/exams/${ref['variant']}?question=${ref['slot']}&retry=1',
    );
  }
}

class StudyHubScreen extends StatefulWidget {
  const StudyHubScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<StudyHubScreen> createState() => _StudyHubScreenState();
}

class _StudyHubScreenState extends State<StudyHubScreen>
    with WidgetsBindingObserver, DayBoundaryObserver {
  String? loadedDay;
  final history = LearningService.instance;
  ExamCatalog? catalog;
  List<Map<String, dynamic>> items = [];
  bool dueOnly = true, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  DateTime get dayClock => history.clock();

  @override
  void onDayBoundary() {
    if (mounted && loadedDay != null && loadedDay != history.today) {
      load();
    }
  }

  Future<void> load() async {
    try {
      await history.init();
      final c = await ExamCatalog.load();
      final daily = await history.dailyTasks(c);
      if (mounted) {
        setState(() {
          catalog = c;
          loadedDay = history.today;
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
    var track = history.plan['track'] as String? ?? 'school';
    var daily = history.plan['daily'] as int? ?? 5;
    var grade =
        history.plan['grade'] as int? ??
        history.diagnostic['grade'] as int? ??
        ProgressService.getCurrentGrade();
    var target =
        DateTime.tryParse(history.plan['target'] as String? ?? '') ??
        DateTime.now().add(const Duration(days: 90));
    final goal = TextEditingController(
      text: history.plan['goal'] as String? ?? 'Заниматься регулярно',
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
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'К чему готовимся',
                    ),
                    items: {'school': 'Школьная математика', ...examLabels}
                        .entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                'goal': goal.text.trim().isEmpty
                    ? 'Заниматься регулярно'
                    : goal.text.trim(),
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
            'Выбери школьную программу или экзамен и посильную нагрузку. Начни с 5 заданий в день — её всегда можно изменить.',
            Icons.calendar_month,
          ),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.flag_outlined),
            title: Text('1. Выбери цель'),
            subtitle: Text('Класс, ОГЭ или один из уровней ЕГЭ'),
          ),
          const ListTile(
            leading: Icon(Icons.today_outlined),
            title: Text('2. Решай небольшой набор каждый день'),
            subtitle: Text('Ошибки для повторения и разные темы'),
          ),
          const ListTile(
            leading: Icon(Icons.insights_outlined),
            title: Text('3. Следи за результатом'),
            subtitle: Text('Новые попытки уточняют подбор заданий'),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: configure, child: const Text('Создать план')),
          TextButton(
            onPressed: () => context.push('/diagnostic'),
            child: const Text('Сначала пройти диагностику'),
          ),
        ],
      );
    }
    final days = DateUtils.dateOnly(
      DateTime.parse(p['target'] as String),
    ).difference(DateUtils.dateOnly(DateTime.now())).inDays;
    final completed = items.where(history.completedToday).length;
    final remaining = items.where((r) => !history.completedToday(r)).toList();
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
        const SizedBox(height: 16),
        if (remaining.isNotEmpty)
          FilledButton.icon(
            onPressed: () async {
              await openDailyPractice(context, remaining);
              if (mounted) await load();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Продолжить план'),
          )
        else if (items.isNotEmpty)
          const Text('План выполнен. Новый набор появится завтра.'),
        const SizedBox(height: 12),
        ...items.map((r) {
          final task = r['kind'] == 'school'
              ? getTaskById(r['id'] as String)
              : null;
          final done = history.completedToday(r);
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
                      '${items.indexOf(r) + 1}. ${history.reviews(dueOnly: true).any((e) => e.value['ref']['kind'] == r['kind'] && e.value['ref']['id'] == r['id'])
                          ? 'Повторение ошибки'
                          : history.stats[r['id']] == null
                          ? 'Новая практика'
                          : 'Закрепление'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await openLearningRef(context, r);
                if (mounted) await load();
              },
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              dueOnly && history.reviews().isNotEmpty
                  ? 'На сегодня всё повторено. Отключи фильтр, чтобы увидеть следующие задания.'
                  : 'Пока нет заданий для повторения. Ошибки появятся здесь после решения.',
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
              'Точность — доля верных ответов среди сохранённых попыток. Для развёрнутых экзаменационных задач учитывается самооценка. При одной-двух попытках выводы предварительные.',
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
                      final ref = source['ref'] as Map;
                      final task = ref['kind'] == 'school'
                          ? getTaskById(ref['id'] as String)
                          : null;
                      if (task == null) {
                        openLearningRef(context, ref);
                      } else {
                        context.push(
                          '/learn/intro',
                          extra: {
                            'name': task.topic,
                            'restart': true,
                            'tasks': getTasksByGradeAndTopic(
                              task.grade,
                              task.topic,
                            ).take(5).toList(),
                          },
                        );
                      }
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
