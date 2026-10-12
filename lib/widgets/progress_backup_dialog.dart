import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/backup_service.dart';
import '../services/files/backup_file.dart';
import '../services/language_service.dart';

class ProgressBackupDialog extends StatefulWidget {
  const ProgressBackupDialog({super.key});
  @override
  State<ProgressBackupDialog> createState() => _ProgressBackupDialogState();
}

class _ProgressBackupDialogState extends State<ProgressBackupDialog> {
  final _input = TextEditingController();
  bool _busy = false;
  bool _paste = false;
  bool _confirming = false;
  String? _message;
  bool _failed = false;
  bool get _en => LanguageService.instance.isEnglish;
  String _text(String ru, String en) => _en ? en : ru;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _message = _text(
            'Не удалось прочитать или сохранить копию. Выбери JSON-файл, созданный в Algeon.',
            'Could not read or save the backup. Choose a JSON file created by Algeon.',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export({bool copy = false}) => _run(() async {
    final contents = await BackupService.export();
    if (copy) {
      await Clipboard.setData(ClipboardData(text: contents));
    } else {
      await downloadBackup(
        contents,
        'algeon-progress-${DateTime.now().toIso8601String().substring(0, 10)}.json',
      );
    }
    if (mounted) {
      setState(() {
        _failed = false;
        _message = copy
            ? _text('Копия в буфере обмена.', 'Backup copied to clipboard.')
            : _text(
                'Копия подготовлена для скачивания.',
                'Backup download prepared.',
              );
      });
    }
  });

  Future<void> _import({bool paste = false}) => _run(() async {
    final contents = paste ? _input.text : await pickBackupFile();
    if (contents == null || !mounted) return;
    final data = BackupService.validate(contents);
    final solved = (data['solved_tasks'] as List?)?.length ?? 0;
    setState(() => _confirming = true);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Восстановить прогресс?', 'Restore progress?')),
        content: Text(
          _text(
            'В копии решено задач: $solved. Текущий профиль, прогресс и настройки будут заменены. Сначала можно сохранить текущую копию.',
            'Solved tasks in this backup: $solved. This replaces the current profile, progress and settings. You can save your current backup first.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_text('Отмена', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_text('Восстановить', 'Restore')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirm != true) return;
    await BackupService.restore(contents);
    if (mounted) Navigator.pop(context, true);
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_text('Сохранить прогресс', 'Back up progress')),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _text(
                'Копия сохранит профиль, решения и награды для переноса на другое устройство.',
                'Progress is stored in this browser. Save a backup to move your profile, solved tasks and achievements to another device.',
              ),
            ),
            const SizedBox(height: 20),
            if (supportsBackupFiles)
              FilledButton.icon(
                onPressed: _busy ? null : () => _export(),
                icon: const Icon(Icons.download_rounded),
                label: Text(_text('Скачать копию', 'Download backup')),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _export(copy: true),
              icon: const Icon(Icons.copy_rounded),
              label: Text(_text('Скопировать', 'Copy backup')),
            ),
            if (supportsBackupFiles) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _import(),
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(_text('Из файла', 'Restore from file')),
              ),
            ],
            TextButton(
              onPressed: _busy ? null : () => setState(() => _paste = !_paste),
              child: Text(_text('Вставить копию', 'Paste a backup')),
            ),
            if (_paste) ...[
              TextField(
                controller: _input,
                minLines: 3,
                maxLines: 6,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: _text('Содержимое копии', 'Backup contents'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy ? null : () => _import(paste: true),
                child: Text(
                  _text('Проверить и восстановить', 'Review and restore'),
                ),
              ),
            ],
            if (_busy && !_confirming)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _failed ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context, false),
        child: Text(_text('Закрыть', 'Close')),
      ),
    ],
  );
}
