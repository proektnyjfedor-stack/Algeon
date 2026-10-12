import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'backup_service.dart';
import 'learning_service.dart';
import 'bookmark_service.dart';
import 'cloud_progress_store.dart';
import 'exam_progress.dart';
import 'mock_exam_service.dart';

class CloudSyncService extends ChangeNotifier {
  @visibleForTesting
  factory CloudSyncService.forTesting({
    required CloudProgressStore store,
    required String? Function() currentUid,
    required Future<String> Function() export,
    required Future<void> Function(String) restore,
    Duration debounce = const Duration(seconds: 3),
  }) => CloudSyncService._(
    store: store,
    currentUid: currentUid,
    export: export,
    restore: restore,
    debounce: debounce,
  );
  CloudSyncService._({
    required CloudProgressStore store,
    required String? Function() currentUid,
    required Future<String> Function() export,
    required Future<void> Function(String) restore,
    Duration debounce = const Duration(seconds: 3),
  }) : _store = store,
       _currentUid = currentUid,
       _export = export,
       _restore = restore,
       _debounce = debounce {
    LearningService.instance.addListener(schedule);
    BookmarkService.instance.addListener(schedule);
    ExamProgress.changes.addListener(schedule);
    MockExamService.changes.addListener(schedule);
  }
  static final instance = CloudSyncService._(
    store: FirebaseProgressStore(),
    currentUid: () => AuthService.currentUser()?.uid,
    export: BackupService.export,
    restore: BackupService.restore,
  );
  final Duration _debounce;
  final CloudProgressStore _store;
  final String? Function() _currentUid;
  final Future<String> Function() _export;
  final Future<void> Function(String) _restore;
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
  Future<void>? _init, _restoreInFlight;
  bool _suppress = false, _dirty = false, _disposed = false;
  int _generation = 0;
  bool _active(int generation, String owner) =>
      !_disposed &&
      generation == _generation &&
      uid == owner &&
      _currentUid() == owner;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() => _init ??= _initialize();
  Future<void> _initialize() async {
    try {
      await AuthService.init();
      if (_disposed) return;
      initialized = true;
      if (AuthService.ready) {
        _auth = AuthService.authStateChanges().listen((_) {
          unawaited(connect());
        });
      }
    } catch (_) {
      message = 'Облачное сохранение недоступно. Попробуй позже.';
      _init = null;
    }
    _notify();
  }

  String _revisionKey(String owner) => 'cloud_revision_$owner';
  String _summary(CloudProgressCopy copy) {
    final data = BackupService.validate(copy.payload);
    final count = (data['solved_tasks'] as List? ?? []).length;
    final date = copy.updatedAt?.toLocal();
    return 'В облаке: $count решённых заданий · ${data['current_grade'] ?? 5} класс${date == null ? '' : ' · ${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'}';
  }

  void _validateCopy(CloudProgressCopy copy) {
    validateSize(copy.payload);
    if (copy.revision <= 0) {
      throw const FormatException('Invalid cloud revision');
    }
  }

  Future<void> connect() async {
    if (_disposed) return;
    final generation = ++_generation;
    _suppress = _restoreInFlight != null;
    _timer?.cancel();
    _dirty = false;
    final owner = _currentUid();
    uid = owner;
    revision = 0;
    needsChoice = false;
    hasRemote = false;
    remoteSummary = null;
    message = null;
    busy = owner != null;
    _notify();
    if (owner == null) return;
    try {
      // Finish an already approved local restore before reading ownership metadata
      // for a newly signed-in account. Do not start an automatic upload meanwhile.
      try {
        await _restoreInFlight;
      } catch (_) {}
      if (!_active(generation, owner)) return;
      _suppress = false;
      final copy = await _store.read(owner);
      if (!_active(generation, owner)) return;
      if (copy != null) {
        _validateCopy(copy);
        hasRemote = true;
        revision = copy.revision;
        remoteSummary = _summary(copy);
      }
      final prefs = await SharedPreferences.getInstance();
      if (!_active(generation, owner)) return;
      final localOwner = prefs.getString('cloud_local_owner');
      needsChoice =
          (hasRemote && prefs.getInt(_revisionKey(owner)) != revision) ||
          (localOwner != null && localOwner != owner) ||
          (hasRemote && localOwner == null);
      message = needsChoice
          ? 'Выбери копию: прогресс на устройстве и в аккаунте может отличаться.'
          : hasRemote
          ? 'Сохранение подключено.'
          : 'Первое облачное сохранение готово к созданию.';
      if (!needsChoice) schedule();
    } catch (_) {
      if (_active(generation, owner)) {
        needsChoice = true;
        message =
            'Не удалось проверить облачную копию. Локальный прогресс сохранён.';
      }
    } finally {
      if (_active(generation, owner)) {
        busy = false;
        _notify();
      }
    }
  }

  void schedule() {
    if (_disposed || uid == null || needsChoice || _suppress) return;
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_debounce, () {
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
    if (_disposed || uid == null || needsChoice && !replace || _suppress) {
      return;
    }
    if (busy) {
      _dirty = true;
      return;
    }
    final generation = _generation, owner = uid!, expected = revision;
    if (!_active(generation, owner)) return;
    _timer?.cancel();
    _dirty = false;
    busy = true;
    _notify();
    try {
      final payload = await _export();
      validateSize(payload);
      if (!_active(generation, owner)) return;
      final next = await _store.write(
        owner,
        payload,
        expectedRevision: expected,
      );
      if (!_active(generation, owner)) return;
      final prefs = await SharedPreferences.getInstance();
      if (!_active(generation, owner)) return;
      if (!await prefs.setInt(_revisionKey(owner), next) ||
          !await prefs.setString('cloud_local_owner', owner)) {
        throw StateError('Could not record cloud revision');
      }
      if (!_active(generation, owner)) return;
      revision = next;
      hasRemote = true;
      needsChoice = false;
      remoteSummary = _summary(
        CloudProgressCopy(
          payload: payload,
          revision: next,
          updatedAt: DateTime.now(),
        ),
      );
      message = 'Прогресс сохранён в аккаунте.';
    } on FormatException catch (e) {
      if (_active(generation, owner)) message = e.message;
    } catch (_) {
      if (_active(generation, owner)) {
        needsChoice = true;
        message =
            'Сохранение не обновлено. Проверь соединение и сравни копии перед повтором.';
      }
    } finally {
      if (_active(generation, owner)) {
        busy = false;
        _notify();
        if (_dirty && !needsChoice) schedule();
      }
    }
  }

  Future<void> download() async {
    if (_disposed || uid == null || busy) return;
    final generation = _generation, owner = uid!;
    if (!_active(generation, owner)) return;
    busy = true;
    _suppress = true;
    _timer?.cancel();
    _notify();
    var preserved = false;
    try {
      final copy = await _store.read(owner);
      if (!_active(generation, owner)) return;
      if (copy == null) throw StateError('No cloud copy');
      _validateCopy(copy);
      final prefs = await SharedPreferences.getInstance();
      final recovery = await _export();
      BackupService.validate(recovery);
      if (!_active(generation, owner)) return;
      if (!await prefs.setString('cloud_local_recovery', recovery)) {
        throw StateError('Could not preserve local copy');
      }
      preserved = true;
      if (!_active(generation, owner)) return;
      final applying = _applyRemote(owner, copy, prefs);
      _restoreInFlight = applying;
      try {
        await applying;
      } finally {
        if (identical(_restoreInFlight, applying)) _restoreInFlight = null;
      }
      if (!_active(generation, owner)) return;
      revision = copy.revision;
      needsChoice = false;
      hasRemote = true;
      remoteSummary = _summary(copy);
      message =
          'Облачный прогресс загружен. Предыдущая локальная копия сохранена для восстановления.';
    } catch (_) {
      if (_active(generation, owner)) {
        needsChoice = true;
        message = preserved
            ? 'Не удалось завершить загрузку. Предыдущая локальная копия доступна для восстановления.'
            : 'Не удалось загрузить копию. Прогресс на устройстве сохранён.';
      }
    } finally {
      if (_active(generation, owner)) {
        _suppress = false;
        busy = false;
        _notify();
      }
    }
  }

  Future<void> _applyRemote(
    String owner,
    CloudProgressCopy copy,
    SharedPreferences prefs,
  ) async {
    // An interrupted restore must never appear to belong to another account.
    if (!await prefs.setString('cloud_local_owner', 'restoring:$owner')) {
      throw StateError('Could not mark restore');
    }
    await _restore(copy.payload);
    if (!await prefs.setInt(_revisionKey(owner), copy.revision) ||
        !await prefs.setString('cloud_local_owner', owner)) {
      throw StateError('Could not finish restore metadata');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _auth?.cancel();
    _timer?.cancel();
    LearningService.instance.removeListener(schedule);
    BookmarkService.instance.removeListener(schedule);
    ExamProgress.changes.removeListener(schedule);
    MockExamService.changes.removeListener(schedule);
    super.dispose();
  }
}
