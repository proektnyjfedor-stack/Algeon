import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A wall-clock deadline survives reloads and background throttling.
class MockExamService {
  /// Emitted only after a local change has been persisted successfully.
  static final _changes = ValueNotifier<int>(0);
  static ValueListenable<int> get changes => _changes;
  static int minutes(String track) => track == 'base' ? 180 : 235;
  static Set<String> get keys => {
    for (final track in ['oge', 'base', 'profile'])
      for (var i = 1; i <= 10; i++) 'mock_exam_$track-$i',
  };
  static Future<void> _queue = Future.value();
  static int _pendingWrites = 0;
  static Map<String, dynamic> validate(String raw, String id) {
    final d = jsonDecode(raw);
    final max = id.startsWith('oge-')
        ? 25
        : id.startsWith('base-')
        ? 21
        : 20;
    if (!keys.contains('mock_exam_$id') ||
        d is! Map<String, dynamic> ||
        d['version'] != 1 ||
        d['id'] != id ||
        d['started'] is! int ||
        d['started'] < 0 ||
        d['deadline'] is! int ||
        d['deadline'] !=
            d['started'] +
                Duration(
                  minutes: minutes(id.split('-').first),
                ).inMilliseconds ||
        d['index'] is! int ||
        d['index'] < 0 ||
        d['index'] >= max ||
        d['answers'] is! Map ||
        d['flags'] is! List) {
      throw const FormatException('Invalid mock exam');
    }
    for (final entry in (d['answers'] as Map).entries) {
      final n = int.tryParse(entry.key.toString());
      if (n == null ||
          n < 0 ||
          n >= max ||
          entry.value is! String ||
          (entry.value as String).length > 10000) {
        throw const FormatException('Invalid mock answer');
      }
    }
    if ((d['flags'] as List).length > max ||
        (d['flags'] as List).any((n) => n is! int || n < 0 || n >= max)) {
      throw const FormatException('Invalid flags');
    }
    if (d['submitted'] != null &&
        (d['submitted'] is! int || d['submitted'] < d['started'])) {
      throw const FormatException('Invalid submission');
    }
    if (d['journaled'] != null &&
        (d['journaled'] is! bool || d['submitted'] == null)) {
      throw const FormatException('Invalid journal status');
    }
    return d;
  }

  static Map<String, dynamic> start(String id, DateTime now) => {
    'version': 1,
    'id': id,
    'started': now.millisecondsSinceEpoch,
    'deadline': now
        .add(Duration(minutes: minutes(id.split('-').first)))
        .millisecondsSinceEpoch,
    'index': 0,
    'answers': <String, String>{},
    'flags': <int>[],
  };
  static Duration remaining(Map session, DateTime now) => Duration(
    milliseconds: ((session['deadline'] as int) - now.millisecondsSinceEpoch)
        .clamp(0, const Duration(days: 1).inMilliseconds),
  );
  static Future<Map<String, dynamic>?> read(String id) async {
    if (_pendingWrites > 0) await _queue;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('mock_exam_$id');
    if (raw == null) return null;
    try {
      return validate(raw, id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Map<String, dynamic> session) {
    final raw = jsonEncode(session);
    final id = session['id'] as String;
    validate(raw, id);
    if (_pendingWrites == 0) _queue = Future.value();
    _pendingWrites++;
    final result = _queue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('mock_exam_$id', raw)) {
        throw StateError('Mock exam not saved');
      }
      _changes.value++;
    });
    _queue = result.then<void>(
      (_) {
        _pendingWrites--;
      },
      onError: (Object _, StackTrace _) {
        _pendingWrites--;
      },
    );
    return result;
  }

  static Future<void> flush() => _pendingWrites == 0 ? Future.value() : _queue;
  static Future<void> clear() async {
    if (_pendingWrites > 0) await _queue;
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      if (!await prefs.remove(key)) {
        throw StateError('Mock exam progress not cleared');
      }
    }
    _changes.value++;
  }
}
