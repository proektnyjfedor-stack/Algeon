/// Структурированная теория для каждой темы
///
/// Секции: определение, правило/формула, разбор примера, шаги.
library;

import 'package:flutter/material.dart';
import 'tasks_data.dart';
import 'topic_curriculum.dart';
import 'topic_curriculum_en.dart';
import 'topic_titles_en.dart';

part 'topic_theory_deep_dives.dart';
part 'topic_theory_deep_dives_en.dart';

enum TheorySectionType {
  definition,
  formula,
  example,
  visual,
  tip,
  table,
  steps,
}

class TheorySection {
  const TheorySection({
    required this.type,
    this.title,
    required this.content,
    this.emoji,
    this.items,
    this.accentColor,
  });
  final TheorySectionType type;
  final String? title;
  final String content;
  final String? emoji;
  final List<String>? items;
  final Color? accentColor;
}

class TopicTheory {
  const TopicTheory({
    required this.topicName,
    required this.subtitle,
    required this.sections,
  });
  final String topicName;
  final String subtitle;
  final List<TheorySection> sections;
}

TopicTheory? getTopicTheory(String topicName, {bool english = false}) {
  final ruCurriculum = kTopicCurriculumTexts[topicName];
  final enCurriculum = kTopicCurriculumTextsEn[topicName];
  final curriculumText = (english ? enCurriculum : ruCurriculum) ?? '';
  if (curriculumText.trim().isNotEmpty) {
    final displayName = english ? topicTitleEn(topicName) : topicName;
    final generated = _buildGeneratedTheory(
      displayName,
      curriculumText,
      english: english,
    );
    final extras = english
        ? [
            ..._topicDeepDiveSectionsEnglish(topicName),
            ..._officialProgramSections(topicName, english: true),
          ]
        : [
            ..._topicDeepDiveSections(topicName),
            ..._officialProgramSections(topicName, english: false),
          ];
    return TopicTheory(
      topicName: displayName,
      subtitle: generated.subtitle,
      sections: _mergeAfterFirstDefinition(generated.sections, extras),
    );
  }

  if (!english) {
    final predefined = _theoryMap[topicName];
    if (predefined != null) {
      return TopicTheory(
        topicName: predefined.topicName,
        subtitle: predefined.subtitle,
        sections: _sanitizeSections(predefined.sections),
      );
    }
    final description = getTopicDescription(topicName);
    final resolved = (description == null || description.trim().isEmpty)
        ? _buildDefaultDescription(topicName, english: false)
        : description;
    final generated =
        _buildGeneratedTheory(topicName, resolved, english: false);
    return TopicTheory(
      topicName: generated.topicName,
      subtitle: generated.subtitle,
      sections: _mergeAfterFirstDefinition(
        generated.sections,
        [
          ..._topicDeepDiveSections(topicName),
          ..._officialProgramSections(topicName, english: false),
        ],
      ),
    );
  }

  final predefined = _theoryMap[topicName];
  if (predefined != null) {
    return TopicTheory(
      topicName: topicTitleEn(topicName),
      subtitle: predefined.subtitle,
      sections: _sanitizeSections(predefined.sections),
    );
  }
  final description = getTopicDescription(topicName);
  final resolved = (description == null || description.trim().isEmpty)
      ? _buildDefaultDescription(topicName, english: true)
      : description;
  final generated = _buildGeneratedTheory(
    topicTitleEn(topicName),
    resolved,
    english: true,
  );
  return TopicTheory(
    topicName: topicTitleEn(topicName),
    subtitle: generated.subtitle,
    sections: _mergeAfterFirstDefinition(
      generated.sections,
      [
        ..._topicDeepDiveSectionsEnglish(topicName),
        ..._officialProgramSections(topicName, english: true),
      ],
    ),
  );
}

/// Убираем «Совет» / шаблонные «как решать…»; советы-заметки переводим в обычные блоки теории.
List<TheorySection> _sanitizeSections(List<TheorySection> sections) {
  final out = <TheorySection>[];
  for (final s in sections) {
    if (s.type == TheorySectionType.steps) {
      final t = (s.title ?? '').toLowerCase();
      if (t.contains('как решать задания по теме')) continue;
      if (s.content.contains('Универсальный алгоритм')) continue;
    }
    if (s.type == TheorySectionType.tip) {
      final rawTitle = (s.title ?? '').trim();
      if (rawTitle.toLowerCase() == 'совет') continue;
      final tl = rawTitle.toLowerCase();
      final TheorySectionType newType;
      var newTitle = rawTitle;
      if (tl == 'обрати внимание') {
        newTitle = 'Уточнение';
        newType = TheorySectionType.definition;
      } else if (tl.contains('признак') ||
          tl.contains('правил') ||
          tl.contains('свойств')) {
        newType = TheorySectionType.formula;
      } else {
        newType = TheorySectionType.definition;
      }
      out.add(TheorySection(
        type: newType,
        title: newTitle,
        content: s.content,
        emoji: s.emoji,
        items: s.items,
        accentColor: s.accentColor,
      ));
      continue;
    }
    out.add(s);
  }
  return out;
}

List<TheorySection> _mergeAfterFirstDefinition(
  List<TheorySection> base,
  List<TheorySection> extras,
) {
  if (extras.isEmpty) return _sanitizeSections(base);
  final head = _sanitizeSections(base);
  final i = head.indexWhere((s) => s.type == TheorySectionType.definition);
  if (i < 0) return [...extras, ...head];
  return [...head.take(i + 1), ...extras, ...head.skip(i + 1)];
}

String _stripInlineAdvice(String text, {bool english = false}) {
  final lines = text.split('\n');
  final kept = <String>[];
  final adviceRe = english
      ? RegExp(r'^(tip|hint|life\s*hack|advice)\s*:', caseSensitive: false)
      : RegExp(r'^(совет|подсказка|лайфхак)\s*:', caseSensitive: false);
  for (final line in lines) {
    final t = line.trim();
    if (adviceRe.hasMatch(t)) {
      continue;
    }
    kept.add(line);
  }
  return kept.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

String _buildDefaultDescription(String topicName, {required bool english}) {
  if (english) {
    return 'The topic “$topicName” matters for core skills and exam-style problems.\n\n'
        'Before solving exercises, learn the key definitions, formulas, and standard methods.\n'
        'Review the main ideas first, then move on to practice.';
  }
  return _fallbackTopicDescription(topicName);
}

String _fallbackTopicDescription(String topicName) {
  final exact = _fallbackTopicDescriptionsRu[topicName];
  if (exact != null) return exact;

  final lower = topicName.toLowerCase();
  if (lower.contains('уравнен')) {
    return 'Уравнение — это равенство с неизвестным числом. Цель решения: найти такое значение буквы, при котором левая и правая части станут равны.\n\n'
        'Главный принцип — равносильные преобразования: к обеим частям можно прибавлять или вычитать одно и то же выражение, умножать или делить обе части на одно и то же ненулевое число.\n\n'
        'После решения обязательно делается проверка: найденное значение подставляют в исходное уравнение.\n\n'
        '• Неизвестное лучше оставить в одной части, числа — в другой.\n'
        '• При переносе слагаемого через знак равенства меняется знак.\n'
        '• Ответ без проверки легко может оказаться лишним или ошибочным.\n';
  }
  if (lower.contains('неравен')) {
    return 'Неравенство сравнивает выражения с помощью знаков >, <, ≥, ≤. Решение неравенства — это не одно число, а множество чисел, при которых сравнение верно.\n\n'
        'С неравенствами работают почти как с уравнениями, но есть важное правило: при умножении или делении обеих частей на отрицательное число знак неравенства меняется на противоположный.\n\n'
        'Ответ часто записывают промежутком или показывают на числовой прямой.\n\n'
        '• Строгие знаки > и < не включают граничную точку.\n'
        '• Знаки ≥ и ≤ включают граничную точку.\n'
        '• В системах неравенств берут пересечение условий.\n';
  }
  if (lower.contains('дроб')) {
    return 'Дробь показывает часть целого. Знаменатель говорит, на сколько равных частей разделили целое, числитель — сколько таких частей взяли.\n\n'
        'При сложении и вычитании дроби приводят к общему знаменателю. При умножении перемножают числители и знаменатели. При делении умножают на обратную дробь.\n\n'
        'Дробь можно сокращать, если числитель и знаменатель имеют общий делитель.\n\n'
        '• Сначала определяй, что принято за целое.\n'
        '• Сокращение не меняет значение дроби.\n'
        '• Ответ часто удобно упростить до несократимой дроби.\n';
  }
  if (lower.contains('координ')) {
    return 'Координаты помогают точно описывать положение точки. На прямой у точки одна координата, на плоскости — две: (x, y).\n\n'
        'Первая координата x показывает движение вправо или влево от вертикальной оси. Вторая координата y показывает движение вверх или вниз от горизонтальной оси.\n\n'
        'Знаки координат определяют квадрант: I (+,+), II (-,+), III (-,-), IV (+,-).\n\n'
        '• Точка (0, 0) — начало координат.\n'
        '• Если x = 0, точка лежит на оси OY.\n'
        '• Если y = 0, точка лежит на оси OX.\n';
  }
  if (lower.contains('геометр') ||
      lower.contains('угл') ||
      lower.contains('фигур')) {
    return 'Геометрическая тема требует не угадывать формулу, а сначала понять объект: точка, прямая, угол, треугольник, окружность или тело.\n\n'
        'Решение строится от известных свойств: сумма углов, равенство сторон, параллельность, перпендикулярность, площадь, объём или признаки равенства/подобия.\n\n'
        'Полезно делать короткий чертёж и подписывать данные прямо на нём.\n\n'
        '• Сначала выпиши, что дано и что нужно найти.\n'
        '• Следи за единицами: длина, площадь и объём измеряются по-разному.\n'
        '• Не используй формулу, если её условия не выполнены.\n';
  }
  return 'Тема "$topicName" нужна, чтобы уверенно решать учебные и практические задачи.\n\n'
      'Сначала разберись в смысле основных слов темы: что дано, что нужно найти и какая связь между величинами используется.\n\n'
      'Затем выбери правило или формулу, запиши решение по шагам и проверь ответ обратным действием, подстановкой или примерной оценкой.\n\n'
      '• Не начинай с ответа: сначала найди правило.\n'
      '• Каждое действие должно отвечать на вопрос «что я сейчас нашёл?».\n'
      '• Если задача короткая, всё равно проговори смысл условия.\n';
}

const Map<String, String> _fallbackTopicDescriptionsRu = {
  'НОД и НОК': 'НОД — наибольший общий делитель. Это самое большое число, на которое оба данных числа делятся без остатка.\n\n'
      'НОК — наименьшее общее кратное. Это самое маленькое положительное число, которое делится на оба данных числа.\n\n'
      'Есть два удобных способа. Первый — выписать делители или кратные и выбрать нужное число. Второй — разложить числа на простые множители.\n\n'
      'Для НОД берут общие простые множители в меньших степенях. Для НОК берут все простые множители в больших степенях.\n\n'
      '• НОД(12, 18): делители 12 — 1, 2, 3, 4, 6, 12; делители 18 — 1, 2, 3, 6, 9, 18. Самый большой общий — 6.\n'
      '• НОК(4, 6): кратные 4 — 4, 8, 12; кратные 6 — 6, 12. Первое общее — 12.\n'
      '• Связь: НОД(a, b) × НОК(a, b) = a × b для натуральных a и b.\n',
  'Признаки делимости':
      'Признаки делимости помогают понять, делится ли число на 2, 3, 5, 9 или 10 без полного деления.\n\n'
          'На 2 делятся числа, которые оканчиваются на чётную цифру. На 5 — числа, оканчивающиеся на 0 или 5. На 10 — числа, оканчивающиеся на 0.\n\n'
          'На 3 делятся числа, у которых сумма цифр делится на 3. На 9 — числа, у которых сумма цифр делится на 9.\n\n'
          '• 246 делится на 2, потому что оканчивается на 6.\n'
          '• 123 делится на 3, потому что 1 + 2 + 3 = 6, а 6 делится на 3.\n'
          '• 145 делится на 5, потому что оканчивается на 5.\n',
  'Десятичные дроби':
      'Десятичная дробь — это удобная запись частей единицы через десятые, сотые, тысячные и так далее.\n\n'
          'Цифры после запятой имеют разряды: десятые, сотые, тысячные. Поэтому 0,4 = 4/10, а 0,04 = 4/100.\n\n'
          'При сложении и вычитании десятичные дроби записывают запятую под запятой. При умножении сначала умножают как натуральные числа, затем ставят запятую по числу знаков после запятой.\n\n'
          '• 1,2 + 0,35 = 1,55.\n'
          '• 0,5 = 1/2.\n'
          '• При сравнении можно дописать нули: 0,4 = 0,40.\n',
  'Состав числа':
      'Состав числа показывает, из каких частей можно получить одно число. Например, 7 можно составить как 3 + 4, 5 + 2 или 6 + 1.\n\n'
          'Эта тема нужна для быстрого сложения и вычитания: если знаешь состав 10, легче считать с переходом через десяток.\n\n'
          '• Чтобы найти пропущенную часть, вычти известную часть из целого.\n'
          '• 8 = 5 + 3, значит неизвестная часть в 8 = 5 + ? равна 3.\n',
  'Таблица умножения':
      'Таблица умножения — это быстрый способ считать одинаковые группы. Запись 7 × 8 означает 7 групп по 8 или 8 групп по 7.\n\n'
          'Умножение можно проверить делением, а сложные строки таблицы удобно связывать с уже знакомыми: 8 × 7 = 7 × 8.\n\n'
          '• Порядок множителей можно менять.\n'
          '• Если забыл факт, разложи один множитель: 7 × 8 = 7 × (5 + 3).\n',
};

TopicTheory _buildGeneratedTheory(
  String topicName,
  String description, {
  required bool english,
}) {
  final clean = _stripInlineAdvice(description, english: english).trim();
  final lines = clean
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  final bulletLines = lines
      .where((e) => e.startsWith('•') || e.startsWith('-'))
      .map((e) => e.replaceFirst(RegExp(r'^[•\-]\s*'), ''))
      .toList(growable: false);

  final proseLines = lines
      .where((e) => !(e.startsWith('•') || e.startsWith('-')))
      .toList(growable: false);

  final prose = proseLines.join('\n\n').trim();
  final subtitle = proseLines.isNotEmpty
      ? proseLines.first
      : (english ? 'Theory for “$topicName”' : 'Теория по теме «$topicName»');
  final exampleItems =
      _extractExampleItems(proseLines, bulletLines, english: english);

  final defTitle = english ? 'What this topic is about' : 'Смысл темы';
  final stepsTitle =
      english ? 'Key facts and rules' : 'Факты и правила по порядку';
  final stepsIntro = english
      ? 'Each bullet is a separate fact. Read top to bottom to connect ideas with formulas.'
      : 'Ниже каждый пункт — отдельное утверждение. Прочитай сверху вниз: так проще связать определения с формулами.';
  final exTitle = english ? 'Worked examples' : 'Примеры по теме';
  final exIntro = english
      ? 'Walk each item step by step: what is given, which rule you use, what result you get.'
      : 'Разбери каждый пример по шагам: что дано, какое правило применяем, какой получаем результат.';

  final sections = <TheorySection>[
    TheorySection(
      type: TheorySectionType.definition,
      title: defTitle,
      content: prose.isNotEmpty ? prose : clean,
    ),
  ];

  if (bulletLines.isNotEmpty) {
    sections.add(
      TheorySection(
        type: TheorySectionType.steps,
        title: stepsTitle,
        content: stepsIntro,
        items: List<String>.generate(
          bulletLines.length,
          (i) => '${i + 1}. ${bulletLines[i]}',
        ),
      ),
    );
  }

  if (exampleItems.isNotEmpty) {
    sections.add(
      TheorySection(
        type: TheorySectionType.example,
        title: exTitle,
        content: exIntro,
        items: exampleItems,
      ),
    );
  }

  return TopicTheory(
    topicName: topicName,
    subtitle: subtitle,
    sections: sections,
  );
}

List<String> _extractExampleItems(
  List<String> proseLines,
  List<String> bulletLines, {
  required bool english,
}) {
  final picked = <String>[];
  final seen = <String>{};

  void addItem(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return;
    if (cleaned.length < 6) return;
    if (seen.contains(cleaned)) return;
    seen.add(cleaned);
    picked.add(cleaned);
  }

  final exampleLeadRe = english
      ? RegExp(
          r'^(for example|e\.g\.|example)\s*[:\-]?\s*',
          caseSensitive: false,
        )
      : RegExp(r'^(например|пример)\s*[:\-]?\s*', caseSensitive: false);
  final formulaLikeRe = RegExp(r'[\dxyab]\s*[\+\-\×x*/÷=<>≤≥]\s*[\dxyab]');

  for (final line in proseLines) {
    var normalized = line.trim();
    if (exampleLeadRe.hasMatch(normalized)) {
      normalized = normalized.replaceFirst(exampleLeadRe, '').trim();
      addItem(normalized);
      continue;
    }
    if (normalized.contains('→') || formulaLikeRe.hasMatch(normalized)) {
      addItem(normalized);
    }
  }

  for (final b in bulletLines) {
    final line = b.trim();
    if (line.contains('→') || formulaLikeRe.hasMatch(line)) {
      addItem(line);
    }
  }

  if (picked.isEmpty && proseLines.isNotEmpty) {
    final first = proseLines.first;
    addItem(english ? 'Worked example: $first' : 'Пример применения: $first');
  }

  return picked.take(5).toList(growable: false);
}

// ============================================================
// ДАННЫЕ ТЕОРИИ
// ============================================================

final Map<String, TopicTheory> _theoryMap = {
  // ==================== 1 КЛАСС ====================

  'Счёт до 10': const TopicTheory(
    topicName: 'Счёт до 10',
    subtitle: 'Основы сложения в пределах 10',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Сложение',
        content:
            'Сложение — арифметическое действие, при котором два числа (слагаемые) объединяются в одно число (сумму).\n\nЗнак сложения: +\nЗапись: слагаемое + слагаемое = сумма',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Переместительное свойство',
        content:
            'a + b = b + a\n\nОт перестановки слагаемых сумма не меняется.\n\n2 + 3 = 3 + 2 = 5',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Числовая прямая',
        content:
            ' 0 — 1 — 2 — 3 — 4 — 5 — 6 — 7 — 8 — 9 — 10\n\nЧтобы сложить 4 + 3, встань на число 4\nи сделай 3 шага вправо:\n4 → 5 → 6 → 7\n\nОтвет: 4 + 3 = 7',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примеров',
        content: '',
        items: [
          '2 + 5 = 7    (два плюс пять равно семь)',
          '4 + 4 = 8    (четыре плюс четыре равно восемь)',
          '3 + 7 = 10  (три плюс семь равно десять)',
          '6 + 1 = 7    (шесть плюс один равно семь)',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content:
            'При сложении с нулём число не меняется:\n5 + 0 = 5\n0 + 8 = 8',
      ),
    ],
  ),

  'Счёт до 20': const TopicTheory(
    topicName: 'Счёт до 20',
    subtitle: 'Сложение с переходом через десяток',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Переход через десяток',
        content:
            'Если сумма двух чисел больше 10, применяется приём «дополнение до 10»: первое число дополняется до 10, затем прибавляется остаток.',
      ),
      TheorySection(
        type: TheorySectionType.steps,
        title: 'Алгоритм сложения',
        content: 'Пример: 8 + 5',
        items: [
          'Определи, сколько нужно до 10: 10 − 8 = 2',
          'Разбей второе слагаемое: 5 = 2 + 3',
          'Дополни до 10: 8 + 2 = 10',
          'Прибавь остаток: 10 + 3 = 13',
        ],
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Общая схема',
        content:
            'a + b, если a + b > 10:\n\n1) d = 10 − a\n2) b = d + (b − d)\n3) a + b = 10 + (b − d)',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры',
        content: '',
        items: [
          '7 + 5:  7 + 3 + 2 = 10 + 2 = 12',
          '9 + 4:  9 + 1 + 3 = 10 + 3 = 13',
          '6 + 7:  6 + 4 + 3 = 10 + 3 = 13',
          '8 + 8:  8 + 2 + 6 = 10 + 6 = 16',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content:
            'Начинай сложение с большего числа — так легче дополнять до 10.\n\nВместо 3 + 9 считай 9 + 3 (до десяти не хватает всего 1).',
      ),
    ],
  ),

  'Вычитание до 10': const TopicTheory(
    topicName: 'Вычитание до 10',
    subtitle: 'Основы вычитания',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Вычитание',
        content:
            'Вычитание — действие, обратное сложению. Из уменьшаемого вычитается вычитаемое, получается разность.\n\nЗнак вычитания: −\nЗапись: уменьшаемое − вычитаемое = разность',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Связь сложения и вычитания',
        content:
            'Если a + b = c, то:\nc − a = b\nc − b = a\n\nПример:\n3 + 4 = 7  →  7 − 3 = 4  →  7 − 4 = 3',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры',
        content: '',
        items: [
          '9 − 4 = 5    (от девяти отнять четыре)',
          '10 − 7 = 3  (от десяти отнять семь)',
          '8 − 8 = 0    (число минус само себя равно нулю)',
          '6 − 0 = 6    (минус ноль — число не меняется)',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Проверка вычитания',
        content:
            'Чтобы проверить вычитание, сложи разность и вычитаемое — должно получиться уменьшаемое.\n\n9 − 4 = 5\nПроверка: 5 + 4 = 9  ✓',
      ),
    ],
  ),

  'Сравнение чисел': const TopicTheory(
    topicName: 'Сравнение чисел',
    subtitle: 'Знаки сравнения: >, <, =',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Знаки сравнения',
        content:
            'Для сравнения двух чисел используют три знака:\n\n>  — больше (левое число больше правого)\n<  — меньше (левое число меньше правого)\n=  — равно (числа одинаковые)',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Правило «открытой стороны»',
        content:
            'Знак всегда «раскрывается» в сторону большего числа:\n\n  5 > 3   — раскрыт к пятёрке\n  2 < 7   — раскрыт к семёрке\n  4 = 4   — числа равны',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры',
        content: '',
        items: [
          '8 > 6    (восемь больше шести)',
          '3 < 9    (три меньше девяти)',
          '10 > 1  (десять больше одного)',
          '7 = 7    (семь равно семи)',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Как запомнить',
        content:
            'Представь знак как рот — он всегда хочет «съесть» большее число и открывается в его сторону.',
      ),
    ],
  ),

  'Фигуры': const TopicTheory(
    topicName: 'Фигуры',
    subtitle: 'Основные геометрические фигуры',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Геометрические фигуры',
        content:
            'Геометрическая фигура — замкнутая линия на плоскости. Основные характеристики фигуры: количество сторон, углов и их свойства.',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Основные фигуры',
        content: '',
        items: [
          'Круг — нет сторон, нет углов. Все точки на одинаковом расстоянии от центра.',
          'Треугольник — 3 стороны, 3 угла.',
          'Квадрат — 4 равные стороны, 4 прямых угла (по 90°).',
          'Прямоугольник — 4 стороны, противоположные стороны равны, 4 прямых угла.',
        ],
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Где встречаются',
        content:
            'Круг — монета, тарелка, колесо\nТреугольник — дорожный знак, крыша дома\nКвадрат — кафельная плитка, кубик\nПрямоугольник — дверь, экран телефона, книга',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content:
            'Квадрат — это частный случай прямоугольника, у которого все четыре стороны равны.',
      ),
    ],
  ),

  'Задачи на сложение': const TopicTheory(
    topicName: 'Задачи на сложение',
    subtitle: 'Решение текстовых задач',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Текстовая задача',
        content:
            'Текстовая задача содержит условие (известные данные) и вопрос (что нужно найти). Чтобы решить задачу, нужно определить действие и выполнить вычисление.',
      ),
      TheorySection(
        type: TheorySectionType.steps,
        title: 'Порядок решения',
        content: '',
        items: [
          'Прочитай задачу. Определи, что известно и что нужно найти.',
          'Выбери действие. Ключевые слова: «всего», «стало», «вместе» указывают на сложение.',
          'Запиши решение в виде числового выражения.',
          'Вычисли и запиши ответ с наименованием (штук, кг, см и т.д.).',
        ],
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор задачи',
        content:
            'Условие: В корзине 3 яблока и 4 груши. Сколько фруктов в корзине?\n\nИзвестно: 3 яблока, 4 груши\nНайти: сколько всего фруктов\nДействие: сложение (слово «всего»)\nРешение: 3 + 4 = 7\nОтвет: 7 фруктов.',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Ключевые слова для сложения',
        content: '',
        items: [
          '«всего» — складываем все части',
          '«вместе» — объединяем в одно',
          '«стало» — было мало, добавили',
          '«получилось» — результат объединения',
        ],
      ),
    ],
  ),

  // ==================== 2 КЛАСС ====================

  'Умножение на 2': const TopicTheory(
    topicName: 'Умножение на 2',
    subtitle: 'Понятие умножения, таблица на 2',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое умножение',
        content:
            'Умножение — это сложение одинаковых слагаемых.\n\na × b означает: число a сложить b раз.\n\nЗнак умножения: ×\nЗапись: множитель × множитель = произведение',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Умножение на 2',
        content:
            'a × 2 = a + a\n\nУмножить на 2 — значит удвоить число.\n\nПример: 6 × 2 = 6 + 6 = 12',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Таблица умножения на 2',
        content: '',
        items: [
          '1 × 2 = 2        6 × 2 = 12',
          '2 × 2 = 4        7 × 2 = 14',
          '3 × 2 = 6        8 × 2 = 16',
          '4 × 2 = 8        9 × 2 = 18',
          '5 × 2 = 10      10 × 2 = 20',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Свойство',
        content:
            'Произведение любого числа на 2 всегда чётное (оканчивается на 0, 2, 4, 6, 8).',
      ),
    ],
  ),

  'Умножение на 3': const TopicTheory(
    topicName: 'Умножение на 3',
    subtitle: 'Таблица умножения на 3',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Умножение на 3',
        content:
            'a × 3 = a + a + a\n\nУмножить число на 3 — значит сложить его три раза.\n\nПример: 4 × 3 = 4 + 4 + 4 = 12',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Таблица умножения на 3',
        content: '',
        items: [
          '1 × 3 = 3        6 × 3 = 18',
          '2 × 3 = 6        7 × 3 = 21',
          '3 × 3 = 9        8 × 3 = 24',
          '4 × 3 = 12      9 × 3 = 27',
          '5 × 3 = 15      10 × 3 = 30',
        ],
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Связь с умножением на 2',
        content:
            'a × 3 = a × 2 + a\n\nЕсли знаешь таблицу на 2, прибавь число ещё раз:\n7 × 3 = 7 × 2 + 7 = 14 + 7 = 21',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Признак делимости на 3',
        content:
            'Если сумма цифр числа делится на 3, то и само число делится на 3.\n\n21: 2 + 1 = 3 (делится) ✓\n25: 2 + 5 = 7 (не делится) ✗',
      ),
    ],
  ),

  'Умножение на 4 и 5': const TopicTheory(
    topicName: 'Умножение на 4 и 5',
    subtitle: 'Приёмы быстрого умножения',
    sections: [
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Умножение на 4',
        content:
            'a × 4 = (a × 2) × 2\n\nУмножить на 4 — значит дважды удвоить.\n\nПример: 7 × 4\n7 × 2 = 14\n14 × 2 = 28\nОтвет: 28',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Умножение на 5',
        content:
            'a × 5 = a × 10 ÷ 2\n\nУмножить на 5 — умножь на 10 и раздели пополам.\n\nПример: 7 × 5\n7 × 10 = 70\n70 ÷ 2 = 35\nОтвет: 35',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Таблица умножения на 4 и 5',
        content: '',
        items: [
          '1 × 4 = 4        1 × 5 = 5',
          '2 × 4 = 8        2 × 5 = 10',
          '3 × 4 = 12      3 × 5 = 15',
          '4 × 4 = 16      4 × 5 = 20',
          '5 × 4 = 20      5 × 5 = 25',
          '6 × 4 = 24      6 × 5 = 30',
          '7 × 4 = 28      7 × 5 = 35',
          '8 × 4 = 32      8 × 5 = 40',
          '9 × 4 = 36      9 × 5 = 45',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Свойство',
        content:
            'Произведение любого числа на 5 всегда оканчивается на 0 или 5.',
      ),
    ],
  ),

  'Деление': const TopicTheory(
    topicName: 'Деление',
    subtitle: 'Действие, обратное умножению',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое деление',
        content:
            'Деление — разбиение числа на равные части.\n\nЗнак деления: ÷\nЗапись: делимое ÷ делитель = частное\n\nПример: 12 ÷ 3 = 4 (двенадцать разделить на три равно четырём)',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Связь умножения и деления',
        content:
            'Если a × b = c, то:\nc ÷ a = b\nc ÷ b = a\n\nПример:\n4 × 3 = 12\n12 ÷ 3 = 4\n12 ÷ 4 = 3',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content:
            'Задача: 15 ÷ 5 = ?\n\nДумаем: на какое число нужно умножить 5, чтобы получить 15?\n5 × 3 = 15\n\nЗначит 15 ÷ 5 = 3.',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Правила деления',
        content:
            'На ноль делить нельзя.\nПри делении на 1 число не меняется: a ÷ 1 = a.\nЧисло, делённое на себя, равно 1: a ÷ a = 1.',
      ),
    ],
  ),

  'Текстовые задачи': const TopicTheory(
    topicName: 'Текстовые задачи',
    subtitle: 'Выбор действия по условию задачи',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Как определить действие',
        content:
            'В тексте задачи есть ключевые слова, которые подсказывают нужное арифметическое действие.',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Ключевые слова',
        content: '',
        items: [
          '«всего», «вместе», «стало»  →  сложение (+)',
          '«осталось», «на сколько больше/меньше»  →  вычитание (−)',
          '«по ... штук в каждом», «в n раз больше»  →  умножение (×)',
          '«поровну», «во сколько раз», «на каждого»  →  деление (÷)',
        ],
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор задачи',
        content:
            'Условие: В 4 коробках по 6 карандашей. Сколько карандашей всего?\n\nИзвестно: 4 коробки, по 6 карандашей\nКлючевые слова: «по 6 в каждой» → умножение\nРешение: 4 × 6 = 24\nОтвет: 24 карандаша.',
      ),
      TheorySection(
        type: TheorySectionType.steps,
        title: 'План решения',
        content: '',
        items: [
          'Прочитай задачу. Выдели известные данные.',
          'Определи, что нужно найти.',
          'Выбери действие по ключевым словам.',
          'Запиши решение и вычисли.',
          'Проверь: ответ соответствует вопросу?',
        ],
      ),
    ],
  ),

  'Время': const TopicTheory(
    topicName: 'Время',
    subtitle: 'Единицы измерения времени',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Единицы времени',
        content:
            'Время измеряется в различных единицах. Основные единицы: секунды, минуты, часы, сутки.',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Соотношения единиц',
        content: '',
        items: [
          '1 минута = 60 секунд',
          '1 час = 60 минут',
          '1 сутки = 24 часа',
          'Полчаса = 30 минут',
          'Четверть часа = 15 минут',
        ],
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Циферблат часов',
        content:
            'Короткая (часовая) стрелка — показывает часы.\nДлинная (минутная) стрелка — показывает минуты.\n\nМинутная стрелка делает полный круг за 1 час.\nЧасовая стрелка делает полный круг за 12 часов.',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры',
        content: '',
        items: [
          '2 часа 30 минут = 150 минут  (2 × 60 + 30)',
          '90 минут = 1 час 30 минут  (90 ÷ 60 = 1 ост. 30)',
          '3 часа = 180 минут  (3 × 60)',
        ],
      ),
    ],
  ),

  // ==================== 3 КЛАСС ====================

  'Умножение на 6-9': const TopicTheory(
    topicName: 'Умножение на 6-9',
    subtitle: 'Полная таблица умножения',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Переместительное свойство',
        content:
            'Если ты знаешь таблицу умножения до 5, то бóльшую часть таблицы 6–9 ты уже знаешь.\n\n6 × 4 = 4 × 6 = 24\n7 × 3 = 3 × 7 = 21\n\nОсталось выучить лишь случаи, где оба множителя ≥ 6.',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Случаи для запоминания',
        content: 'Именно эти произведения чаще всего вызывают затруднения:',
        items: [
          '6 × 6 = 36      7 × 7 = 49',
          '6 × 7 = 42      7 × 8 = 56',
          '6 × 8 = 48      7 × 9 = 63',
          '6 × 9 = 54      8 × 8 = 64',
          '8 × 9 = 72      9 × 9 = 81',
        ],
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Приём для умножения на 9',
        content:
            'a × 9 = a × 10 − a\n\nПример: 7 × 9 = 70 − 7 = 63\n\nДополнительный признак: сумма цифр произведения на 9 всегда равна 9.\n63: 6 + 3 = 9 ✓',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Приём для умножения на 6',
        content:
            'a × 6 = a × 5 + a\n\n8 × 6 = 8 × 5 + 8 = 40 + 8 = 48\n7 × 6 = 7 × 5 + 7 = 35 + 7 = 42',
      ),
    ],
  ),

  'Деление с остатком': const TopicTheory(
    topicName: 'Деление с остатком',
    subtitle: 'Когда число не делится нацело',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Деление с остатком',
        content:
            'Если число не делится нацело, получается неполное частное и остаток.\n\nОстаток — та часть делимого, которая «не вместилась» в целое число групп.',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Формула',
        content:
            'a = b × q + r\n\nгде:\na — делимое\nb — делитель\nq — неполное частное\nr — остаток\n\nВажно: остаток всегда меньше делителя (r < b)',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content:
            '17 ÷ 5 = ?\n\nПодбираем: 5 × 3 = 15 (ближайшее к 17, не превышая его)\nОстаток: 17 − 15 = 2\n\nОтвет: 17 ÷ 5 = 3 (остаток 2)\nПроверка: 5 × 3 + 2 = 17 ✓',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Ещё примеры',
        content: '',
        items: [
          '23 ÷ 4 = 5 (ост. 3)    проверка: 4 × 5 + 3 = 23',
          '19 ÷ 6 = 3 (ост. 1)    проверка: 6 × 3 + 1 = 19',
          '30 ÷ 7 = 4 (ост. 2)    проверка: 7 × 4 + 2 = 30',
        ],
      ),
    ],
  ),

  'Периметр': const TopicTheory(
    topicName: 'Периметр',
    subtitle: 'Сумма длин всех сторон фигуры',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Определение',
        content:
            'Периметр (P) — это сумма длин всех сторон многоугольника. Измеряется в единицах длины (мм, см, дм, м).',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Формулы периметра',
        content:
            'Прямоугольник:\nP = (a + b) × 2\nгде a — длина, b — ширина\n\nКвадрат:\nP = a × 4\nгде a — сторона квадрата\n\nТреугольник:\nP = a + b + c\nгде a, b, c — стороны',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content:
            'Найти периметр прямоугольника со сторонами 5 см и 3 см.\n\nP = (a + b) × 2\nP = (5 + 3) × 2\nP = 8 × 2\nP = 16 см\n\nОтвет: 16 см.',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Ещё примеры',
        content: '',
        items: [
          'Квадрат со стороной 4 см:  P = 4 × 4 = 16 см',
          'Прямоугольник 7 см и 2 см:  P = (7 + 2) × 2 = 18 см',
          'Треугольник 3, 4, 5 см:  P = 3 + 4 + 5 = 12 см',
        ],
      ),
    ],
  ),

  'Площадь': const TopicTheory(
    topicName: 'Площадь',
    subtitle: 'Измерение поверхности фигур',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Определение',
        content:
            'Площадь (S) — это величина, которая показывает, сколько места занимает фигура на плоскости. Измеряется в квадратных единицах (мм², см², дм², м²).',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Формулы площади',
        content:
            'Прямоугольник:\nS = a × b\nгде a — длина, b — ширина\n\nКвадрат:\nS = a × a = a²\nгде a — сторона квадрата',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content:
            'Найти площадь прямоугольника со сторонами 6 см и 4 см.\n\nS = a × b\nS = 6 × 4\nS = 24 см²\n\nОтвет: 24 см².',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Периметр и площадь — разные величины',
        content:
            'Периметр — длина границы (в см).\nПлощадь — размер поверхности (в см²).\n\nПрямоугольник 6 × 4 см:\nP = (6 + 4) × 2 = 20 см\nS = 6 × 4 = 24 см²',
      ),
    ],
  ),

  'Единицы длины': const TopicTheory(
    topicName: 'Единицы длины',
    subtitle: 'Перевод единиц измерения длины',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Единицы длины',
        content:
            'Длину измеряют в миллиметрах (мм), сантиметрах (см), дециметрах (дм), метрах (м) и километрах (км).',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Соотношения единиц',
        content: '',
        items: [
          '1 км = 1 000 м',
          '1 м = 10 дм = 100 см = 1 000 мм',
          '1 дм = 10 см = 100 мм',
          '1 см = 10 мм',
        ],
      ),
      TheorySection(
        type: TheorySectionType.steps,
        title: 'Правило перевода',
        content: '',
        items: [
          'Из крупных в мелкие — умножай.',
          'Из мелких в крупные — дели.',
          'Пример: 3 м в см → 3 × 100 = 300 см',
          'Пример: 450 см в м → 450 ÷ 100 = 4 м 50 см',
        ],
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры перевода',
        content: '',
        items: [
          '3 м 25 см = 325 см    (3 × 100 + 25)',
          '540 см = 5 м 40 см    (540 ÷ 100 = 5 ост. 40)',
          '2 км 300 м = 2 300 м  (2 × 1000 + 300)',
        ],
      ),
    ],
  ),

  'Единицы массы': const TopicTheory(
    topicName: 'Единицы массы',
    subtitle: 'Граммы, килограммы, центнеры, тонны',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Единицы массы',
        content:
            'Массу измеряют в граммах (г), килограммах (кг), центнерах (ц) и тоннах (т).',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Соотношения единиц',
        content: '',
        items: [
          '1 т = 1 000 кг',
          '1 ц = 100 кг',
          '1 кг = 1 000 г',
          '1 т = 10 ц',
        ],
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Для ориентира',
        content:
            '1 г — скрепка для бумаги\n100 г — яблоко\n1 кг — пачка сахара\n1 ц (100 кг) — взрослый человек\n1 т (1000 кг) — легковой автомобиль',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры перевода',
        content: '',
        items: [
          '3 кг 200 г = 3 200 г    (3 × 1000 + 200)',
          '5 400 г = 5 кг 400 г    (5400 ÷ 1000 = 5 ост. 400)',
          '2 т 500 кг = 2 500 кг  (2 × 1000 + 500)',
        ],
      ),
    ],
  ),

  // ==================== 4 КЛАСС ====================

  'Многозначные числа': const TopicTheory(
    topicName: 'Многозначные числа',
    subtitle: 'Разряды и арифметика больших чисел',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Разряды чисел',
        content:
            'Каждая цифра в числе занимает определённый разряд, который определяет её значение.\n\nРазряды (справа налево): единицы, десятки, сотни, тысячи, десятки тысяч и т.д.',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Разрядный состав числа 4 528',
        content:
            'Разряд:    тыс.    сот.    дес.    ед.\nЦифра:        4         5         2        8\n\n4 528 = 4 000 + 500 + 20 + 8\n\n4 — тысячи  (4 × 1000)\n5 — сотни     (5 × 100)\n2 — десятки  (2 × 10)\n8 — единицы (8 × 1)',
      ),
      TheorySection(
        type: TheorySectionType.steps,
        title: 'Сложение в столбик',
        content: 'Пример: 3 456 + 2 378',
        items: [
          'Запиши числа столбиком (разряд под разрядом).',
          'Единицы: 6 + 8 = 14 → пишем 4, переносим 1.',
          'Десятки: 5 + 7 + 1 = 13 → пишем 3, переносим 1.',
          'Сотни: 4 + 3 + 1 = 8.',
          'Тысячи: 3 + 2 = 5.',
          'Ответ: 5 834.',
        ],
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content:
            'Всегда выравнивай числа по разрядам. Складывай (или вычитай) строго справа налево, не забывая про перенос.',
      ),
    ],
  ),

  'Дроби': const TopicTheory(
    topicName: 'Дроби',
    subtitle: 'Понятие дроби, сравнение дробей',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое дробь',
        content:
            'Дробь обозначает часть целого. Записывается в виде a/b.\n\nЧислитель (a) — сколько частей взяли.\nЗнаменатель (b) — на сколько равных частей разделили целое.',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Пример: дробь 3/4',
        content:
            'Целое разделено на 4 равные части.\nВзято 3 из них.\n\n[■][■][■][  ]\n\n3  ←  числитель (взяли 3 части)\n─\n4  ←  знаменатель (всего 4 части)',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Сравнение дробей',
        content:
            'Одинаковый знаменатель:\nСравниваем числители.\n3/5 > 2/5  (три пятых больше двух пятых)\n\nОдинаковый числитель:\nБольше та дробь, у которой знаменатель меньше.\n1/3 > 1/4  (треть больше четвертинки)\n\nПравило: чем больше знаменатель, тем мельче части.',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Примеры',
        content: '',
        items: [
          '5/8 > 3/8  (одинаковый знаменатель, 5 > 3)',
          '1/2 > 1/5  (одинаковый числитель, 2 < 5)',
          '4/4 = 1      (если числитель равен знаменателю — это целое)',
          '0/7 = 0      (если числитель 0 — дробь равна нулю)',
        ],
      ),
    ],
  ),

  'Уравнения': const TopicTheory(
    topicName: 'Уравнения',
    subtitle: 'Нахождение неизвестного компонента',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое уравнение',
        content:
            'Уравнение — это равенство, содержащее неизвестное число (обычно обозначается буквой x). Решить уравнение — значит найти такое значение x, при котором равенство верно.',
      ),
      TheorySection(
        type: TheorySectionType.table,
        title: 'Правила нахождения x',
        content: 'Чтобы найти x, выполни обратное действие:',
        items: [
          'x + a = b   →   x = b − a    (неизвестное слагаемое)',
          'x − a = b   →   x = b + a    (неизвестное уменьшаемое)',
          'a − x = b   →   x = a − b    (неизвестное вычитаемое)',
          'x × a = b   →   x = b ÷ a    (неизвестный множитель)',
          'x ÷ a = b   →   x = b × a    (неизвестное делимое)',
        ],
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content:
            'Уравнение: x + 5 = 12\n\nНеизвестное слагаемое = сумма − известное слагаемое\nx = 12 − 5\nx = 7\n\nПроверка: 7 + 5 = 12 ✓',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Ещё пример',
        content:
            'Уравнение: x × 4 = 20\n\nНеизвестный множитель = произведение ÷ известный множитель\nx = 20 ÷ 4\nx = 5\n\nПроверка: 5 × 4 = 20 ✓',
      ),
    ],
  ),

  'Скорость, время, расстояние': const TopicTheory(
    topicName: 'Скорость, время, расстояние',
    subtitle: 'Задачи на движение',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Три величины',
        content:
            'Скорость (V) — расстояние, пройденное за единицу времени (км/ч, м/с).\nВремя (t) — продолжительность движения (ч, мин, с).\nРасстояние (S) — длина пройденного пути (км, м).',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Основные формулы',
        content:
            'S = V × t    — расстояние\nV = S ÷ t    — скорость\nt = S ÷ V    — время\n\nВсе три формулы следуют из одной:\nS = V × t',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Треугольник S–V–t',
        content:
            '          S\n       ┌──┴──┐\n       V  ×  t\n\nЗакрой искомую величину:\n• Ищешь S  →  V × t\n• Ищешь V  →  S ÷ t\n• Ищешь t  →  S ÷ V',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор задач',
        content:
            'Задача 1. Велосипедист ехал 3 ч со скоростью 15 км/ч. Найти расстояние.\nS = V × t = 15 × 3 = 45 км\n\nЗадача 2. Поезд проехал 240 км за 4 ч. Найти скорость.\nV = S ÷ t = 240 ÷ 4 = 60 км/ч\n\nЗадача 3. Пешеход идёт со скоростью 5 км/ч. Путь — 20 км. Найти время.\nt = S ÷ V = 20 ÷ 5 = 4 ч',
      ),
    ],
  ),

  'Порядок действий': const TopicTheory(
    topicName: 'Порядок действий',
    subtitle: 'Правила выполнения арифметических действий',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Порядок действий',
        content:
            'При вычислении выражений с несколькими действиями необходимо соблюдать строгий порядок. Нарушение порядка приводит к неверному результату.',
      ),
      TheorySection(
        type: TheorySectionType.steps,
        title: 'Правила',
        content: '',
        items: [
          'Сначала выполняй действия в скобках.',
          'Затем — умножение и деление (слева направо).',
          'В последнюю очередь — сложение и вычитание (слева направо).',
        ],
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content:
            'Вычислить: 2 + 3 × 4\n\n1) Умножение: 3 × 4 = 12\n2) Сложение: 2 + 12 = 14\n\nОтвет: 14\n\nОшибка: если сначала сложить 2 + 3 = 5, затем 5 × 4 = 20 — это неверно!',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Пример со скобками',
        content:
            'Вычислить: (8 + 2) × 3 − 4 ÷ 2\n\n1) Скобки: 8 + 2 = 10\n2) Умножение: 10 × 3 = 30\n3) Деление: 4 ÷ 2 = 2\n4) Вычитание: 30 − 2 = 28\n\nОтвет: 28',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content:
            'Скобки всегда имеют наивысший приоритет — они указывают, какое действие выполнить первым, независимо от типа операции внутри.',
      ),
    ],
  ),
};
