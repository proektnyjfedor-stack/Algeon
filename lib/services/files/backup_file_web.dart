import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../backup_service.dart';

const supportsBackupFiles = true;

Future<void> downloadBackup(String text, String name) async {
  final blob = web.Blob(
    [text.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  // Let browsers consume the download URL before releasing it.
  Timer(const Duration(seconds: 5), () => web.URL.revokeObjectURL(url));
}

Future<String?> pickBackupFile() {
  final result = Completer<String?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.json,application/json';
  input.style.display = 'none';
  void complete([String? text, Object? error]) {
    if (result.isCompleted) return;
    input.remove();
    if (error != null) {
      result.completeError(error);
    } else {
      result.complete(text);
    }
  }

  input.addEventListener(
    'change',
    ((web.Event _) {
      final file = input.files?.item(0);
      if (file == null) {
        complete();
        return;
      }
      if (file.size > BackupService.maxBytes) {
        complete(null, const FormatException('Backup is too large'));
        return;
      }
      file.text().toDart.then(
        (value) => complete(value.toDart),
        onError: (Object error) => complete(null, error),
      );
    }).toJS,
  );
  input.addEventListener('cancel', ((web.Event _) => complete()).toJS);
  web.document.body?.appendChild(input);
  input.click();
  return result.future;
}
