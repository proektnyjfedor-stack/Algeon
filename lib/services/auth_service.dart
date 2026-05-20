library;

class AuthUser {
  const AuthUser({required this.uid});

  final String uid;
}

class AuthService {
  AuthService._();

  static Future<void> init() async {}

  static Stream<AuthUser?> authStateChanges() =>
      const Stream<AuthUser?>.empty();

  static AuthUser? currentUser() => null;

  static bool isLoggedIn() => false;

  static String loginToEmail(String login) {
    final normalized = login.trim().toLowerCase();
    final cleaned = normalized.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    return '$cleaned@algeon.local';
  }

  static bool isLoginValid(String login) {
    final normalized = login.trim();
    if (normalized.length < 3) return false;
    return RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(normalized);
  }

  static Future<void> signInWithLogin({
    required String login,
    required String password,
  }) async {
    throw UnsupportedError('Login is disabled.');
  }

  static Future<void> registerWithLogin({
    required String login,
    required String password,
  }) async {
    throw UnsupportedError('Registration is disabled.');
  }

  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnsupportedError('Login is disabled.');
  }

  static Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnsupportedError('Registration is disabled.');
  }

  static Future<void> signOut() async {}
}
