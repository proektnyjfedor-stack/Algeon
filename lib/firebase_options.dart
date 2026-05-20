library;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static Object get currentPlatform {
    throw UnsupportedError('Firebase is disabled in this build.');
  }
}
