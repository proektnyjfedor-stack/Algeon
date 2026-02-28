/// Структурированная теория для каждой темы
///
/// Секции: определение, правило/формула, разбор примера,
/// важное замечание.

import 'package:flutter/material.dart';

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
  final TheorySectionType type;
  final String? title;
  final String content;
  final String? emoji;
  final List<String>? items;
  final Color? accentColor;

  const TheorySection({
    required this.type,
    this.title,
    required this.content,
    this.emoji,
    this.items,
    this.accentColor,
  });
}

class TopicTheory {
  final String topicName;
  final String subtitle;
  final List<TheorySection> sections;

  const TopicTheory({
    required this.topicName,
    required this.subtitle,
    required this.sections,
  });
}

TopicTheory? getTopicTheory(String topicName) => _theoryMap[topicName];

// ============================================================
// ДАННЫЕ ТЕОРИИ
// ============================================================

final Map<String, TopicTheory> _theoryMap = {

  // ==================== 1 КЛАСС ====================

  'Счёт до 10': TopicTheory(
    topicName: 'Счёт до 10',
    subtitle: 'Основы сложения в пределах 10',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Сложение',
        content: 'Сложение — арифметическое действие, при котором два числа (слагаемые) объединяются в одно число (сумму).\n\nЗнак сложения: +\nЗапись: слагаемое + слагаемое = сумма',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Переместительное свойство',
        content: 'a + b = b + a\n\nОт перестановки слагаемых сумма не меняется.\n\n2 + 3 = 3 + 2 = 5',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Числовая прямая',
        content: ' 0 — 1 — 2 — 3 — 4 — 5 — 6 — 7 — 8 — 9 — 10\n\nЧтобы сложить 4 + 3, встань на число 4\nи сделай 3 шага вправо:\n4 → 5 → 6 → 7\n\nОтвет: 4 + 3 = 7',
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
        content: 'При сложении с нулём число не меняется:\n5 + 0 = 5\n0 + 8 = 8',
      ),
    ],
  ),

  'Счёт до 20': TopicTheory(
    topicName: 'Счёт до 20',
    subtitle: 'Сложение с переходом через десяток',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Переход через десяток',
        content: 'Если сумма двух чисел больше 10, применяется приём «дополнение до 10»: первое число дополняется до 10, затем прибавляется остаток.',
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
        content: 'a + b, если a + b > 10:\n\n1) d = 10 − a\n2) b = d + (b − d)\n3) a + b = 10 + (b − d)',
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
        content: 'Начинай сложение с большего числа — так легче дополнять до 10.\n\nВместо 3 + 9 считай 9 + 3 (до десяти не хватает всего 1).',
      ),
    ],
  ),

  'Вычитание до 10': TopicTheory(
    topicName: 'Вычитание до 10',
    subtitle: 'Основы вычитания',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Вычитание',
        content: 'Вычитание — действие, обратное сложению. Из уменьшаемого вычитается вычитаемое, получается разность.\n\nЗнак вычитания: −\nЗапись: уменьшаемое − вычитаемое = разность',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Связь сложения и вычитания',
        content: 'Если a + b = c, то:\nc − a = b\nc − b = a\n\nПример:\n3 + 4 = 7  →  7 − 3 = 4  →  7 − 4 = 3',
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
        content: 'Чтобы проверить вычитание, сложи разность и вычитаемое — должно получиться уменьшаемое.\n\n9 − 4 = 5\nПроверка: 5 + 4 = 9  ✓',
      ),
    ],
  ),

  'Сравнение чисел': TopicTheory(
    topicName: 'Сравнение чисел',
    subtitle: 'Знаки сравнения: >, <, =',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Знаки сравнения',
        content: 'Для сравнения двух чисел используют три знака:\n\n>  — больше (левое число больше правого)\n<  — меньше (левое число меньше правого)\n=  — равно (числа одинаковые)',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Правило «открытой стороны»',
        content: 'Знак всегда «раскрывается» в сторону большего числа:\n\n  5 > 3   — раскрыт к пятёрке\n  2 < 7   — раскрыт к семёрке\n  4 = 4   — числа равны',
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
        content: 'Представь знак как рот — он всегда хочет «съесть» большее число и открывается в его сторону.',
      ),
    ],
  ),

  'Фигуры': TopicTheory(
    topicName: 'Фигуры',
    subtitle: 'Основные геометрические фигуры',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Геометрические фигуры',
        content: 'Геометрическая фигура — замкнутая линия на плоскости. Основные характеристики фигуры: количество сторон, углов и их свойства.',
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
        content: 'Круг — монета, тарелка, колесо\nТреугольник — дорожный знак, крыша дома\nКвадрат — кафельная плитка, кубик\nПрямоугольник — дверь, экран телефона, книга',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content: 'Квадрат — это частный случай прямоугольника, у которого все четыре стороны равны.',
      ),
    ],
  ),

  'Задачи на сложение': TopicTheory(
    topicName: 'Задачи на сложение',
    subtitle: 'Решение текстовых задач',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Текстовая задача',
        content: 'Текстовая задача содержит условие (известные данные) и вопрос (что нужно найти). Чтобы решить задачу, нужно определить действие и выполнить вычисление.',
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
        content: 'Условие: В корзине 3 яблока и 4 груши. Сколько фруктов в корзине?\n\nИзвестно: 3 яблока, 4 груши\nНайти: сколько всего фруктов\nДействие: сложение (слово «всего»)\nРешение: 3 + 4 = 7\nОтвет: 7 фруктов.',
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

  'Умножение на 2': TopicTheory(
    topicName: 'Умножение на 2',
    subtitle: 'Понятие умножения, таблица на 2',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое умножение',
        content: 'Умножение — это сложение одинаковых слагаемых.\n\na × b означает: число a сложить b раз.\n\nЗнак умножения: ×\nЗапись: множитель × множитель = произведение',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Умножение на 2',
        content: 'a × 2 = a + a\n\nУмножить на 2 — значит удвоить число.\n\nПример: 6 × 2 = 6 + 6 = 12',
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
        content: 'Произведение любого числа на 2 всегда чётное (оканчивается на 0, 2, 4, 6, 8).',
      ),
    ],
  ),

  'Умножение на 3': TopicTheory(
    topicName: 'Умножение на 3',
    subtitle: 'Таблица умножения на 3',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Умножение на 3',
        content: 'a × 3 = a + a + a\n\nУмножить число на 3 — значит сложить его три раза.\n\nПример: 4 × 3 = 4 + 4 + 4 = 12',
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
        content: 'a × 3 = a × 2 + a\n\nЕсли знаешь таблицу на 2, прибавь число ещё раз:\n7 × 3 = 7 × 2 + 7 = 14 + 7 = 21',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Признак делимости на 3',
        content: 'Если сумма цифр числа делится на 3, то и само число делится на 3.\n\n21: 2 + 1 = 3 (делится) ✓\n25: 2 + 5 = 7 (не делится) ✗',
      ),
    ],
  ),

  'Умножение на 4 и 5': TopicTheory(
    topicName: 'Умножение на 4 и 5',
    subtitle: 'Приёмы быстрого умножения',
    sections: [
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Умножение на 4',
        content: 'a × 4 = (a × 2) × 2\n\nУмножить на 4 — значит дважды удвоить.\n\nПример: 7 × 4\n7 × 2 = 14\n14 × 2 = 28\nОтвет: 28',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Умножение на 5',
        content: 'a × 5 = a × 10 ÷ 2\n\nУмножить на 5 — умножь на 10 и раздели пополам.\n\nПример: 7 × 5\n7 × 10 = 70\n70 ÷ 2 = 35\nОтвет: 35',
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
        content: 'Произведение любого числа на 5 всегда оканчивается на 0 или 5.',
      ),
    ],
  ),

  'Деление': TopicTheory(
    topicName: 'Деление',
    subtitle: 'Действие, обратное умножению',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое деление',
        content: 'Деление — разбиение числа на равные части.\n\nЗнак деления: ÷\nЗапись: делимое ÷ делитель = частное\n\nПример: 12 ÷ 3 = 4 (двенадцать разделить на три равно четырём)',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Связь умножения и деления',
        content: 'Если a × b = c, то:\nc ÷ a = b\nc ÷ b = a\n\nПример:\n4 × 3 = 12\n12 ÷ 3 = 4\n12 ÷ 4 = 3',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content: 'Задача: 15 ÷ 5 = ?\n\nДумаем: на какое число нужно умножить 5, чтобы получить 15?\n5 × 3 = 15\n\nЗначит 15 ÷ 5 = 3.',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Правила деления',
        content: 'На ноль делить нельзя.\nПри делении на 1 число не меняется: a ÷ 1 = a.\nЧисло, делённое на себя, равно 1: a ÷ a = 1.',
      ),
    ],
  ),

  'Текстовые задачи': TopicTheory(
    topicName: 'Текстовые задачи',
    subtitle: 'Выбор действия по условию задачи',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Как определить действие',
        content: 'В тексте задачи есть ключевые слова, которые подсказывают нужное арифметическое действие.',
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
        content: 'Условие: В 4 коробках по 6 карандашей. Сколько карандашей всего?\n\nИзвестно: 4 коробки, по 6 карандашей\nКлючевые слова: «по 6 в каждой» → умножение\nРешение: 4 × 6 = 24\nОтвет: 24 карандаша.',
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

  'Время': TopicTheory(
    topicName: 'Время',
    subtitle: 'Единицы измерения времени',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Единицы времени',
        content: 'Время измеряется в различных единицах. Основные единицы: секунды, минуты, часы, сутки.',
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
        content: 'Короткая (часовая) стрелка — показывает часы.\nДлинная (минутная) стрелка — показывает минуты.\n\nМинутная стрелка делает полный круг за 1 час.\nЧасовая стрелка делает полный круг за 12 часов.',
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

  'Умножение на 6-9': TopicTheory(
    topicName: 'Умножение на 6-9',
    subtitle: 'Полная таблица умножения',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Переместительное свойство',
        content: 'Если ты знаешь таблицу умножения до 5, то бóльшую часть таблицы 6–9 ты уже знаешь.\n\n6 × 4 = 4 × 6 = 24\n7 × 3 = 3 × 7 = 21\n\nОсталось выучить лишь случаи, где оба множителя ≥ 6.',
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
        content: 'a × 9 = a × 10 − a\n\nПример: 7 × 9 = 70 − 7 = 63\n\nДополнительный признак: сумма цифр произведения на 9 всегда равна 9.\n63: 6 + 3 = 9 ✓',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Приём для умножения на 6',
        content: 'a × 6 = a × 5 + a\n\n8 × 6 = 8 × 5 + 8 = 40 + 8 = 48\n7 × 6 = 7 × 5 + 7 = 35 + 7 = 42',
      ),
    ],
  ),

  'Деление с остатком': TopicTheory(
    topicName: 'Деление с остатком',
    subtitle: 'Когда число не делится нацело',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Деление с остатком',
        content: 'Если число не делится нацело, получается неполное частное и остаток.\n\nОстаток — та часть делимого, которая «не вместилась» в целое число групп.',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Формула',
        content: 'a = b × q + r\n\nгде:\na — делимое\nb — делитель\nq — неполное частное\nr — остаток\n\nВажно: остаток всегда меньше делителя (r < b)',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content: '17 ÷ 5 = ?\n\nПодбираем: 5 × 3 = 15 (ближайшее к 17, не превышая его)\nОстаток: 17 − 15 = 2\n\nОтвет: 17 ÷ 5 = 3 (остаток 2)\nПроверка: 5 × 3 + 2 = 17 ✓',
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

  'Периметр': TopicTheory(
    topicName: 'Периметр',
    subtitle: 'Сумма длин всех сторон фигуры',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Определение',
        content: 'Периметр (P) — это сумма длин всех сторон многоугольника. Измеряется в единицах длины (мм, см, дм, м).',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Формулы периметра',
        content: 'Прямоугольник:\nP = (a + b) × 2\nгде a — длина, b — ширина\n\nКвадрат:\nP = a × 4\nгде a — сторона квадрата\n\nТреугольник:\nP = a + b + c\nгде a, b, c — стороны',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content: 'Найти периметр прямоугольника со сторонами 5 см и 3 см.\n\nP = (a + b) × 2\nP = (5 + 3) × 2\nP = 8 × 2\nP = 16 см\n\nОтвет: 16 см.',
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

  'Площадь': TopicTheory(
    topicName: 'Площадь',
    subtitle: 'Измерение поверхности фигур',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Определение',
        content: 'Площадь (S) — это величина, которая показывает, сколько места занимает фигура на плоскости. Измеряется в квадратных единицах (мм², см², дм², м²).',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Формулы площади',
        content: 'Прямоугольник:\nS = a × b\nгде a — длина, b — ширина\n\nКвадрат:\nS = a × a = a²\nгде a — сторона квадрата',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор примера',
        content: 'Найти площадь прямоугольника со сторонами 6 см и 4 см.\n\nS = a × b\nS = 6 × 4\nS = 24 см²\n\nОтвет: 24 см².',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Периметр и площадь — разные величины',
        content: 'Периметр — длина границы (в см).\nПлощадь — размер поверхности (в см²).\n\nПрямоугольник 6 × 4 см:\nP = (6 + 4) × 2 = 20 см\nS = 6 × 4 = 24 см²',
      ),
    ],
  ),

  'Единицы длины': TopicTheory(
    topicName: 'Единицы длины',
    subtitle: 'Перевод единиц измерения длины',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Единицы длины',
        content: 'Длину измеряют в миллиметрах (мм), сантиметрах (см), дециметрах (дм), метрах (м) и километрах (км).',
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

  'Единицы массы': TopicTheory(
    topicName: 'Единицы массы',
    subtitle: 'Граммы, килограммы, центнеры, тонны',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Единицы массы',
        content: 'Массу измеряют в граммах (г), килограммах (кг), центнерах (ц) и тоннах (т).',
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
        content: '1 г — скрепка для бумаги\n100 г — яблоко\n1 кг — пачка сахара\n1 ц (100 кг) — взрослый человек\n1 т (1000 кг) — легковой автомобиль',
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

  'Многозначные числа': TopicTheory(
    topicName: 'Многозначные числа',
    subtitle: 'Разряды и арифметика больших чисел',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Разряды чисел',
        content: 'Каждая цифра в числе занимает определённый разряд, который определяет её значение.\n\nРазряды (справа налево): единицы, десятки, сотни, тысячи, десятки тысяч и т.д.',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Разрядный состав числа 4 528',
        content: 'Разряд:    тыс.    сот.    дес.    ед.\nЦифра:        4         5         2        8\n\n4 528 = 4 000 + 500 + 20 + 8\n\n4 — тысячи  (4 × 1000)\n5 — сотни     (5 × 100)\n2 — десятки  (2 × 10)\n8 — единицы (8 × 1)',
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
        content: 'Всегда выравнивай числа по разрядам. Складывай (или вычитай) строго справа налево, не забывая про перенос.',
      ),
    ],
  ),

  'Дроби': TopicTheory(
    topicName: 'Дроби',
    subtitle: 'Понятие дроби, сравнение дробей',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое дробь',
        content: 'Дробь обозначает часть целого. Записывается в виде a/b.\n\nЧислитель (a) — сколько частей взяли.\nЗнаменатель (b) — на сколько равных частей разделили целое.',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Пример: дробь 3/4',
        content: 'Целое разделено на 4 равные части.\nВзято 3 из них.\n\n[■][■][■][  ]\n\n3  ←  числитель (взяли 3 части)\n─\n4  ←  знаменатель (всего 4 части)',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Сравнение дробей',
        content: 'Одинаковый знаменатель:\nСравниваем числители.\n3/5 > 2/5  (три пятых больше двух пятых)\n\nОдинаковый числитель:\nБольше та дробь, у которой знаменатель меньше.\n1/3 > 1/4  (треть больше четвертинки)\n\nПравило: чем больше знаменатель, тем мельче части.',
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

  'Уравнения': TopicTheory(
    topicName: 'Уравнения',
    subtitle: 'Нахождение неизвестного компонента',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Что такое уравнение',
        content: 'Уравнение — это равенство, содержащее неизвестное число (обычно обозначается буквой x). Решить уравнение — значит найти такое значение x, при котором равенство верно.',
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
        content: 'Уравнение: x + 5 = 12\n\nНеизвестное слагаемое = сумма − известное слагаемое\nx = 12 − 5\nx = 7\n\nПроверка: 7 + 5 = 12 ✓',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Ещё пример',
        content: 'Уравнение: x × 4 = 20\n\nНеизвестный множитель = произведение ÷ известный множитель\nx = 20 ÷ 4\nx = 5\n\nПроверка: 5 × 4 = 20 ✓',
      ),
    ],
  ),

  'Скорость, время, расстояние': TopicTheory(
    topicName: 'Скорость, время, расстояние',
    subtitle: 'Задачи на движение',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Три величины',
        content: 'Скорость (V) — расстояние, пройденное за единицу времени (км/ч, м/с).\nВремя (t) — продолжительность движения (ч, мин, с).\nРасстояние (S) — длина пройденного пути (км, м).',
      ),
      TheorySection(
        type: TheorySectionType.formula,
        title: 'Основные формулы',
        content: 'S = V × t    — расстояние\nV = S ÷ t    — скорость\nt = S ÷ V    — время\n\nВсе три формулы следуют из одной:\nS = V × t',
      ),
      TheorySection(
        type: TheorySectionType.visual,
        title: 'Треугольник S–V–t',
        content: '          S\n       ┌──┴──┐\n       V  ×  t\n\nЗакрой искомую величину:\n• Ищешь S  →  V × t\n• Ищешь V  →  S ÷ t\n• Ищешь t  →  S ÷ V',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Разбор задач',
        content: 'Задача 1. Велосипедист ехал 3 ч со скоростью 15 км/ч. Найти расстояние.\nS = V × t = 15 × 3 = 45 км\n\nЗадача 2. Поезд проехал 240 км за 4 ч. Найти скорость.\nV = S ÷ t = 240 ÷ 4 = 60 км/ч\n\nЗадача 3. Пешеход идёт со скоростью 5 км/ч. Путь — 20 км. Найти время.\nt = S ÷ V = 20 ÷ 5 = 4 ч',
      ),
    ],
  ),

  'Порядок действий': TopicTheory(
    topicName: 'Порядок действий',
    subtitle: 'Правила выполнения арифметических действий',
    sections: [
      TheorySection(
        type: TheorySectionType.definition,
        title: 'Порядок действий',
        content: 'При вычислении выражений с несколькими действиями необходимо соблюдать строгий порядок. Нарушение порядка приводит к неверному результату.',
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
        content: 'Вычислить: 2 + 3 × 4\n\n1) Умножение: 3 × 4 = 12\n2) Сложение: 2 + 12 = 14\n\nОтвет: 14\n\nОшибка: если сначала сложить 2 + 3 = 5, затем 5 × 4 = 20 — это неверно!',
      ),
      TheorySection(
        type: TheorySectionType.example,
        title: 'Пример со скобками',
        content: 'Вычислить: (8 + 2) × 3 − 4 ÷ 2\n\n1) Скобки: 8 + 2 = 10\n2) Умножение: 10 × 3 = 30\n3) Деление: 4 ÷ 2 = 2\n4) Вычитание: 30 − 2 = 28\n\nОтвет: 28',
      ),
      TheorySection(
        type: TheorySectionType.tip,
        title: 'Обрати внимание',
        content: 'Скобки всегда имеют наивысший приоритет — они указывают, какое действие выполнить первым, независимо от типа операции внутри.',
      ),
    ],
  ),
};
