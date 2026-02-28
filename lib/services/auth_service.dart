/// Auth Service — Firebase Authentication (Web-only)
///
/// Email/Password, Google Sign-In (popup), Apple Sign-In (popup)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static SharedPreferences? _prefs;

  static const String _keyAuthMethod = 'auth_method';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Текущий пользователь Firebase
  static User? get currentUser => _auth.currentUser;

  /// Пользователь авторизован?
  static bool isLoggedIn() => _auth.currentUser != null;

  /// Получить email
  static String? getUserEmail() => _auth.currentUser?.email;

  /// Получить метод авторизации
  static String? getAuthMethod() => _prefs?.getString(_keyAuthMethod);

  // ============================================================
  // EMAIL / PASSWORD
  // ============================================================

  /// Регистрация через Email
  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _prefs?.setString(_keyAuthMethod, 'email');
    return credential;
  }

  /// Вход через Email
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _prefs?.setString(_keyAuthMethod, 'email');
    return credential;
  }

  // ============================================================
  // GOOGLE (Web popup)
  // ============================================================

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final result = await _auth.signInWithPopup(googleProvider);
      await _prefs?.setString(_keyAuthMethod, 'google');
      return result;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return null;
    }
  }

  // ============================================================
  // APPLE (Web popup)
  // ============================================================

  static Future<UserCredential?> signInWithApple() async {
    try {
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final result = await _auth.signInWithPopup(appleProvider);
      await _prefs?.setString(_keyAuthMethod, 'apple');
      return result;
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      return null;
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  static Future<void> signOut() async {
    await _auth.signOut();
    await _prefs?.remove(_keyAuthMethod);
  }

  // ============================================================
  // LEGACY ALIASES (for old screens that still reference these)
  // ============================================================

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => signInWithEmail(email: email, password: password);

  static Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await registerWithEmail(email: email, password: password);
    if (displayName != null) {
      await cred.user?.updateDisplayName(displayName);
    }
    return cred;
  }

  static Future<void> sendPhoneCode({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required Function(String) onError,
  }) async {
    onError('Phone auth not supported');
  }

  static Future<bool> verifyPhoneCode(String code) async => false;
}
