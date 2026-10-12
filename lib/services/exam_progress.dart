import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamProgress {
  /// Emitted only after a local change has been persisted successfully.
  static final _changes = ValueNotifier<int>(0);
  static ValueListenable<int> get changes => _changes;
  static Future<void> _tail = Future.value();
  static final Set<Future<void>> _pending = {};

  static Future<void> _enqueue(Future<void> Function() action) {
    // Start a fresh chain after an idle period; completed operations need not
    // retain an old async context or a growing future chain.
    if (_pending.isEmpty) _tail = Future.value();
    final result = _tail.then((_) async {
      await action();
      _changes.value++;
    });
    _pending.add(result);
    // Keep the next operation usable after a failure, while returning the
    // original failed future to its caller and any active flush.
    _tail = result.then<void>(
      (_) => _pending.remove(result),
      onError: (Object _, StackTrace _) {
        _pending.remove(result);
      },
    );
    return result;
  }

  static Future<void> flush() async {
    while (_pending.isNotEmpty) {
      await Future.wait(_pending.toList());
    }
  }

  static Set<String> get keys => {
    for (final track in ['oge', 'base', 'profile'])
      for (var i = 1; i <= 10; i++) 'exam_$track-$i',
  };
  static Map<String, dynamic> validate(String contents, String key) {
    final decoded = jsonDecode(contents);
    final count = key.startsWith('exam_oge-')
        ? 25
        : key.startsWith('exam_base-')
        ? 21
        : 20;
    if (!keys.contains(key) ||
        decoded is! Map ||
        decoded['index'] is! int ||
        decoded['index'] < 0 ||
        decoded['index'] >= count ||
        decoded['records'] is! Map) {
      throw const FormatException('Invalid exam progress');
    }
    for (final entry in (decoded['records'] as Map).entries) {
      final slot = int.tryParse(entry.key.toString());
      final record = entry.value;
      if (slot == null ||
          slot < 0 ||
          slot >= count ||
          record is! Map ||
          record['input'] is! String ||
          (record['input'] as String).length > 10000 ||
          ![null, 'correct', 'wrong', 'reviewed'].contains(record['status'])) {
        throw const FormatException('Invalid exam answer');
      }
      if ((record['selfAssessed'] != null && record['selfAssessed'] is! bool) ||
          (record['selfCorrect'] != null && record['selfCorrect'] is! bool) ||
          (record['criteria'] != null &&
              (record['criteria'] is! List ||
                  (record['criteria'] as List).length > 4 ||
                  (record['criteria'] as List).any(
                    (v) => v is! String || v.length > 100,
                  )))) {
        throw const FormatException('Invalid self assessment');
      }
    }
    return Map<String, dynamic>.from(decoded);
  }

  static Future<Map<String, dynamic>> read(String id) async {
    await flush();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exam_$id');
    if (raw == null) return {};
    try {
      return validate(raw, 'exam_$id');
    } catch (_) {
      return {};
    }
  }

  static Future<void> save(String id, Map<String, dynamic> data) {
    // Snapshot before queueing so subsequent UI edits cannot change this write.
    final encoded = jsonEncode(data);
    validate(encoded, 'exam_$id');
    return _enqueue(() async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString('exam_$id', encoded)) {
        throw StateError('Не удалось сохранить результат');
      }
    });
  }

  static Future<void> clear() => _enqueue(() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      if (!await prefs.remove(key)) {
        throw StateError('Не удалось очистить результаты экзаменов');
      }
    }
  });
}
