library;

/// Light-touch helpers for short Russian snippets that appear inside mixed UI.
///
/// Full topic theory and curriculum use dedicated English sources
/// ([kTopicCurriculumTextsEn], [topicTitleEn]) — this class does **not** transliterate.
class LocalizedTextService {
  static final RegExp _cyr = RegExp(r'[А-Яа-яЁё]');

  static bool hasCyrillic(String text) => _cyr.hasMatch(text);

  /// Replaces a few common instruction prefixes when the interface is English.
  /// If Cyrillic remains, returns the original text unchanged (no transliteration).
  static String forEnglishUi(String text) {
    if (text.trim().isEmpty) return text;
    var out = text;

    const phraseMap = <String, String>{
      'Решите уравнение': 'Solve the equation',
      'Реши уравнение': 'Solve the equation',
      'Решите неравенство': 'Solve the inequality',
      'Вычислите': 'Calculate',
      'Найдите': 'Find',
      'Найди': 'Find',
      'Упростите': 'Simplify',
      'Сократите дробь': 'Reduce the fraction',
      'Разложите на множители': 'Factorize',
      'Выразите': 'Express',
      'Подсказка': 'Hint',
      'Разберём вместе': 'Let’s solve it together',
      'чисел': 'of the numbers',
      'числа': 'of the number',
      'Наибольший общий делитель': 'Greatest common divisor',
      'Наименьшее общее кратное': 'Least common multiple',
      'Правильный ответ': 'Correct answer',
      'Теоретической вероятности': 'Theoretical probability',
      'Нулю': 'Zero',
      'Единице': 'One',
      'Дисперсии': 'Variance',
      'Да': 'Yes',
      'Нет': 'No',
    };

    phraseMap.forEach((ru, en) {
      out = out.replaceAll(ru, en);
    });

    return out;
  }
}
