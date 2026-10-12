import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/tasks_data.dart';
import '../models/task.dart';
import '../services/bookmark_service.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/math_text.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.savedOnly = false});
  final bool savedOnly;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final search = TextEditingController();
  late int mode = widget.savedOnly ? 2 : 0;
  int? grade;
  int limit = 40;
  String normalize(String s) => s.toLowerCase().replaceAll('ё', 'е').trim();
  @override
  void initState() {
    super.initState();
    BookmarkService.instance.ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant LibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savedOnly != widget.savedOnly) {
      mode = widget.savedOnly ? 2 : 0;
      limit = 40;
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void openTopic(int grade, String topic) => context.push(
    '/learn/intro',
    extra: {'name': topic, 'tasks': getTasksByGradeAndTopic(grade, topic)},
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: BookmarkService.instance,
    builder: (context, _) {
      final query = normalize(search.text);
      bool matches(String text) => query
          .split(RegExp(r'\s+'))
          .every((word) => normalize(text).contains(word));
      final entries = <Widget>[];
      var total = 0;
      void add(Widget widget) {
        if (total++ < limit) entries.add(widget);
      }

      if (mode != 1) {
        for (var g = 1; g <= 11; g++) {
          if (grade != null && grade != g) continue;
          for (final topic in getTopicsInfoByGrade(g)) {
            final id = 'topic:$g:${topic.name}';
            if ((mode != 2 || BookmarkService.instance.contains(id)) &&
                matches('${topic.name} $g класс')) {
              add(
                Card(
                  child: ListTile(
                    leading: Icon(getTopicIcon(topic.name)),
                    title: Text(topic.name),
                    subtitle: Text('$g класс · ${topic.taskCount} заданий'),
                    trailing: BookmarkButton(id: id),
                    onTap: () => openTopic(g, topic.name),
                  ),
                ),
              );
            }
          }
        }
      }
      if (mode != 0) {
        for (final task in getAllTasks()) {
          if (grade != null && grade != task.grade) continue;
          final id = 'task:${task.id}';
          if ((mode != 2 || BookmarkService.instance.contains(id)) &&
              matches('${task.question} ${task.topic} ${task.grade} класс')) {
            add(
              Card(
                child: ListTile(
                  title: MathText(
                    task.question,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text('${task.grade} класс · ${task.topic}'),
                  trailing: BookmarkButton(id: id),
                  onTap: () => context.push(
                    '/learn/topic',
                    extra: {
                      'name': task.topic,
                      'tasks': <Task>[task],
                      'restart': true,
                    },
                  ),
                ),
              ),
            );
          }
        }
      }
      if (mode == 2 && grade == null) {
        for (final id in BookmarkService.instance.items.where(
          (id) => id.startsWith('exam:'),
        )) {
          final parts = id.split(':');
          final track = parts[1].split('-').first;
          final label =
              '${track == 'oge'
                  ? 'ОГЭ'
                  : track == 'base'
                  ? 'ЕГЭ · база'
                  : 'ЕГЭ · профиль'} · Вариант ${parts[1].split('-').last} · Задание ${parts[2]}';
          if (matches(label)) {
            add(
              Card(
                child: ListTile(
                  title: Text(label),
                  trailing: BookmarkButton(id: id),
                  onTap: () =>
                      context.push('/exams/${parts[1]}?question=${parts[2]}'),
                ),
              ),
            );
          }
        }
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Поиск и закладки'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/learn');
              }
            },
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  key: const ValueKey('library_search'),
                  controller: search,
                  decoration: InputDecoration(
                    labelText: 'Тема или условие задания',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Очистить поиск',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              search.clear();
                              setState(() => limit = 40);
                            },
                          ),
                  ),
                  onChanged: (_) => setState(() => limit = 40),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < 3; i++)
                      ChoiceChip(
                        label: Text(['Темы', 'Задания', 'Закладки'][i]),
                        selected: mode == i,
                        onSelected: (_) => setState(() {
                          mode = i;
                          limit = 40;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: grade,
                  decoration: const InputDecoration(labelText: 'Класс'),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Все классы'),
                    ),
                    for (var g = 1; g <= 11; g++)
                      DropdownMenuItem(value: g, child: Text('$g класс')),
                  ],
                  onChanged: (g) => setState(() {
                    grade = g;
                    limit = 40;
                  }),
                ),
                const SizedBox(height: 16),
                if (total == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      mode == 2 && query.isEmpty
                          ? 'Сохраняй задания и теорию кнопкой закладки — они появятся здесь.'
                          : 'Ничего не найдено. Попробуй другое слово или выбери все классы.',
                    ),
                  ),
                ...entries,
                if (total > limit)
                  TextButton(
                    onPressed: () => setState(() => limit += 40),
                    child: Text('Показать ещё · всего $total'),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
