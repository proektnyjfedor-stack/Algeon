import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/exam_catalog.dart';
import '../services/learning_service.dart';
import 'exam_session_screen.dart';

/// Uses the cached daily plan, so refreshes and returning from another screen
/// resume the same set. Answers and drafts remain in their original variants.
class DailyExamScreen extends StatefulWidget {
  const DailyExamScreen({super.key});
  @override
  State<DailyExamScreen> createState() => _DailyExamScreenState();
}

class _DailyExamScreenState extends State<DailyExamScreen> {
  final history = LearningService.instance;
  List<Map<String, dynamic>> remaining = [];
  int index = 0, total = 0, previouslyCompleted = 0;
  bool ready = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      await history.init();
      final catalog = await ExamCatalog.load();
      final daily = (await history.dailyTasks(
        catalog,
      )).where((ref) => ref['kind'] == 'exam').toList();
      final pending = daily
          .where((ref) => !history.completedToday(ref))
          .toList();
      if (!mounted) return;
      setState(() {
        remaining = pending;
        total = daily.length;
        previouslyCompleted = total - pending.length;
        index = 0;
        error = null;
        ready = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Не удалось загрузить задания плана.';
          ready = true;
        });
      }
    }
  }

  void next() {
    if (index >= remaining.length) return;
    if (!history.completedToday(remaining[index])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Сначала сохрани проверку ответа или самооценку решения.',
          ),
        ),
      );
      return;
    }
    setState(() => index++);
  }

  @override
  Widget build(BuildContext context) {
    if (ready && error == null && index < remaining.length) {
      final ref = remaining[index];
      return ExamSessionScreen(
        key: ValueKey('${ref['variant']}:${ref['id']}'),
        variantId: ref['variant'] as String,
        initialQuestion: ref['slot'] as int,
        retry: true,
        practicePosition: previouslyCompleted + index + 1,
        practiceTotal: total,
        onPracticeContinue: next,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('План на сегодня'),
        leading: IconButton(
          onPressed: () => context.go('/study'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: !ready
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        error != null
                            ? Icons.cloud_off_outlined
                            : total == 0
                            ? Icons.calendar_month
                            : Icons.done_all,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error ??
                            (total == 0
                                ? 'Нет экзаменационных заданий в плане'
                                : 'План на сегодня выполнен'),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (error == null && total > 0)
                        Text(
                          'Выполнено $total из $total. Ошибки сохранены для повторения.',
                          textAlign: TextAlign.center,
                        ),
                      if (error != null)
                        TextButton(
                          onPressed: load,
                          child: const Text('Повторить'),
                        ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.go('/study'),
                        child: const Text('К плану подготовки'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
