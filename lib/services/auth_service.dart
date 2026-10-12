import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

class AuthUser {
  const AuthUser({required this.uid});
  final String uid;
}

class AuthService {
  AuthService._();
  static Future<void>? _pending;
  static bool ready = false;
  static Future<void> init() => _pending ??= _initialize();
  static Future<void> _initialize() async {
    if (!kIsWeb) return;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      ready = true;
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }

  static Stream<AuthUser?> authStateChanges() => ready
      ? FirebaseAuth.instance.authStateChanges().map(
          (u) => u == null ? null : AuthUser(uid: u.uid),
        )
      : const Stream.empty();
  static AuthUser? currentUser() {
    final u = ready ? FirebaseAuth.instance.currentUser : null;
    return u == null ? null : AuthUser(uid: u.uid);
  }

  static bool isLoggedIn() => currentUser() != null;
  static String loginToEmail(String login) =>
      '${login.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '')}@algeon.local';
  static bool isLoginValid(String login) =>
      login.trim().length >= 3 &&
      RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(login.trim());
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await init();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    await init();
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signInWithLogin({
    required String login,
    required String password,
  }) => signInWithEmail(email: loginToEmail(login), password: password);
  static Future<void> registerWithLogin({
    required String login,
    required String password,
  }) => registerWithEmail(email: loginToEmail(login), password: password);
  static Future<void> signOut() async {
    if (ready) await FirebaseAuth.instance.signOut();
  }
}
