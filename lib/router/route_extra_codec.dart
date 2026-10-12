import 'dart:convert';
import '../models/task.dart';
import '../data/tasks_data.dart';
import '../services/achievements_service.dart';

/// Keep lesson and result data serializable in browser history.
class RouteExtraCodec extends Codec<Object?, Object?> {
  const RouteExtraCodec();
  @override
  Converter<Object?, Object?> get encoder => const _ExtraEncoder();
  @override
  Converter<Object?, Object?> get decoder => const _ExtraDecoder();
}

class _ExtraEncoder extends Converter<Object?, Object?> {
  const _ExtraEncoder();
  @override
  Object? convert(Object? value) {
    if (value is Task) return {'algeonType': 'task', 'id': value.id};
    if (value is Duration) {
      return {'algeonType': 'duration', 'milliseconds': value.inMilliseconds};
    }
    if (value is Achievement) {
      return {'algeonType': 'achievement', 'name': value.type.name};
    }
    if (value is List) return value.map(convert).toList();
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), convert(item)));
    }
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    throw const FormatException('Unsupported route data');
  }
}

class _ExtraDecoder extends Converter<Object?, Object?> {
  const _ExtraDecoder();
  @override
  Object? convert(Object? value) {
    if (value is List) return value.map(convert).toList();
    if (value is Map) {
      switch (value['algeonType']) {
        case 'task':
          return getTaskById(value['id'] as String);
        case 'duration':
          return Duration(milliseconds: value['milliseconds'] as int);
        case 'achievement':
          for (final item in AchievementsService.getAll()) {
            if (item.type.name == value['name']) return item;
          }
          return null;
      }
      return value.map((key, item) => MapEntry(key.toString(), convert(item)));
    }
    return value;
  }
}
