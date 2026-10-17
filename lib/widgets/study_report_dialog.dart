import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/learning_service.dart';
import '../services/study_report.dart';
import '../services/files/backup_file.dart';

Future<void> showStudyReport(BuildContext context) async {
  final history = LearningService.instance;
  final report = buildStudyReport(history);
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Отчёт о подготовке'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(child: SelectableText(report)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: report));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Отчёт скопирован')));
            }
          },
          icon: const Icon(Icons.copy),
          label: const Text('Копировать'),
        ),
        if (supportsBackupFiles)
          FilledButton.icon(
            onPressed: () async {
              try {
                await downloadBackup(
                  report,
                  'algeon-report-${history.today}.md',
                  mimeType: 'text/markdown;charset=utf-8',
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Не удалось скачать. Используйте «Копировать».',
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Скачать .md'),
          ),
      ],
    ),
  );
}
