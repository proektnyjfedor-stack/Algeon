import '../services/files/backup_file.dart';
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
  final form = GlobalKey<FormState>();
  final emailField = GlobalKey<FormFieldState<String>>();
  final emailFocus = FocusNode(), passwordFocus = FocusNode();
  bool working = false,
      register = false,
      hidePassword = true,
      attempted = false;
  bool hasRecovery = false;
  @override
  void initState() {
    super.initState();
    loadRecovery();
  }

  Future<void> loadRecovery() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(
          () => hasRecovery = prefs.getString('cloud_local_recovery') != null,
        );
      }
    } catch (_) {}
  }

  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Укажи электронную почту.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Проверь адрес: name@example.com';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введи пароль.';
    if (register && value.length < 6) return 'Нужно не менее 6 символов.';
    return null;
  }

  String? error;
  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> authenticate() async {
    if (working) return;
    setState(() => attempted = true);
    if (form.currentState?.validate() != true) {
      (validateEmail(email.text) != null ? emailFocus : passwordFocus)
          .requestFocus();
      return;
    }
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
      if (mounted) password.clear();
      await CloudSyncService.initAndBind();
      if (CloudSyncService.instance.uid != AuthService.currentUser()?.uid) {
        await CloudSyncService.instance.connect();
      }
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

  Future<void> refreshCloud() async {
    if (working) return;
    setState(() {
      working = true;
      error = null;
    });
    try {
      await CloudSyncService.initAndBind();
      await CloudSyncService.instance.connect();
    } catch (_) {
      error = 'Не удалось подключиться. Попробуй позже.';
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
      'Заменить прогресс на этом устройстве облачной копией? Текущая локальная копия останется доступной для скачивания ниже.',
    )) {
      return;
    }
    if (!mounted) return;
    final theme = context.read<ThemeProvider>();
    await CloudSyncService.instance.download();
    await loadRecovery();
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
          title: const Text('Аккаунт'),
          subtitle: Text(
            signedIn
                ? (sync.needsChoice ? 'Проверь сохранение' : 'Выполнен вход')
                : 'Вход и прогресс',
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AutofillGroup(
                child: Form(
                  key: form,
                  autovalidateMode: attempted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        signedIn
                            ? 'Прогресс можно перенести на другое устройство через этот аккаунт.'
                            : 'Сохрани прогресс и продолжай на другом устройстве. Вход необязателен.',
                      ),
                      if (!signedIn) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          key: emailField,
                          controller: email,
                          focusNode: emailFocus,
                          validator: validateEmail,
                          enabled: !disabled,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Электронная почта',
                            errorMaxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: password,
                          focusNode: passwordFocus,
                          validator: validatePassword,
                          enabled: !disabled,
                          textInputAction: TextInputAction.done,
                          obscureText: hidePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: [
                            register
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          onFieldSubmitted: (_) {
                            if (!disabled) authenticate();
                          },
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            errorMaxLines: 2,
                            helperMaxLines: 2,
                            helperText: register ? 'Не менее 6 символов' : null,
                            suffixIcon: IconButton(
                              tooltip: hidePassword
                                  ? 'Показать пароль'
                                  : 'Скрыть пароль',
                              onPressed: disabled
                                  ? null
                                  : () => setState(
                                      () => hidePassword = !hidePassword,
                                    ),
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (working)
                          const LinearProgressIndicator(
                            semanticsLabel: 'Подключение',
                          ),
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
                              : () => setState(() {
                                  register = !register;
                                  error = null;
                                }),
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
                                  if (emailField.currentState?.validate() !=
                                      true) {
                                    emailFocus.requestFocus();
                                    return;
                                  }
                                  final address = email.text.trim();
                                  setState(() {
                                    working = true;
                                    error = null;
                                  });
                                  try {
                                    await AuthService.init();
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(email: address);
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
                        if (sync.remoteSummary != null)
                          Text(sync.remoteSummary!),
                        if (sync.message != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(sync.message!),
                            ),
                          ),
                        if (sync.busy) const LinearProgressIndicator(),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: disabled ? null : refreshCloud,
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
                          child: Semantics(
                            liveRegion: true,
                            child: Text(error!),
                          ),
                        ),
                      if (hasRecovery)
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final copy = prefs.getString(
                              'cloud_local_recovery',
                            );
                            if (copy != null) {
                              if (supportsBackupFiles) {
                                await downloadBackup(
                                  copy,
                                  'algeon-before-cloud.json',
                                );
                              } else {
                                await Clipboard.setData(
                                  ClipboardData(text: copy),
                                );
                              }
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    copy == null
                                        ? 'Предыдущей копии пока нет.'
                                        : supportsBackupFiles
                                        ? 'Копия подготовлена для скачивания.'
                                        : 'Предыдущая копия скопирована. Сохрани текст в файл .json для восстановления.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            supportsBackupFiles
                                ? 'Скачать предыдущую копию'
                                : 'Скопировать предыдущую копию',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
