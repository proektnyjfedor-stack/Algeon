library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _register = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (email.isEmpty || password.length < 6) {
      setState(() => _error = 'Введите email и пароль (минимум 6 символов).');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_register) {
        await AuthService.registerWithEmail(email: email, password: password);
      } else {
        await AuthService.signInWithEmail(email: email, password: password);
      }
      if (!mounted) return;
      if (!ProgressService.isOnboardingComplete()) {
        context.go(AppRoutes.onboarding);
      } else {
        context.go(AppRoutes.learn);
      }
    } catch (e) {
      setState(() => _error = _humanizeError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _humanizeError(Object e) {
    final s = e.toString();
    if (s.contains('invalid-email')) return 'Некорректный email.';
    if (s.contains('email-already-in-use')) return 'Этот email уже зарегистрирован.';
    if (s.contains('user-not-found') || s.contains('wrong-password')) {
      return 'Неверный email или пароль.';
    }
    return 'Не удалось войти. Попробуйте еще раз.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _register ? 'Регистрация' : 'Вход',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Пароль'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(_loading
                          ? 'Загрузка...'
                          : (_register ? 'Создать аккаунт' : 'Войти')),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _register = !_register),
                    child: Text(
                      _register
                          ? 'Уже есть аккаунт? Войти'
                          : 'Нет аккаунта? Зарегистрироваться',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
