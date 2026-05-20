library;

class CloudSyncService {
  CloudSyncService._();

  static Future<void> initAndBind() async {}

  static Future<void> syncIfSignedIn() async {}

  static Future<void> syncOnLogin(String uid) async {}

  static Future<void> syncCurrentUserProgress() async {}
}
