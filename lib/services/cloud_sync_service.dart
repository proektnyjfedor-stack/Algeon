import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'backup_service.dart';
import 'learning_service.dart';
import 'bookmark_service.dart';

class CloudSyncService extends ChangeNotifier {
  CloudSyncService._();
  static final instance = CloudSyncService._();
  static Future<void> initAndBind() => instance.initialize();
  static Future<void> syncIfSignedIn() => instance.upload();
  static Future<void> syncOnLogin(String uid) => instance.connect();
  static Future<void> syncCurrentUserProgress() => instance.upload();
  bool initialized = false,
      busy = false,
      needsChoice = false,
      hasRemote = false;
  String? message, uid, remoteSummary;
  int revision = 0;
  Timer? _timer;
  StreamSubscription<AuthUser?>? _auth;
  Future<void>? _init;
  bool _suppress = false, _dirty = false;
  int _connection = 0;
  Future<void> initialize() => _init ??= _initialize();
  Future<void> _initialize() async {
    try {
      await AuthService.init();
      initialized = true;
      if (AuthService.ready) {
        _auth = AuthService.authStateChanges().listen((_) {
          unawaited(connect());
        });
        LearningService.instance.addListener(schedule);
        BookmarkService.instance.addListener(schedule);
      }
    } catch (_) {
      message = 'Облачное сохранение недоступно. Попробуй позже.';
      _init = null;
    }
    notifyListeners();
  }

  DocumentReference<Map<String, dynamic>> get doc =>
      FirebaseFirestore.instance.collection('progress').doc(uid!);
  String get revisionKey => 'cloud_revision_$uid';
  Future<void> connect() async {
    final generation = ++_connection;
    _timer?.cancel();
    uid = AuthService.currentUser()?.uid;
    revision = 0;
    needsChoice = false;
    hasRemote = false;
    remoteSummary = null;
    message = null;
    if (uid == null) {
      busy = false;
      notifyListeners();
      return;
    }
    busy = true;
    notifyListeners();
    try {
      final snapshot = await doc
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 20));
      if (generation != _connection || uid != AuthService.currentUser()?.uid) {
        return;
      }
      hasRemote = snapshot.exists;
      if (hasRemote) {
        final payload = snapshot.data()?['payload'];
        if (payload is! String) {
          throw const FormatException('Invalid cloud copy');
        }
        validateSize(payload);
        final data = BackupService.validate(payload);
        final count = (data['solved_tasks'] as List? ?? []).length;
        final date = (snapshot.data()?['updatedAt'] as Timestamp?)
            ?.toDate()
            .toLocal();
        remoteSummary =
            'В облаке: $count решённых заданий · ${data['current_grade'] ?? 5} класс${date == null ? '' : ' · ${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'}';
      }
      revision = snapshot.data()?['revision'] as int? ?? 0;
      final prefs = await SharedPreferences.getInstance();
      needsChoice =
          hasRemote &&
          (prefs.getInt(revisionKey) != revision ||
              prefs.getString('cloud_local_owner') != uid);
      message = needsChoice
          ? 'На другом устройстве есть сохранение. Выбери, какую копию использовать.'
          : hasRemote
          ? 'Сохранение подключено.'
          : 'Первое облачное сохранение готово к созданию.';
      if (!needsChoice) schedule();
    } catch (_) {
      needsChoice = true;
      message =
          'Не удалось проверить облачную копию. Локальный прогресс сохранён.';
    } finally {
      if (generation == _connection) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void schedule() {
    if (uid == null || needsChoice || _suppress) return;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      unawaited(upload());
    });
  }

  static void validateSize(String payload) {
    BackupService.validate(payload);
    if (utf8.encode(payload).length > 800000) {
      throw const FormatException(
        'Копия больше лимита. Сохрани её файлом или уменьши фото профиля.',
      );
    }
  }

  Future<void> upload({bool replace = false}) async {
    if (uid == null || needsChoice && !replace) return;
    if (busy) {
      _dirty = true;
      return;
    }
    _dirty = false;
    final owner = uid!;
    final expected = revision;
    final reference = doc;
    busy = true;
    notifyListeners();
    try {
      final payload = await BackupService.export();
      validateSize(payload);
      final next = await FirebaseFirestore.instance.runTransaction<int>((
        transaction,
      ) async {
        final snapshot = await transaction.get(reference);
        final current = snapshot.data()?['revision'] as int? ?? 0;
        // Explicit replace still requires the latest inspected revision.
        if (current != expected) throw StateError('conflict');
        transaction.set(reference, {
          'payload': payload,
          'revision': current + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return current + 1;
      });
      if (uid != owner) return;
      revision = next;
      hasRemote = true;
      needsChoice = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(revisionKey, next);
      await prefs.setString('cloud_local_owner', owner);
      final savedData = BackupService.validate(payload);
      remoteSummary =
          'В облаке: ${(savedData['solved_tasks'] as List? ?? []).length} решённых заданий · ${savedData['current_grade'] ?? 5} класс';
      message = 'Прогресс сохранён в аккаунте.';
    } on FormatException catch (e) {
      message = e.message;
    } catch (_) {
      needsChoice = true;
      message =
          'Сохранение не обновлено. Проверь соединение и сравни копии перед повтором.';
    } finally {
      busy = false;
      notifyListeners();
      if (_dirty && !needsChoice) schedule();
    }
  }

  Future<void> download() async {
    if (uid == null || busy) return;
    final owner = uid!;
    busy = true;
    _suppress = true;
    _timer?.cancel();
    notifyListeners();
    try {
      final snapshot = await doc
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 20));
      if (uid != owner) return;
      final data = snapshot.data();
      if (data == null) throw StateError('No cloud copy');
      final payload = data['payload'] as String;
      validateSize(payload);
      final prefs = await SharedPreferences.getInstance();
      final recovery = await BackupService.export();
      BackupService.validate(recovery);
      if (uid != owner) return;
      if (!await prefs.setString('cloud_local_recovery', recovery)) {
        throw StateError('Could not preserve local recovery');
      }
      await BackupService.restore(payload);
      revision = data['revision'] as int;
      await prefs.setInt(revisionKey, revision);
      await prefs.setString('cloud_local_owner', owner);
      needsChoice = false;
      hasRemote = true;
      message =
          'Облачный прогресс загружен. Предыдущая локальная копия сохранена для восстановления.';
    } catch (_) {
      message = 'Не удалось загрузить копию. Локальные данные не заменены.';
    } finally {
      busy = false;
      _suppress = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth?.cancel();
    _timer?.cancel();
    LearningService.instance.removeListener(schedule);
    BookmarkService.instance.removeListener(schedule);
    super.dispose();
  }
}
