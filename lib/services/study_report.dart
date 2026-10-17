import 'learning_service.dart';

String buildStudyReport(LearningService history) {
  final topics = history.topicStats();
  final attempts = topics.fold<int>(0, (n, t) => n + (t['attempts'] as int));
  final correct = topics.fold<int>(0, (n, t) => n + (t['correct'] as int));
  final report = StringBuffer(
    '# Algeon — результаты подготовки\n\nДата: ${history.today}\n\n',
  );
  if (attempts == 0) {
    report.writeln(
      'Пока нет сохранённых попыток. Начните с диагностики или короткой тренировки.',
    );
    return report.toString();
  }
  report.writeln(
    'Попыток: $attempts. Верных ответов: $correct. Точность: ${(correct / attempts * 100).round()}%.\n',
  );
  report.writeln('## Темы\n');
  for (final topic in topics) {
    report.writeln(
      '- ${topic['topic']}: ${history.topicStatus(topic)}. ${topic['correct']} из ${topic['attempts']} верно; разных заданий: ${topic['tasks']}.',
    );
  }
  final difficult = topics.where((t) => t['attempts'] > t['correct']).toList()
    ..sort(
      (a, b) => ((b['attempts'] as int) - (b['correct'] as int)).compareTo(
        (a['attempts'] as int) - (a['correct'] as int),
      ),
    );
  report.writeln('\n## Что повторить\n');
  if (difficult.isEmpty) {
    report.writeln(
      'Ошибок в сохранённых попытках нет. Продолжайте решать разные задания.',
    );
  } else {
    for (final topic in difficult.take(5)) {
      report.writeln(
        '- ${topic['topic']}: ${topic['attempts'] - topic['correct']} неверных попыток. Повторите правило и решите похожее задание.',
      );
    }
  }
  report.writeln(
    '\nЗаданий в журнале повторения: ${history.reviews().length}.',
  );
  report.writeln(
    '\nСтатус «Освоено»: не менее 5 разных заданий, точность от 80% и нет незавершённых повторений. Это ориентир по сохранённым попыткам, а не экзаменационная оценка. Для развёрнутых экзаменационных заданий учитывается самооценка.',
  );
  return report.toString();
}
