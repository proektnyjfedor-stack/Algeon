import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/files/exam_link.dart';

class TaskReportButton extends StatelessWidget {
  const TaskReportButton({
    super.key,
    required this.taskId,
    required this.question,
  });
  final String taskId, question;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Сообщить об ошибке',
    icon: const Icon(Icons.flag_outlined, size: 20),
    onPressed: () async {
      final note = TextEditingController();
      var category = 'Ошибка в условии';
      await showDialog<void>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, update) => AlertDialog(
            title: const Text('Сообщить об ошибке'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Задание: $taskId'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      isExpanded: true,
                      items:
                          [
                                'Ошибка в условии',
                                'Не принимается ответ',
                                'Ошибка в объяснении',
                                'Проблема с рисунком',
                              ]
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (v) => update(() => category = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: note,
                      maxLength: 1000,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Что нужно исправить?',
                        hintText: 'Опиши проблему. Не указывай личные данные.',
                      ),
                    ),
                    const Text(
                      'Откроется GitHub с готовым сообщением. Отправку нужно подтвердить там.',
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
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text:
                          '$category\nЗадание: $taskId\n$question\n${note.text.trim()}',
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сообщение скопировано.')),
                    );
                  }
                },
                child: const Text('Скопировать'),
              ),
              FilledButton(
                onPressed: () {
                  final uri = Uri.https(
                    'github.com',
                    '/proektnyjfedor-stack/Algeon/issues/new',
                    {
                      'title': '[$taskId] $category',
                      'body':
                          'Задание: $taskId\n\nУсловие: $question\n\nПроблема: ${note.text.trim()}',
                    },
                  );
                  openExamLink(uri.toString());
                  Navigator.pop(context);
                },
                child: const Text('Открыть GitHub'),
              ),
            ],
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      note.dispose();
    },
  );
}
