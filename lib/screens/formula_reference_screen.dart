import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/math_text.dart';
import '../widgets/topic_lesson_card.dart';

class FormulaEntry {
  const FormulaEntry(
    this.title,
    this.formula,
    this.symbols,
    this.example,
    this.visual,
  );
  final String title, formula, symbols, example, visual;
}

const formulaReference = [
  FormulaEntry(
    'Сложение и вычитание дробей',
    r'$\frac{a}{c}+\frac{b}{c}=\frac{a+b}{c}$'
        '\n'
        r'$\frac{a}{c}-\frac{b}{c}=\frac{a-b}{c}$',
    'a и b — числители, c — общий ненулевой знаменатель. При разных знаменателях сначала приведи дроби к общему.',
    '1/3 + 1/6 = 2/6 + 1/6 = 1/2',
    'fraction',
  ),
  FormulaEntry(
    'Деление дробей',
    '(a/b) ÷ (c/d) = (a × d)/(b × c)',
    'b, c и d не равны нулю. Первую дробь сохраняем, вторую переворачиваем.',
    '(2/3) ÷ (4/5) = (2/3) × (5/4) = 5/6',
    'fraction',
  ),
  FormulaEntry(
    'Процент от числа и целое',
    'b = a × p/100',
    'a — целое, p — процент, b — часть. Если известна часть, целое a = b ÷ (p/100), где p не равен нулю.',
    '20% от 150: 150 × 20/100 = 30',
    'fraction',
  ),
  FormulaEntry(
    'Линейное уравнение',
    'a × x + b = 0; x = -b/a',
    'a — коэффициент при неизвестном x, a не равен нулю. b — свободный член.',
    '2x − 6 = 0; 2x = 6; x = 3',
    'line',
  ),
  FormulaEntry(
    'Квадратное уравнение',
    'D = b² − 4ac; x = (-b ± √D)/(2a)',
    'Для ax² + bx + c = 0, a не равен нулю. При D > 0 два действительных корня, при D = 0 один, при D < 0 действительных корней нет.',
    'x² − 5x + 6 = 0; D = 1; x = 2 или x = 3',
    'parabola',
  ),
  FormulaEntry(
    'Степени',
    r'$a^m \times a^n = a^{m+n}$',
    'Основания должны совпадать. Для целых неотрицательных m и n правило работает для любого a, кроме неопределённого 0⁰.',
    '2³ × 2² = 2⁵ = 32',
    'powers',
  ),
  FormulaEntry(
    'Теорема Пифагора',
    'a² + b² = c²',
    'Только для прямоугольного треугольника: a и b — катеты, c — гипотенуза напротив прямого угла.',
    'a = 3, b = 4; c = √(9 + 16) = 5',
    'pythagoras',
  ),
  FormulaEntry(
    'Площадь треугольника',
    'S = a × h/2',
    'a — основание, h — высота, перпендикулярная этому основанию. Единицы длины должны совпадать.',
    'a = 8 см, h = 5 см; S = 20 см²',
    'triangle',
  ),
  FormulaEntry(
    'Площадь и периметр прямоугольника',
    'S = a × b; P = 2(a + b)',
    'a и b — длины соседних сторон. Площадь измеряется в квадратных единицах, периметр — в единицах длины.',
    'a = 3 см, b = 5 см; S = 15 см², P = 16 см',
    'rectangle',
  ),
  FormulaEntry(
    'Длина окружности и площадь круга',
    'C = 2πr; S = πr²',
    'r — радиус, π ≈ 3.14159. Диаметр d = 2r. C — длина окружности, S — площадь круга.',
    'r = 3 см; C = 6π см, S = 9π см²',
    'circle',
  ),
  FormulaEntry(
    'Синус и косинус острого угла',
    'sin α = a/c; cos α = b/c',
    'В прямоугольном треугольнике a — катет напротив угла α, b — прилежащий катет, c — гипотенуза.',
    'a = 3, b = 4, c = 5; sin α = 3/5, cos α = 4/5',
    'trigTriangle',
  ),
  FormulaEntry(
    'Классическая вероятность',
    'P = m/n',
    'n — число равновозможных исходов, m — число благоприятных. n > 0. При неравновозможных исходах это правило неприменимо.',
    'У честного кубика 3 чётные грани из 6: P = 3/6 = 1/2',
    'probability',
  ),
];

class FormulaReferenceScreen extends StatefulWidget {
  const FormulaReferenceScreen({super.key});
  @override
  State<FormulaReferenceScreen> createState() => _FormulaReferenceScreenState();
}

class _FormulaReferenceScreenState extends State<FormulaReferenceScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.toLowerCase().replaceAll('ё', 'е').trim();
    final entries = formulaReference
        .where(
          (e) => query
              .split(RegExp(r'\s+'))
              .every(
                (word) => '${e.title} ${e.formula} ${e.symbols}'
                    .toLowerCase()
                    .replaceAll('ё', 'е')
                    .contains(word),
              ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Формулы'),
        leading: IconButton(
          tooltip: 'Назад к подготовке',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/practice');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Найти формулу или тему',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Очистить поиск',
                            onPressed: () => setState(search.clear),
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text(
                          'Ничего не найдено. Попробуй другое название.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            key: ValueKey(entry.title),
                            child: ExpansionTile(
                              title: Text(entry.title),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: MathText(
                                  entry.formula,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              childrenPadding: const EdgeInsets.all(16),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  entry.symbols,
                                  style: const TextStyle(height: 1.5),
                                ),
                                const SizedBox(height: 12),
                                Semantics(
                                  image: true,
                                  label: 'Схема правила: ${entry.title}',
                                  child: SizedBox(
                                    height: 150,
                                    child: CustomPaint(
                                      painter: LessonDiagramPainter(
                                        entry.visual,
                                        Theme.of(context).colorScheme,
                                      ),
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Схема правила; пример ниже использует свои числа.',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Text('Пример'),
                                const SizedBox(height: 8),
                                MathText(
                                  entry.example,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
