import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tasks_data.dart';

class BookmarkService extends ChangeNotifier {
  BookmarkService._();
  static final instance = BookmarkService._();
  static const key = 'study_bookmarks_v1';
  Set<String> _items = {};
  bool _loaded = false;
  bool busy = false;
  Future<void>? _pending;
  Set<String> get items => Set.unmodifiable(_items);
  bool contains(String id) => _items.contains(id);
  static void validate(dynamic value) {
    if (value is! List ||
        value.length > 10000 ||
        value.any((v) => v is! String || !validId(v)) ||
        value.toSet().length != value.length) {
      throw const FormatException('Invalid bookmarks');
    }
  }

  static bool validId(String id) {
    if (id.startsWith('task:')) return getTaskById(id.substring(5)) != null;
    final topic = RegExp(r'^topic:(\d+):(.+)$').firstMatch(id);
    if (topic != null) {
      return getTasksByGradeAndTopic(
        int.parse(topic[1]!),
        topic[2]!,
      ).isNotEmpty;
    }
    final parts = id.split(':');
    if (parts.length == 3 && parts[0] == 'exam') {
      final m = RegExp(r'^(oge|base|profile)-(10|[1-9])$').firstMatch(parts[1]);
      final slot = int.tryParse(parts[2]);
      return m != null &&
          slot != null &&
          slot >= 1 &&
          slot <=
              (m[1] == 'oge'
                  ? 25
                  : m[1] == 'base'
                  ? 21
                  : 20);
    }
    return false;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.get(key);
    _items = raw is List
        ? raw.whereType<String>().where(validId).take(10000).toSet()
        : {};
    _loaded = true;
    notifyListeners();
  }

  Future<void> ensureLoaded() async {
    if (!_loaded) await init();
  }

  Future<void> toggle(String id) async {
    if (!validId(id)) throw const FormatException('Invalid bookmark');
    if (busy) return;
    await ensureLoaded();
    if (busy) return;
    final previous = Set<String>.from(_items);
    busy = true;
    if (!_items.remove(id)) _items.add(id);
    notifyListeners();
    try {
      final operation = _save();
      _pending = operation;
      await operation;
    } catch (_) {
      _items = previous;
      rethrow;
    } finally {
      busy = false;
      _pending = null;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setStringList(key, _items.toList())) {
      throw StateError('Bookmarks could not be saved');
    }
  }

  Future<void> flush() async {
    if (busy && _pending != null) await _pending;
  }
}
