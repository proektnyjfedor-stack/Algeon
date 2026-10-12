import 'bookmark_service.dart';
import 'learning_service.dart';
import 'mock_exam_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'achievements_service.dart';
import 'progress_service.dart';
import 'study_session_service.dart';
import 'exam_progress.dart';

/// A versioned, local backup. Validate the entire file before writing anything.
class BackupService {
  static const maxBytes = 4 * 1024 * 1024;
  static const _strings = <String>{
    'last_active_date',
    'user_name',
    'user_avatar',
    'today_date',
    'equipped_beta_item',
    'profile_background',
    'custom_avatar',
    'custom_photo_b64',
    'theme_mode',
    'app_language',
  };
  static const _integers = <String>{
    'total_attempts',
    'correct_attempts',
    'streak_days',
    'current_grade',
    'today_completed',
    'accent_color',
  };
  static const _booleans = <String>{
    'onboarding_complete',
    'sound_enabled',
    'install_app_banner_dismissed',
  };
  static Set<String> get keys => {
    ..._strings,
    ...ExamProgress.keys,
    ...MockExamService.keys,
    LearningService.key,
    BookmarkService.key,
    ..._integers,
    ..._booleans,
    'solved_tasks',
    for (final type in AchievementType.values) 'achievement_${type.name}',
  };

  static Future<String> export() async {
    await ProgressService.flush();
    await BookmarkService.instance.flush();
    await LearningService.instance.flush();
    await MockExamService.flush();
    await ExamProgress.flush();
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final key in keys) {
      final value = prefs.get(key);
      if (value != null) data[key] = value;
    }
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'algeon-progress',
      'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    });
  }

  static Map<String, dynamic> validate(String contents) {
    if (utf8.encode(contents).length > maxBytes) {
      throw const FormatException('Backup is too large');
    }
    final decoded = jsonDecode(contents);
    if (decoded is! Map ||
        decoded['format'] != 'algeon-progress' ||
        decoded['version'] != 1 ||
        decoded['data'] is! Map) {
      throw const FormatException('Not a supported Algeon backup');
    }
    final data = <String, dynamic>{};
    for (final entry in (decoded['data'] as Map).entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || !keys.contains(key)) {
        throw const FormatException('Unknown backup field');
      }
      if (key == BookmarkService.key) {
        BookmarkService.validate(value);
      } else if (key == LearningService.key) {
        if (value is! String) {
          throw const FormatException('Invalid learning history');
        }
        LearningService.validate(value);
      } else if (MockExamService.keys.contains(key)) {
        if (value is! String) throw const FormatException('Invalid mock exam');
        MockExamService.validate(value, key.substring('mock_exam_'.length));
      } else if (ExamProgress.keys.contains(key)) {
        if (value is! String) throw const FormatException('Invalid exam data');
        ExamProgress.validate(value, key);
      } else if (_strings.contains(key)) {
        if (value is! String || value.length > maxBytes) {
          throw const FormatException('Invalid text');
        }
      } else if (_booleans.contains(key)) {
        if (value is! bool) throw const FormatException('Invalid setting');
      } else if (key == 'solved_tasks') {
        if (value is! List ||
            value.length > 100000 ||
            value.any((id) => id is! String || id.isEmpty || id.length > 200) ||
            value.toSet().length != value.length) {
          throw const FormatException('Invalid solved tasks');
        }
      } else {
        if (value is! int || value < 0 || value > 9007199254740991) {
          throw const FormatException('Invalid counter');
        }
      }
      data[key] = value;
    }
    if ((data['correct_attempts'] ?? 0) > (data['total_attempts'] ?? 0)) {
      throw const FormatException('Invalid accuracy');
    }
    final accent = data['accent_color'];
    if (accent != null && (accent < 0xFF000000 || accent > 0xFFFFFFFF)) {
      throw const FormatException('Invalid accent color');
    }
    final grade = data['current_grade'];
    if (grade != null && (grade < 1 || grade > 11)) {
      throw const FormatException('Invalid grade');
    }
    if (data['theme_mode'] != null &&
        !['light', 'dark', 'system'].contains(data['theme_mode'])) {
      throw const FormatException('Invalid theme');
    }
    if (data['app_language'] != null &&
        !['ru', 'en'].contains(data['app_language'])) {
      throw const FormatException('Invalid language');
    }
    for (final key in ['last_active_date', 'today_date']) {
      final raw = data[key];
      if (raw != null && !RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$').hasMatch(raw)) {
        throw const FormatException('Invalid date');
      }
    }
    final avatar = data['custom_avatar'];
    if (avatar != null && jsonDecode(avatar) is! Map<String, dynamic>) {
      throw const FormatException('Invalid avatar');
    }
    final photo = data['custom_photo_b64'];
    if (photo != null) base64Decode(photo);
    return data;
  }

  static Future<void> restore(String contents) async {
    final data = validate(contents);
    await LearningService.instance.flush();
    await BookmarkService.instance.flush();
    await MockExamService.flush();
    await ExamProgress.flush();
    await ProgressService.replacePreferences(data, keys);
    await LearningService.instance.init();
    await BookmarkService.instance.init();
    await StudySessionService.clear();
    await AchievementsService.init();
  }
}
