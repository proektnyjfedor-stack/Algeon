import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tasks_data.dart';
import '../data/exam_catalog.dart';
import '../data/exam_theory.dart';
import '../models/task.dart';

/// Observed learning history. Never infers past mistakes from solved counters.
class LearningService extends ChangeNotifier {
  LearningService._();
  static final instance = LearningService._();
  static const key = 'learning_history_v1';
  SharedPreferences? _prefs;
  Map<String, dynamic> _data = empty();
  Future<void> _queue = Future.value();
  int _pendingWrites = 0;
  DateTime Function() clock = DateTime.now;
  static Map<String, dynamic> empty() => {
    'version': 1,
    'stats': <String, dynamic>{},
    'mistakes': <String, dynamic>{},
    'seen': <String>[],
    'plan': <String, dynamic>{},
    'diagnostic': <String, dynamic>{},
  };
  Map<String, dynamic> get stats =>
      Map<String, dynamic>.from(_data['stats'] as Map);
  Map<String, dynamic> get mistakes =>
      Map<String, dynamic>.from(_data['mistakes'] as Map);
  Map<String, dynamic> get plan =>
      Map<String, dynamic>.from(_data['plan'] as Map);
  Map<String, dynamic> get diagnostic =>
      Map<String, dynamic>.from(_data['diagnostic'] as Map);
  String get today => day(clock());
  static String day(DateTime time) =>
      '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  static Map<String, dynamic> validate(String raw) {
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic> || data['version'] != 1) {
      throw const FormatException('Invalid learning history');
    }
    for (final field in ['stats', 'mistakes', 'plan', 'diagnostic']) {
      if (data[field] is! Map) {
        throw const FormatException('Invalid learning section');
      }
    }
    if (data['seen'] is! List ||
        (data['seen'] as List).length > 5000 ||
        (data['seen'] as List).any((id) => id is! String)) {
      throw const FormatException('Invalid attempt ids');
    }
    if ((data['stats'] as Map).length > 5000 ||
        (data['mistakes'] as Map).length > 5000) {
      throw const FormatException('Too many records');
    }
    for (final entry in (data['stats'] as Map).entries) {
      final r = entry.value;
      if (entry.key is! String ||
          r is! Map ||
          r['attempts'] is! int ||
          r['correct'] is! int ||
          r['attempts'] <= 0 ||
          r['correct'] < 0 ||
          r['correct'] > r['attempts'] ||
          r['topic'] is! String ||
          !validRef(r['ref']) ||
          r['lastDay'] is! String ||
          r['recent'] is! List ||
          (r['recent'] as List).length > 10 ||
          (r['recent'] as List).any((v) => v is! bool)) {
        throw const FormatException('Invalid topic statistics');
      }
    }
    for (final entry in (data['mistakes'] as Map).entries) {
      final r = entry.value;
      if (entry.key is! String ||
          r is! Map ||
          r['stage'] is! int ||
          r['stage'] < 0 ||
          r['stage'] > 4 ||
          r['topic'] is! String ||
          !validRef(r['ref']) ||
          r['input'] is! String ||
          (r['input'] as String).length > 1500 ||
          r['due'] is! String ||
          DateTime.tryParse(r['due']) == null) {
        throw const FormatException('Invalid review record');
      }
    }
    final plan = data['plan'] as Map;
    if (plan.isNotEmpty &&
        (!['school', 'oge', 'base', 'profile'].contains(plan['track']) ||
            plan['daily'] is! int ||
            plan['daily'] < 3 ||
            plan['daily'] > 30 ||
            plan['target'] is! String ||
            DateTime.tryParse(plan['target']) == null ||
            plan['goal'] is! String ||
            (plan['goal'] as String).length > 100)) {
      throw const FormatException('Invalid learning plan');
    }
    final diagnostic = data['diagnostic'] as Map;
    if (diagnostic.isNotEmpty &&
        (diagnostic['ids'] is! List ||
            (diagnostic['ids'] as List).length > 12 ||
            (diagnostic['ids'] as List).any(
              (id) => id is! String || getTaskById(id) == null,
            ) ||
            diagnostic['answers'] is! Map ||
            (diagnostic['answers'] as Map).values.any(
              (r) =>
                  r is! Map || r['correct'] is! bool || r['input'] is! String,
            ))) {
      throw const FormatException('Invalid diagnostic');
    }
    if (plan.isNotEmpty &&
        (plan['grade'] is! int || plan['grade'] < 1 || plan['grade'] > 11)) {
      throw const FormatException('Invalid grade');
    }
    if (diagnostic.isNotEmpty &&
        (diagnostic['startedAt'] is! String ||
            DateTime.tryParse(diagnostic['startedAt']) == null ||
            diagnostic['grade'] is! int ||
            diagnostic['grade'] < 1 ||
            diagnostic['grade'] > 11 ||
            (diagnostic['ids'] as List).isEmpty ||
            (diagnostic['ids'] as List).toSet().length !=
                (diagnostic['ids'] as List).length ||
            (diagnostic['answers'] as Map).entries.any(
              (e) =>
                  !(diagnostic['ids'] as List).contains(e.key) ||
                  (e.value['input'] as String).length > 10000,
            ))) {
      throw const FormatException('Invalid diagnostic session');
    }
    final daily = data['dailyPlan'];
    if (daily != null &&
        (daily is! Map ||
            daily['day'] is! String ||
            daily['items'] is! List ||
            (daily['items'] as List).length > 30 ||
            (daily['items'] as List).any((r) => !validRef(r)))) {
      throw const FormatException('Invalid daily plan');
    }
    return data;
  }

  static bool validRef(dynamic r) {
    if (r is! Map || r['id'] is! String) return false;
    if (r['kind'] == 'school') {
      return getTaskById(r['id']) != null &&
          r['grade'] is int &&
          r['grade'] >= 1 &&
          r['grade'] <= 11;
    }
    return r['kind'] == 'exam' &&
        ['oge', 'base', 'profile'].contains(r['track']) &&
        r['slot'] is int &&
        r['slot'] >= 1 &&
        r['slot'] <=
            (r['track'] == 'oge'
                ? 25
                : r['track'] == 'base'
                ? 21
                : 20) &&
        r['variant'] is String &&
        RegExp(r'^(oge|base|profile)-(10|[1-9])$').hasMatch(r['variant']);
  }

  Future<void> init() async {
    if (_pendingWrites > 0) await _queue;
    _prefs = await SharedPreferences.getInstance();
    try {
      _data = validate(_prefs!.getString(key) ?? jsonEncode(empty()));
    } catch (_) {
      _data = empty();
    }
    notifyListeners();
  }

  Future<void> _mutate(void Function() action) {
    if (_pendingWrites == 0) _queue = Future.value();
    _pendingWrites++;
    final result = _queue.then((_) async {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
        try {
          _data = validate(_prefs!.getString(key) ?? jsonEncode(empty()));
        } catch (_) {
          _data = empty();
        }
      }
      final previous = jsonEncode(_data);
      try {
        action();
        validate(jsonEncode(_data));
        if (!await _prefs!.setString(key, jsonEncode(_data))) {
          throw StateError('History could not be saved');
        }
      } catch (_) {
        _data = validate(previous);
        rethrow;
      }
      notifyListeners();
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

  Future<void> flush() => _pendingWrites == 0 ? Future.value() : _queue;
  Future<void> clear() => _mutate(() => _data = empty());
  static Map<String, dynamic> taskRef(Task task) => {
    'kind': 'school',
    'id': task.id,
    'grade': task.grade,
  };
  static Map<String, dynamic> examRef(Map<String, dynamic> q, String variant) =>
      {
        'kind': 'exam',
        'id': q['id'],
        'track': q['track'],
        'slot': q['slot'],
        'variant': variant,
      };
  Future<void> record({
    required String attemptId,
    required String id,
    required String topic,
    required Map<String, dynamic> ref,
    required bool correct,
    required String input,
  }) => _mutate(() {
    final seen = (_data['seen'] as List).cast<String>();
    if (seen.contains(attemptId)) return;
    seen.add(attemptId);
    if (seen.length > 5000) seen.removeRange(0, seen.length - 5000);
    final stats = _data['stats'] as Map;
    final previous = stats[id] as Map? ?? {};
    final recent = <bool>[
      ...?((previous['recent'] as List?)?.cast<bool>()),
      correct,
    ];
    if (recent.length > 10) recent.removeAt(0);
    stats[id] = {
      'topic': topic,
      'ref': ref,
      'attempts': (previous['attempts'] as int? ?? 0) + 1,
      'correct': (previous['correct'] as int? ?? 0) + (correct ? 1 : 0),
      'lastDay': today,
      'recent': recent,
    };
    final mistakes = _data['mistakes'] as Map;
    if (!correct) {
      mistakes[id] = {
        'topic': topic,
        'ref': ref,
        'stage': 0,
        'due': clock().toIso8601String(),
        'input': input.substring(0, input.length.clamp(0, 1500)),
      };
    } else if (mistakes[id] is Map) {
      final mistake = Map<String, dynamic>.from(mistakes[id] as Map);
      if (mistake['stage'] == 0 ||
          !clock().isBefore(DateTime.parse(mistake['due'] as String))) {
        final stage = ((mistake['stage'] as int) + 1).clamp(0, 4);
        mistake['stage'] = stage;
        mistake['due'] = clock()
            .add(Duration(days: [0, 1, 3, 7, 14][stage]))
            .toIso8601String();
        mistakes[id] = mistake;
      }
    }
  });
  List<MapEntry<String, dynamic>> reviews({bool dueOnly = false}) =>
      mistakes.entries
          .where(
            (e) =>
                e.value['stage'] < 4 &&
                (!dueOnly ||
                    !clock().isBefore(
                      DateTime.parse(e.value['due'] as String),
                    )),
          )
          .toList()
        ..sort(
          (a, b) =>
              (a.value['due'] as String).compareTo(b.value['due'] as String),
        );
  List<Map<String, dynamic>> topicStats() {
    final groups = <String, Map<String, dynamic>>{};
    for (final r in stats.values) {
      final topic = r['topic'] as String;
      final g = groups.putIfAbsent(
        topic,
        () => {'topic': topic, 'attempts': 0, 'correct': 0, 'recent': <bool>[]},
      );
      g['attempts'] += r['attempts'];
      g['correct'] += r['correct'];
      (g['recent'] as List).addAll((r['recent'] as List).cast<bool>());
    }
    return groups.values.toList()..sort(
      (a, b) => ((a['correct'] as int) / (a['attempts'] as int)).compareTo(
        (b['correct'] as int) / (b['attempts'] as int),
      ),
    );
  }

  bool completedToday(Map ref) =>
      stats[ref['kind'] == 'exam'
          ? 'exam:${ref['id']}'
          : ref['id']]?['lastDay'] ==
      today;

  Future<void> configurePlan(Map<String, dynamic> plan) => _mutate(() {
    _data['plan'] = plan;
    _data.remove('dailyPlan');
  });
  Future<List<Map<String, dynamic>>> dailyTasks(ExamCatalog catalog) async {
    final cached = _data['dailyPlan'];
    if (cached is Map && cached['day'] == today) {
      return (cached['items'] as List).cast<Map<String, dynamic>>();
    }
    if (plan.isEmpty) return [];
    final candidates = <Map<String, dynamic>>[];
    final track = plan['track'];
    for (final review in reviews(dueOnly: true)) {
      final ref = Map<String, dynamic>.from(review.value['ref'] as Map);
      if (track == 'school'
          ? ref['kind'] == 'school' &&
                getTaskById(ref['id'] as String)?.grade == plan['grade']
          : ref['track'] == track) {
        candidates.add(ref);
      }
    }
    if (track == 'school') {
      final grade = plan['grade'] as int? ?? 5;
      final tasks = getTasksByGrade(grade).toList()
        ..sort((a, b) {
          final sa = stats[a.id];
          final sb = stats[b.id];
          if (sa?['lastDay'] == today && sb?['lastDay'] != today) {
            return 1;
          }
          if (sb?['lastDay'] == today && sa?['lastDay'] != today) {
            return -1;
          }
          if (sa == null && sb != null && sb['correct'] == sb['attempts']) {
            return -1;
          }
          if (sb == null && sa != null && sa['correct'] == sa['attempts']) {
            return 1;
          }
          final pa = sa == null ? 0.5 : sa['correct'] / sa['attempts'];
          final pb = sb == null ? 0.5 : sb['correct'] / sb['attempts'];
          final priority = pa.compareTo(pb);
          return priority != 0
              ? priority
              : (sa?['lastDay'] as String? ?? '').compareTo(
                  sb?['lastDay'] as String? ?? '',
                );
        });
      candidates.addAll(
        balanced(
          tasks.map(taskRef).toList(),
          (r) => getTaskById(r['id'] as String)!.topic,
        ),
      );
    } else {
      final qs =
          catalog.questions.values
              .cast<Map<String, dynamic>>()
              .where((q) => q['track'] == track)
              .toList()
            ..sort((a, b) {
              final sa = stats['exam:${a['id']}'];
              final sb = stats['exam:${b['id']}'];
              final priority =
                  (sa == null ? .5 : sa['correct'] / sa['attempts']).compareTo(
                    sb == null ? .5 : sb['correct'] / sb['attempts'],
                  );
              return priority != 0
                  ? priority
                  : (sa?['lastDay'] as String? ?? '').compareTo(
                      sb?['lastDay'] as String? ?? '',
                    );
            });
      for (final q in balanced(qs, (q) => '${q['slot']}')) {
        final v = catalog.variants.firstWhere(
          (v) => (v['questionIds'] as List).contains(q['id']),
        );
        candidates.add(examRef(q, v['id'] as String));
      }
    }
    final unique = <String>{};
    final available = candidates
        .where((r) => unique.add('${r['kind']}:${r['id']}'))
        .toList();
    // Reconfiguring the plan should not consume the new daily target with
    // attempts already counted today, including mistakes awaiting review.
    // Keep their order and retain them only as a fallback for a small pool.
    final items = [
      ...available.where((ref) => !completedToday(ref)),
      ...available.where(completedToday),
    ].take(plan['daily'] as int).toList();
    await _mutate(() => _data['dailyPlan'] = {'day': today, 'items': items});
    return items;
  }

  static List<Map<String, dynamic>> balanced(
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) group,
  ) {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      groups.putIfAbsent(group(item), () => []).add(item);
    }
    final result = <Map<String, dynamic>>[];
    while (groups.values.any((g) => g.isNotEmpty)) {
      for (final g in groups.values) {
        if (g.isNotEmpty) result.add(g.removeAt(0));
      }
    }
    return result;
  }

  static List<Task> diagnosticTasks(int grade) {
    // Check prerequisites and current material; never test an unstudied future class.
    final grades = grade > 1 ? [grade - 1, grade] : [grade];
    final result = <Task>[];
    for (final g in grades) {
      final tasks = getTasksByGrade(g);
      final groups = <String, List<Task>>{};
      for (final task in tasks) {
        groups.putIfAbsent(task.topic, () => []).add(task);
      }
      final limit = g == grade ? (grade == 1 ? 9 : 6) : 3;
      final spread = <Task>[];
      // Spread selection over the topic list instead of testing only its first entries.
      final topics = groups.values.toList();
      for (var i = 0; i < topics.length; i++) {
        final index = (i * topics.length / limit).floor() % topics.length;
        final group = topics[index];
        if (!spread.any((t) => t.topic == group.first.topic)) {
          spread.add(group[group.length ~/ 2]);
        }
      }
      spread.addAll(tasks.where((t) => !spread.any((s) => s.id == t.id)));
      result.addAll(spread.take(limit));
    }
    final ids = result.map((t) => t.id).toSet();
    result.addAll(
      getTasksByGrade(
        grade,
      ).where((t) => ids.add(t.id)).take(9 - result.length),
    );
    return result;
  }

  Future<void> saveDiagnostic(Map<String, dynamic> value) =>
      _mutate(() => _data['diagnostic'] = value);
  static String taskTopic(Task task) => '${task.grade} класс · ${task.topic}';
  static String examTopic(Map<String, dynamic> q) =>
      '${examLabels[q['track']]} · №${q['slot']} · ${examGuide(q['track'] as String, q['slot'] as int).title}';
  static List<Task> similar(Task task, {int count = 3}) => getAllTasks()
      .where(
        (t) =>
            t.id != task.id && t.grade == task.grade && t.topic == task.topic,
      )
      .take(count)
      .toList();
}
