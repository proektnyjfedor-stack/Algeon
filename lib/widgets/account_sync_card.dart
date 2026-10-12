import '../services/progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/language_service.dart';
import '../theme/theme_provider.dart';

class AccountSyncCard extends StatefulWidget {
  const AccountSyncCard({super.key});
  @override
  State<AccountSyncCard> createState() => _AccountSyncCardState();
}

class _AccountSyncCardState extends State<AccountSyncCard> {
  final email = TextEditingController(), password = TextEditingController();
  bool working = false, register = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> authenticate() async {
    setState(() {
      working = true;
      error = null;
    });
    try {
      if (register) {
        await AuthService.registerWithEmail(
          email: email.text,
          password: password.text,
        );
      } else {
        await AuthService.signInWithEmail(
          email: email.text,
          password: password.text,
        );
      }
      password.clear();
    } on FirebaseAuthException catch (e) {
      error = switch (e.code) {
        'invalid-email' => 'Проверь адрес почты.',
        'weak-password' => 'Используй пароль не короче 6 символов.',
        'email-already-in-use' =>
          'Этот адрес уже зарегистрирован. Выбери вход.',
        'too-many-requests' => 'Слишком много попыток. Попробуй позже.',
        'network-request-failed' => 'Проверь соединение с интернетом.',
        _ => 'Не удалось войти. Проверь почту и пароль.',
      };
    } catch (_) {
      error = 'Вход пока недоступен. Попробуй позже.';
    }
    if (mounted) setState(() => working = false);
  }

  Future<bool> confirm(String text) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Выбор сохранения'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> download() async {
    if (!await confirm(
      'Заменить прогресс на этом устройстве облачной копией? Текущая локальная копия останется доступной для копирования ниже.',
    )) {
      return;
    }
    if (!mounted) return;
    final theme = context.read<ThemeProvider>();
    await CloudSyncService.instance.download();
    await LanguageService.instance.init();
    await theme.reload();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CloudSyncService.instance,
    builder: (context, _) {
      final sync = CloudSyncService.instance;
      final signedIn = AuthService.isLoggedIn();
      final disabled = working || sync.busy;
      return Card(
        child: ExpansionTile(
          title: const Text('Аккаунт и сохранение'),
          subtitle: Text(
            signedIn
                ? (sync.needsChoice
                      ? 'Нужно выбрать копию'
                      : 'Аккаунт подключён')
                : 'Перенос прогресса между устройствами',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    signedIn
                        ? 'Прогресс можно перенести на другое устройство через этот аккаунт.'
                        : 'Войди, чтобы сохранять прогресс в аккаунте. Без входа он остаётся на этом устройстве.',
                  ),
                  if (!signedIn) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Электронная почта',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      autofillHints: [
                        register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onSubmitted: (_) {
                        if (!disabled) authenticate();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        helperText: 'Не менее 6 символов',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: disabled ? null : authenticate,
                      child: Text(
                        working
                            ? 'Подключение…'
                            : register
                            ? 'Создать аккаунт'
                            : 'Войти',
                      ),
                    ),
                    TextButton(
                      onPressed: disabled
                          ? null
                          : () => setState(() => register = !register),
                      child: Text(
                        register
                            ? 'Уже есть аккаунт? Войти'
                            : 'Создать аккаунт',
                      ),
                    ),
                    TextButton(
                      onPressed: disabled
                          ? null
                          : () async {
                              if (email.text.trim().isEmpty) {
                                setState(() => error = 'Сначала укажи почту.');
                                return;
                              }
                              setState(() => working = true);
                              try {
                                await AuthService.init();
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                      email: email.text.trim(),
                                    );
                                error =
                                    'Если аккаунт существует, письмо для смены пароля отправлено.';
                              } catch (_) {
                                error =
                                    'Не удалось запросить письмо. Проверь адрес и соединение.';
                              }
                              if (mounted) setState(() => working = false);
                            },
                      child: const Text('Забыли пароль?'),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Text(FirebaseAuth.instance.currentUser?.email ?? ''),
                    const SizedBox(height: 8),
                    Text(
                      'На устройстве: ${ProgressService.getTotalSolved()} решённых заданий',
                    ),
                    if (sync.remoteSummary != null) Text(sync.remoteSummary!),
                    if (sync.message != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(sync.message!),
                      ),
                    if (sync.busy) const LinearProgressIndicator(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: disabled ? null : sync.connect,
                          child: const Text('Проверить облачную копию'),
                        ),
                        FilledButton(
                          onPressed: disabled
                              ? null
                              : () async {
                                  if (sync.needsChoice &&
                                      !await confirm(
                                        'Заменить облачную копию прогрессом этого устройства? Сначала проверь, что здесь нужные результаты.',
                                      )) {
                                    return;
                                  }
                                  await sync.upload(replace: true);
                                },
                          child: const Text('Сохранить это устройство'),
                        ),
                        if (sync.hasRemote)
                          OutlinedButton(
                            onPressed: disabled ? null : download,
                            child: const Text('Загрузить из аккаунта'),
                          ),
                        TextButton(
                          onPressed: disabled ? null : AuthService.signOut,
                          child: const Text('Выйти'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ответы сохраняются автоматически при доступном интернете. Изменённые настройки можно сохранить кнопкой выше. При конфликте выбери копию вручную.',
                    ),
                  ],
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!),
                    ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final copy = prefs.getString('cloud_local_recovery');
                      if (copy != null) {
                        await Clipboard.setData(ClipboardData(text: copy));
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              copy == null
                                  ? 'Предыдущей копии пока нет.'
                                  : 'Предыдущая копия скопирована. Сохрани текст в файл .json для восстановления.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Скопировать предыдущую локальную копию'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
