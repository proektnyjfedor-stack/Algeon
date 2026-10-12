import 'dart:convert';
import 'package:flutter/services.dart';

const examLabels = {
  'oge': 'ОГЭ',
  'base': 'ЕГЭ · база',
  'profile': 'ЕГЭ · профиль',
};

class ExamCatalog {
  ExamCatalog(this.variants, this.questions);
  final List<Map<String, dynamic>> variants;
  final Map<String, dynamic> questions;
  static Future<ExamCatalog>? _pending;
  static ExamCatalog? _loaded;
  static Future<ExamCatalog> load() =>
      _loaded != null ? Future.value(_loaded) : _pending ??= _read();
  static Future<ExamCatalog> _read() async {
    try {
      final data =
          jsonDecode(await rootBundle.loadString('assets/exams/catalog.json'))
              as Map<String, dynamic>;
      return _loaded = ExamCatalog(
        (data['variants'] as List).cast<Map<String, dynamic>>(),
        data['questions'] as Map<String, dynamic>,
      );
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }
}
