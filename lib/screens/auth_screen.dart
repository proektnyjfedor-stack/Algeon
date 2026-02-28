/// Auth Screen — Вход и регистрация (Firebase)
///
/// Email/пароль + Apple + Google

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';

/// Тип экрана авторизации
enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode newMode) {
    setState(() {
      _mode = newMode;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(Icons.calculate_rounded,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _mode == AuthMode.login
                              ? 'С возвращением!'
                              : 'Создай аккаунт',
                          style: AppTypography.h1.copyWith(
                            color: AppThemeColors.textPrimary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mode == AuthMode.login
                              ? 'Войди, чтобы продолжить'
                              : 'Зарегистрируйся для сохранения прогресса',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppThemeColors.textSecondary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Social buttons
                  _buildSocialButtons(),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 1,
                              color: AppThemeColors.border(context))),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'или по email',
                          style: TextStyle(
                              color: AppThemeColors.textHint(context),
                              fontSize: 14),
                        ),
                      ),
                      Expanded(
                          child: Container(
                              height: 1,
                              color: AppThemeColors.border(context))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Form
                  _buildForm(),

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _mode == AuthMode.login
                                  ? 'Войти'
                                  : 'Создать аккаунт',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Toggle
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _switchMode(_mode == AuthMode.login
                            ? AuthMode.register
                            : AuthMode.login);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 15),
                          children: [
                            TextSpan(
                              text: _mode == AuthMode.login
                                  ? 'Нет аккаунта? '
                                  : 'Уже есть аккаунт? ',
                              style: TextStyle(
                                  color: AppThemeColors.textSecondary(
                                      context)),
                            ),
                            TextSpan(
                              text: _mode == AuthMode.login
                                  ? 'Зарегистрируйся'
                                  : 'Войти',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Apple
        _buildSocialButton(
          onTap: _signInWithApple,
          icon: Icons.apple,
          label: 'Продолжить с Apple',
          backgroundColor: AppThemeColors.textPrimary(context),
          textColor: AppThemeColors.background(context),
        ),
        const SizedBox(height: 12),

        // Google
        _buildSocialButton(
          onTap: _signInWithGoogle,
          icon: Icons.g_mobiledata,
          label: 'Продолжить с Google',
          backgroundColor: AppThemeColors.surface(context),
          textColor: AppThemeColors.textPrimary(context),
          hasBorder: true,
          iconColor: const Color(0xFF4285F4),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    bool hasBorder = false,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder
              ? Border.all(
                  color: AppThemeColors.border(context), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? textColor, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email
        _buildTextField(
          controller: _emailController,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),

        const SizedBox(height: 16),

        // Password
        _buildTextField(
          controller: _passwordController,
          hint: 'Пароль',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppThemeColors.textHint(context),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        // Error
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppThemeColors.errorLight(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppThemeColors.border(context), width: 2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
            fontSize: 16,
            color: AppThemeColors.textPrimary(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: AppThemeColors.textHint(context)),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: AppThemeColors.textHint(context))
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _submit() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(
          () => _errorMessage = 'Заполни все поля');
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() =>
          _errorMessage = 'Неверный формат email');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() =>
          _errorMessage = 'Пароль минимум 6 символов');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      if (_mode == AuthMode.login) {
        await AuthService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await AuthService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      _navigateNext();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _firebaseErrorMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      setState(() =>
          _errorMessage = 'Ошибка авторизации');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      final result = await AuthService.signInWithApple();
      if (!mounted) return;

      if (result != null) {
        _navigateNext();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка входа через Apple';
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      final result = await AuthService.signInWithGoogle();
      if (!mounted) return;

      if (result != null) {
        _navigateNext();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка входа через Google';
      });
    }
  }

  void _navigateNext() {
    if (ProgressService.isOnboardingComplete()) {
      context.go('/learn');
    } else {
      context.go('/onboarding');
    }
  }

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'weak-password':
        return 'Слишком простой пароль';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуй позже';
      case 'invalid-credential':
        return 'Неверный email или пароль';
      default:
        return 'Ошибка авторизации';
    }
  }
}
