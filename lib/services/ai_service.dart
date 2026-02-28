/// AI Service — взаимодействие с OpenAI GPT API
///
/// Функции:
/// 1. Генерация новых задач
/// 2. Анализ ошибок ученика

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class AiService {
  // Запросы идут через Firebase Function — ключ не хранится в клиенте
  // Для локальной разработки: http://localhost:5001/mathpilot-app/us-central1/aiProxy
  // Для продакшна: https://us-central1-mathpilot-app.cloudfunctions.net/aiProxy
  static const String _proxyUrl =
      'https://us-central1-mathpilot-app.cloudfunctions.net/aiProxy';
  static const String _model = 'gpt-4o-mini';

  /// Запрос через Firebase Function прокси (API ключ на сервере)
  static Future<String> _chat(List<Map<String, String>> messages) async {
    try {
      final uri = Uri.parse(_proxyUrl);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] as String;
      } else {
        debugPrint('OpenAI error: ${response.statusCode} ${response.body}');
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error']?['message'] ?? 'Неизвестная ошибка';
        return 'Ошибка: $errorMsg';
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP ClientException: $e');
      return 'Ошибка сети. Проверьте подключение к интернету.';
    } catch (e) {
      debugPrint('AI Service error: $e');
      return 'Ошибка: $e';
    }
  }

  // ============================================================
  // 1. ГЕНЕРАЦИЯ ЗАДАЧ
  // ============================================================

  /// Генерирует новые задачи по теме
  static Future<List<Task>> generateTasks({
    required int grade,
    required String topic,
    int count = 5,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            'Ты — генератор математических задач для учеников начальной школы. '
                'Генерируй задачи строго по указанной теме и классу. '
                'Отвечай ТОЛЬКО валидным JSON массивом без markdown-обёрток. '
                'Каждая задача — объект с полями: '
                '"question" (строка), "answer" (строка с числом), '
                '"options" (массив из 4 строк, один из которых правильный ответ), '
                '"hint" (короткая подсказка, 1 предложение). '
                'Задачи должны быть разнообразными и соответствовать уровню $grade класса. '
                'Отвечай на русском.',
      },
      {
        'role': 'user',
        'content': 'Сгенерируй $count задач.\n'
            'Класс: $grade\n'
            'Тема: $topic',
      },
    ];

    final response = await _chat(messages);

    try {
      // Убираем возможные markdown-обёртки
      String cleaned = response.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      }

      final List<dynamic> parsed = jsonDecode(cleaned);
      return parsed.asMap().entries.map((entry) {
        final i = entry.key;
        final json = entry.value as Map<String, dynamic>;
        return Task(
          id: 'ai_${topic.hashCode}_${DateTime.now().millisecondsSinceEpoch}_$i',
          grade: grade,
          topic: topic,
          question: json['question'] as String,
          type: TaskType.multipleChoice,
          options:
              (json['options'] as List<dynamic>).map((e) => e.toString()).toList(),
          answer: json['answer'].toString(),
          hint: json['hint'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Parse error: $e\nResponse: $response');
      return [];
    }
  }

  // ============================================================
  // 2. ПОДСКАЗКА К ЗАДАЧЕ
  // ============================================================

  /// Генерирует краткую подсказку к конкретной задаче (не раскрывает ответ)
  static Future<String> generateHint({
    required String question,
    required int grade,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
            'Ты — помощник по математике для ученика $grade класса. '
                'Дай КРАТКУЮ подсказку (1-2 предложения) к задаче, '
                'НЕ называя и не раскрывая итоговый ответ. '
                'Подскажи только направление мысли или метод решения. '
                'Отвечай на русском, дружелюбно.',
      },
      {
        'role': 'user',
        'content': 'Дай подсказку к задаче:\n$question',
      },
    ];
    return _chat(messages);
  }

  // ============================================================
  // 3. АНАЛИЗ ОШИБОК
  // ============================================================

  /// Анализирует ошибки и даёт рекомендации
  static Future<String> analyzeErrors({
    required List<Task> wrongTasks,
    required int grade,
  }) async {
    if (wrongTasks.isEmpty) {
      return 'Ошибок нет — отличная работа!';
    }

    final tasksList = wrongTasks.map((t) {
      return '• Тема "${t.topic}": ${t.question} (ответ: ${t.answer})';
    }).join('\n');

    final messages = [
      {
        'role': 'system',
        'content':
            'Ты — опытный учитель математики начальных классов. '
                'Проанализируй ошибки ученика $grade класса и дай рекомендации. '
                'Структура ответа:\n'
                '1. Краткий анализ — какие типы ошибок допущены\n'
                '2. На что обратить внимание — конкретные советы\n'
                '3. Рекомендация — что повторить\n'
                'Пиши простым языком, дружелюбно, поддерживающе. '
                'Ответ не более 200 слов. Отвечай на русском.',
      },
      {
        'role': 'user',
        'content': 'Ученик $grade класса допустил ошибки в следующих задачах:\n'
            '$tasksList\n\n'
            'Проанализируй ошибки и дай рекомендации.',
      },
    ];

    return _chat(messages);
  }
}
