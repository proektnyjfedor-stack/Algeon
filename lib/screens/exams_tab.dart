import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/exam_catalog.dart';
import '../services/exam_progress.dart';
import '../services/files/exam_link.dart';
import '../services/mock_exam_service.dart';

class ExamsTab extends StatefulWidget {
  const ExamsTab({super.key});
  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  String track = 'oge';
  late Future<ExamCatalog> catalog = ExamCatalog.load();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 110),
          children: [
            Text(
              'Экзамены',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Разбирай задания или решай вариант на время.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: examLabels.entries
                  .map(
                    (e) => ChoiceChip(
                      label: Text(e.value),
                      selected: track == e.key,
                      onSelected: (_) => setState(() => track = e.key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            FutureBuilder<ExamCatalog>(
              future: catalog,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      const Text('Не удалось загрузить варианты.'),
                      TextButton(
                        onPressed: () =>
                            setState(() => catalog = ExamCatalog.load()),
                        child: const Text('Повторить'),
                      ),
                    ],
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final variants = snapshot.data!.variants
                    .where((v) => v['track'] == track)
                    .toList();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Each card needs room for two clear, independent actions.
                    final columns = constraints.maxWidth >= 1000
                        ? 3
                        : constraints.maxWidth >= 680
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: variants
                          .map(
                            (v) => SizedBox(
                              width: width,
                              child: _VariantCard(
                                key: ValueKey(v['id']),
                                variant: v,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const _ExamSources(),
          ],
        ),
      ),
    ),
  );
}

class _VariantCard extends StatefulWidget {
  const _VariantCard({super.key, required this.variant});
  final Map<String, dynamic> variant;
  @override
  State<_VariantCard> createState() => _VariantCardState();
}

class _VariantCardState extends State<_VariantCard> {
  late final progress = ExamProgress.read(widget.variant['id'] as String);
  @override
  Widget build(BuildContext context) {
    final v = widget.variant;
    final count = (v['questionIds'] as List).length;
    final minutes = MockExamService.minutes(v['track'] as String);
    final duration = minutes == 180 ? '3 ч' : '3 ч 55 мин';
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Вариант ${v['number']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '$count заданий · $duration',
              style: TextStyle(color: muted, fontSize: 14),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: progress,
              builder: (context, snapshot) {
                final records = snapshot.data?['records'] as Map? ?? {};
                final done = records.values
                    .where((r) => (r as Map)['status'] != null)
                    .length;
                if (done == 0) {
                  return const SizedBox(height: 20);
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Разобрано $done из $count',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: done / count,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              },
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final study = FilledButton(
                  onPressed: () => context.go('/exams/${v['id']}'),
                  child: const Text('Разбор'),
                );
                final exam = OutlinedButton(
                  onPressed: () => context.go('/exams/${v['id']}/run'),
                  child: const Text('Экзамен'),
                );
                if (constraints.maxWidth < 260 ||
                    MediaQuery.textScalerOf(context).scale(14) > 21) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [study, const SizedBox(height: 8), exam],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: study),
                    const SizedBox(width: 10),
                    Expanded(child: exam),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamSources extends StatelessWidget {
  const _ExamSources();
  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
    childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
    title: const Text(
      'О заданиях и режимах',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Разбор — теория и проверка каждого задания. Экзамен — вариант с таймером, решения доступны после завершения.\n\nЗадания: «Решу ОГЭ» и «Решу ЕГЭ». Это тренировочные подборки, не официальные варианты ФИПИ. Структура — по проектам ФИПИ 2027: ОГЭ — 25 заданий, база — 21, профиль — 20. Проекты могут измениться. Данные от 10.10.2026.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => openExamLink(
                'https://fipi.ru/oge/demoversii-specifikacii-kodifikatory',
              ),
              child: const Text('ФИПИ · ОГЭ'),
            ),
            TextButton(
              onPressed: () => openExamLink(
                'https://fipi.ru/ege/demoversii-specifikacii-kodifikatory',
              ),
              child: const Text('ФИПИ · ЕГЭ'),
            ),
          ],
        ),
      ),
    ],
  );
}
