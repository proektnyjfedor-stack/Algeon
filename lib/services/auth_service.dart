library;

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> init() async {}

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static User? currentUser() => _auth.currentUser;

  static bool isLoggedIn() => _auth.currentUser != null;

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() => _auth.signOut();
}
