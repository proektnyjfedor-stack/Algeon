import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExamProgress {
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
    }
    return Map<String, dynamic>.from(decoded);
  }

  static Future<Map<String, dynamic>> read(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('exam_$id');
    if (raw == null) return {};
    try {
      return validate(raw, 'exam_$id');
    } catch (_) {
      return {};
    }
  }

  static Future<void> save(String id, Map<String, dynamic> data) async {
    // Capture before the first await so navigation cannot change this snapshot.
    final encoded = jsonEncode(data);
    validate(encoded, 'exam_$id');
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('exam_$id', encoded)) {
      throw StateError('Не удалось сохранить результат');
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
