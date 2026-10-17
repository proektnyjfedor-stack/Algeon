const supportsBackupFiles = false;
Future<void> downloadBackup(
  String text,
  String name, {
  String mimeType = 'application/json;charset=utf-8',
}) async => throw UnsupportedError('Use copy instead');
Future<String?> pickBackupFile() async => null;
