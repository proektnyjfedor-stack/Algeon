import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../data/tasks_data.dart';

/// The one unfinished practice session, restored after a refresh or reopening.
class StudySessionService {
  static SharedPreferences? _prefs;
  static const _key = 'unfinished_study_session';
  static Map<String, dynamic>? _current;
  static Future<void> _pending = Future<void>.value();
  static Map<String, dynamic>? get current =>
      _current == null ? null : Map.of(_current!);
  static List<Task> get tasks => (_current?['ids'] as List? ?? [])
      .map((id) => getTaskById(id as String))
      .whereType<Task>()
      .toList();

  static Future<void> init() async {
    await _pending;
    _prefs = await SharedPreferences.getInstance();
    _current = null;
    try {
      final raw = _prefs?.getString(_key);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      final ids = decoded['ids'];
      if (ids is! List ||
          ids.isEmpty ||
          ids.length > 1000 ||
          ids.any((id) => id is! String || getTaskById(id) == null)) {
        return;
      }
      final index = decoded['index'];
      if (index is! int ||
          index < 0 ||
          index >= ids.length ||
          decoded['topic'] is! String) {
        return;
      }
      for (final key in ['correct', 'wrong', 'skipped', 'elapsed']) {
        final value = decoded[key];
        if (value is! int || value < 0) return;
      }
      if (decoded['correct'] + decoded['wrong'] > ids.length ||
          decoded['skipped'] > decoded['wrong']) {
        return;
      }
      if (decoded['checked'] is! bool ||
          decoded['isCorrect'] is! bool ||
          decoded['answer'] is! String ||
          decoded['selected'] != null && decoded['selected'] is! String) {
        return;
      }
      if (decoded['wrongIds'] is! List ||
          (decoded['wrongIds'] as List).any((id) => !ids.contains(id))) {
        return;
      }
      _current = decoded;
    } catch (_) {
      /* A broken old session must not stop the app from opening. */
    }
  }

  static Map<String, dynamic>? forLesson(String topic, List<Task> lesson) {
    final saved = _current;
    if (saved == null || saved['topic'] != topic) return null;
    final ids = saved['ids'] as List;
    if (ids.length != lesson.length) return null;
    for (var i = 0; i < ids.length; i++) {
      if (ids[i] != lesson[i].id) return null;
    }
    return Map.of(saved);
  }

  static Future<void> save(Map<String, dynamic> data) {
    _current = Map.of(data);
    final text = jsonEncode(data);
    final result = _pending.then((_) async {
      _prefs ??= await SharedPreferences.getInstance();
      if (!await _prefs!.setString(_key, text)) {
        throw StateError("Session could not be saved");
      }
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  static Future<void> clear() {
    _current = null;
    final result = _pending.then((_) async {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove(_key);
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
