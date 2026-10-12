import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/adaptive_practice.dart';
import '../services/task_teaching.dart';
import 'formula_answer_field.dart';
import 'math_text.dart';

class TopicQuickCheck extends StatefulWidget {
  const TopicQuickCheck({super.key, required this.tasks});
  final List<Task> tasks;
  @override
  State<TopicQuickCheck> createState() => _TopicQuickCheckState();
}

class _TopicQuickCheckState extends State<TopicQuickCheck> {
  final answer = TextEditingController();
  bool open = false, checked = false;
  int index = 0;
  late final List<Task> questions =
      (List<Task>.from(widget.tasks)..sort(
            (a, b) => AdaptivePractice.complexity(
              a,
            ).compareTo(AdaptivePractice.complexity(b)),
          ))
          .take(2)
          .toList();
  @override
  void dispose() {
    answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!open) {
      return OutlinedButton.icon(
        onPressed: () => setState(() => open = true),
        icon: const Icon(Icons.fact_check_outlined),
        label: const Text('Проверить понимание · 2 вопроса'),
      );
    }
    if (index >= questions.length) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Разминка завершена. Теперь можно перейти к практике.'),
        ),
      );
    }
    final task = questions[index];
    final correct = checked && task.checkAnswer(answer.text);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Разминка · ${index + 1} из ${questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Без оценки. Можно сразу перейти к практике.'),
            const SizedBox(height: 14),
            if (task.imageAsset != null)
              Image.asset(task.imageAsset!, height: 160, fit: BoxFit.contain),
            MathText(task.question),
            const SizedBox(height: 12),
            if (task.type == TaskType.multipleChoice)
              ...?task.options?.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: OutlinedButton(
                    onPressed: checked
                        ? null
                        : () => setState(() => answer.text = option),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: answer.text == option
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                    child: MathText(option),
                  ),
                ),
              )
            else
              FormulaAnswerField(
                controller: answer,
                readOnly: checked,
                onSubmitted: (_) {
                  if (answer.text.trim().isNotEmpty) {
                    setState(() => checked = true);
                  }
                },
              ),
            if (checked) ...[
              const SizedBox(height: 12),
              Text(
                correct ? 'Верно' : 'Разберём ответ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!correct)
                MathText(AdaptivePractice.feedback(task, answer.text)),
              ...TaskTeaching.explanation(task).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: MathText(s),
                ),
              ),
              MathText('Ответ: ${task.answer}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => setState(() {
                  index++;
                  checked = false;
                  answer.clear();
                }),
                child: Text(
                  index + 1 == questions.length
                      ? 'Завершить разминку'
                      : 'Следующий вопрос',
                ),
              ),
            ] else
              ListenableBuilder(
                listenable: answer,
                builder: (context, _) => FilledButton(
                  onPressed: answer.text.trim().isEmpty
                      ? null
                      : () => setState(() => checked = true),
                  child: const Text('Проверить ответ'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
