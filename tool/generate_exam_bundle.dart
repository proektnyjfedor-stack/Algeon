// Генерирует assets/exams/exam_bundle.json и SVG-чертежи для вариантов ОГЭ/ЕГЭ.
// Запуск: dart run tool/generate_exam_bundle.dart
//
// Формулировки и нумерация заданий приведены к структуре КИМ ФИПИ (математика);
// тексты — учебные, с собственными числами (не копипаст с коммерческих сборников).

import 'dart:convert';
import 'dart:io';

/// Пифагоровы тройки для задач с целочисленными гипотенузами.
const _pythTriples = [
  [3, 4, 5],
  [5, 12, 13],
  [8, 15, 17],
  [7, 24, 25],
  [20, 21, 29],
  [9, 12, 15],
  [6, 8, 10],
  [12, 16, 20],
  [15, 8, 17],
  [10, 24, 26],
];

void main() {
  final root = Directory.current;
  final diagramsDir = Directory('${root.path}/assets/exams/diagrams');
  if (!diagramsDir.existsSync()) {
    diagramsDir.createSync(recursive: true);
  }

  final oge = <Map<String, dynamic>>[];
  final ege = <Map<String, dynamic>>[];

  for (var v = 1; v <= 10; v++) {
    writeOgeDiagrams(v, diagramsDir);
    writeEgeDiagrams(v, diagramsDir);
    oge.add(buildOgeVariant(v));
    ege.add(buildEgeVariant(v));
  }

  final bundle = <String, dynamic>{
    'meta': {
      'source': 'Структура заданий — спецификация/открытый банк ФИПИ; оформление Algeon.',
      'ogeVariants': 10,
      'egeVariants': 10,
      'tasksPerVariant': 20,
    },
    'oge': oge,
    'ege': ege,
  };

  File('${root.path}/assets/exams/exam_bundle.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(bundle),
  );

  stdout.writeln('Wrote assets/exams/exam_bundle.json and diagrams.');
}

void writeOgeDiagrams(int v, Directory diagramsDir) {
  final coord = 5 + v;
  File('${diagramsDir.path}/oge_v${v}_t03.svg').writeAsStringSync(
    _coordRaySvg(coord, maxTick: 16),
  );
  final a = 3 + v;
  final b = 4 + v;
  File('${diagramsDir.path}/oge_v${v}_t16.svg').writeAsStringSync(
    _rightTriangleSvg(a, b),
  );
}

void writeEgeDiagrams(int v, Directory diagramsDir) {
  final h1 = 15 + v;
  final h2 = 25 + 2 * v;
  final h3 = 18 + 3 * v;
  File('${diagramsDir.path}/ege_v${v}_t08.svg').writeAsStringSync(
    _barChartSvg(heights: [h1, h2, h3], labels: const ['I', 'II', 'III']),
  );
  File('${diagramsDir.path}/ege_v${v}_t14.svg').writeAsStringSync(
    _unitCircleSvg(angleDeg: 30 + v * 6),
  );
}

String _coordRaySvg(int coord, {required int maxTick}) {
  const tickW = 14.0;
  const left = 24.0;
  const y = 36.0;
  final lineEnd = left + maxTick * tickW;
  final ax = left + coord * tickW;
  final ticks = StringBuffer();
  for (var i = 0; i <= maxTick; i++) {
    final x = left + i * tickW;
    ticks.writeln(
      '<line x1="$x" y1="${y - 5}" x2="$x" y2="${y + 6}" stroke="#334155" stroke-width="1.2"/>',
    );
    ticks.writeln(
      '<text x="${x - 3}" y="${y + 22}" font-size="10" fill="#64748b" font-family="system-ui,sans-serif">$i</text>',
    );
  }
  return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${lineEnd + 28} 64" width="100%" height="auto">
  <line x1="$left" y1="$y" x2="$lineEnd" y2="$y" stroke="#0f172a" stroke-width="2"/>
  $ticks
  <circle cx="$ax" cy="$y" r="6" fill="#2563eb"/>
  <text x="${ax - 4}" y="${y + 4}" font-size="10" fill="white" font-weight="700" font-family="system-ui,sans-serif">A</text>
</svg>
''';
}

String _rightTriangleSvg(int legA, int legB) {
  const ox = 40;
  const oy = 110;
  const ax = ox;
  final ay = oy - legA * 6;
  final bx = ox + legB * 6;
  const by = oy;
  return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 130" width="100%" height="auto">
  <polygon points="$ax,$ay $bx,$by $ox,$oy" fill="#eff6ff" stroke="#1e40af" stroke-width="2"/>
  <rect x="$ox" y="${oy - 12}" width="12" height="12" fill="none" stroke="#64748b" stroke-width="1"/>
  <text x="${ox - 28}" y="${(oy + ay) ~/ 2}" font-size="12" fill="#0f172a" font-family="system-ui,sans-serif">$legA</text>
  <text x="${(ox + bx) ~/ 2}" y="${oy + 18}" font-size="12" fill="#0f172a" font-family="system-ui,sans-serif">$legB</text>
</svg>
''';
}

String _barChartSvg({
  required List<int> heights,
  required List<String> labels,
}) {
  final maxH = heights.reduce((a, b) => a > b ? a : b);
  const baseY = 120;
  const barW = 36;
  const gap = 28;
  var x = 30;
  final parts = StringBuffer();
  for (var i = 0; i < heights.length; i++) {
    final h = (heights[i] / maxH * 80).round();
    final y = baseY - h;
    parts.writeln(
      '<rect x="$x" y="$y" width="$barW" height="$h" rx="4" fill="#3b82f6"/>',
    );
    parts.writeln(
      '<text x="${x + 8}" y="${baseY + 16}" font-size="11" fill="#334155" font-family="system-ui,sans-serif">${labels[i]}</text>',
    );
    x += barW + gap;
  }
  return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 220 140" width="100%" height="auto">
  <line x1="20" y1="$baseY" x2="200" y2="$baseY" stroke="#94a3b8" stroke-width="1"/>
  $parts
</svg>
''';
}

String _unitCircleSvg({required int angleDeg}) {
  const cx = 70;
  const cy = 70;
  const r = 50;
  final cos = _cosDeg(angleDeg);
  final sin = _sinDeg(angleDeg);
  final ex = cx + r * cos;
  final ey = cy - r * sin;
  return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 140 140" width="100%" height="auto">
  <circle cx="$cx" cy="$cy" r="$r" fill="none" stroke="#334155" stroke-width="2"/>
  <line x1="$cx" y1="$cy" x2="$cx" y2="${cy - r}" stroke="#94a3b8" stroke-width="1"/>
  <line x1="$cx" y1="$cy" x2="$ex" y2="$ey" stroke="#2563eb" stroke-width="2"/>
  <text x="${cx + r + 6}" y="$cy" font-size="10" fill="#64748b" font-family="system-ui,sans-serif">1</text>
  <text x="${ex - 4}" y="${ey - 6}" font-size="11" fill="#2563eb" font-weight="600" font-family="system-ui,sans-serif">P</text>
</svg>
''';
}

double _cosDeg(int d) {
  const table = {
    36: 0.8090169943749475,
    42: 0.7431448254773941,
    48: 0.6691306063588582,
    54: 0.5877852522924731,
    60: 0.5,
    66: 0.40673664307580015,
    72: 0.30901699437494745,
    78: 0.20791169081775934,
    84: 0.10452846326765346,
    90: 0.0,
  };
  return table[d] ?? 0.7071067811865476;
}

double _sinDeg(int d) {
  const table = {
    36: 0.5877852522924731,
    42: 0.6691306063588582,
    48: 0.7431448254773941,
    54: 0.8090169943749475,
    60: 0.8660254037844386,
    66: 0.9135454576426009,
    72: 0.9510565162951535,
    78: 0.9781476007338057,
    84: 0.9945218953682733,
    90: 1.0,
  };
  return table[d] ?? 0.7071067811865476;
}

Map<String, dynamic> buildOgeVariant(int v) {
  final vid = 'oge_v$v';
  final tasks = <Map<String, dynamic>>[];

  final t1a = 10 + v;
  final t1b = 20 - v;
  final t1c = v * 5;
  final t1ans = t1a * t1b - t1c;
  tasks.add(_t(
    id: '${vid}_01',
    grade: 9,
    q: 'Вычислите: $t1a × $t1b − $t1c',
    ans: '$t1ans',
  ));

  final m = 3500000 + v * 250000;
  final cm = 16 + 2 * v;
  final km = (cm * m / 100000).round();
  tasks.add(_t(
    id: '${vid}_02',
    grade: 9,
    q:
        'На карте масштаба 1:$m расстояние между населёнными пунктами равно $cm см. Найдите это расстояние на местности (в километрах).',
    ans: '$km',
  ));

  final coord = 5 + v;
  tasks.add(_t(
    id: '${vid}_03',
    grade: 9,
    q:
        'На координатной прямой отмечена точка A (см. рисунок). Запишите координату точки A.',
    ans: '$coord',
    image: 'assets/exams/diagrams/${vid}_t03.svg',
  ));

  final price = 2400 + v * 150;
  final disc = 12 + v;
  final pay = (price * (100 - disc) / 100).round();
  tasks.add(_t(
    id: '${vid}_04',
    grade: 9,
    q:
        'Товар стоит $price руб. Магазин объявил скидку $disc%. Сколько рублей стоит товар со скидкой?',
    ans: '$pay',
  ));

  final adult = 320 + 20 * v;
  final child = 140 + 10 * v;
  final fam = 2 * adult + 3 * child;
  tasks.add(_t(
    id: '${vid}_05',
    grade: 9,
    q:
        'Семья из 2 взрослых и 3 детей покупает билеты. Взрослый билет — $adult руб., детский — $child руб. Сколько рублей заплатят за все билеты?',
    ans: '$fam',
  ));

  final a = 2 + v;
  final b = 1 + (v % 4);
  final expr = (2 * a - b) * (2 * a - b);
  tasks.add(_t(
    id: '${vid}_06',
    grade: 9,
    q:
        'Найдите значение выражения \$(2a - b)^2\$ при \$a = $a\$, \$b = $b\$.',
    ans: '$expr',
  ));

  final tA = _pythTriples[(v - 1) % _pythTriples.length];
  final tB = _pythTriples[v % _pythTriples.length];
  final rootSum = tA[2] + tB[2];
  tasks.add(_t(
    id: '${vid}_07',
    grade: 9,
    q:
        'Вычислите: \$\\sqrt{${tA[0]}^2 + ${tA[1]}^2} + \\sqrt{${tB[0]}^2 + ${tB[1]}^2}\$',
    ans: '$rootSum',
  ));

  final n = 55 + v * 3; // не квадрат целого
  final lo = _sqrtFloor(n);
  final lo1 = lo + 1;
  tasks.add(_t(
    id: '${vid}_08',
    grade: 9,
    q: 'Укажите промежуток, которому принадлежит число \$\\sqrt{$n}\$.',
    type: 'multipleChoice',
    options: [
      '(${lo - 1}; $lo)',
      '($lo; $lo1)',
      '($lo1; ${lo + 2})',
      '(${lo + 2}; ${lo + 3})',
    ],
    ans: '($lo; $lo1)',
  ));

  final medList = [v, 12, 3 + v, 18, 7, 2 * v, 9];
  medList.sort();
  final med = medList[medList.length ~/ 2];
  tasks.add(_t(
    id: '${vid}_09',
    grade: 9,
    q: 'Найдите медиану набора чисел: ${medList.join(', ')}.',
    ans: '$med',
  ));

  final tC = _pythTriples[(v + 2) % _pythTriples.length];
  final tD = _pythTriples[(v + 3) % _pythTriples.length];
  final h1 = tC[2];
  final h2 = tD[2];
  final first = h1 >= h2 ? tC : tD;
  final second = h1 >= h2 ? tD : tC;
  final diff = first[2] - second[2];
  tasks.add(_t(
    id: '${vid}_10',
    grade: 9,
    q:
        'Вычислите: \$\\sqrt{${first[0]}^2 + ${first[1]}^2} - \\sqrt{${second[0]}^2 + ${second[1]}^2}\$',
    ans: '$diff',
  ));

  final pw = 8 + v;
  final pb = 20 - v;
  tasks.add(_t(
    id: '${vid}_11',
    grade: 9,
    q:
        'В корзине $pw белых и $pb жёлтых шаров. Наудачу вынимают один шар. Найдите вероятность того, что он белый (десятичная дробь).',
    ans: _prob(pw, pw + pb),
  ));

  final nums = [4 + v, 7, 4, 9 + v, 6];
  final mean = (nums.reduce((a, b) => a + b) / nums.length);
  final meanStr = mean == mean.roundToDouble() ? '${mean.toInt()}' : mean.toStringAsFixed(2);
  tasks.add(_t(
    id: '${vid}_12',
    grade: 9,
    q: 'Найдите среднее арифметическое чисел: ${nums.join(', ')}.',
    ans: meanStr,
  ));

  final xv = 2 + v % 5;
  final fv = 3 * xv - xv * xv;
  tasks.add(_t(
    id: '${vid}_13',
    grade: 9,
    q:
        'Функция \$y = 3x - x^2\$. Найдите значение \$y\$ при \$x = $xv\$.',
    ans: '$fv',
  ));

  final speed1 = 55 + 5 * v;
  final hours2 = 2 + v;
  final speed2 = 40 + 2 * v;
  final totalPath = 2 * speed1 + hours2 * speed2;
  tasks.add(_t(
    id: '${vid}_14',
    grade: 9,
    q:
        'Автомобиль первые 2 ч ехал со скоростью $speed1 км/ч, затем $hours2 ч — со скоростью $speed2 км/ч. Найдите весь пройденный путь (км).',
    ans: '$totalPath',
  ));

  final x1 = 1 + v % 3;
  final y1 = 3 + v % 5;
  final x2 = 7 + v;
  final y2 = 11 + v;
  final my = (y1 + y2) ~/ 2;
  tasks.add(_t(
    id: '${vid}_15',
    grade: 9,
    q:
        'Отрезок \$AB\$: \$A($x1;\\; $y1)\$, \$B($x2;\\; $y2)\$. Найдите ординату середины отрезка.',
    ans: '$my',
  ));

  final legA = 3 + v;
  final legB = 4 + v;
  final triArea = legA * legB ~/ 2;
  tasks.add(_t(
    id: '${vid}_16',
    grade: 9,
    q:
        'На рисунке изображён прямоугольный треугольник с катетами $legA и $legB. Найдите площадь треугольника.',
    ans: '$triArea',
    image: 'assets/exams/diagrams/${vid}_t16.svg',
  ));

  final L = 10 + v;
  final W = 5 + (v % 4);
  tasks.add(_t(
    id: '${vid}_17',
    grade: 9,
    q: 'Прямоугольник со сторонами $L см и $W см. Найдите его площадь (см²).',
    ans: '${L * W}',
  ));

  const chordSpecs = [
    [16, 6, 10],
    [18, 12, 15],
    [10, 12, 13],
    [30, 8, 17],
    [12, 8, 10],
    [16, 6, 10],
    [18, 12, 15],
    [10, 12, 13],
    [30, 8, 17],
    [12, 8, 10],
  ];
  final cs = chordSpecs[(v - 1) % chordSpecs.length];
  final chord = cs[0];
  final dist = cs[1];
  final r = cs[2];
  tasks.add(_t(
    id: '${vid}_18',
    grade: 9,
    q:
        'Хорда окружности равна $chord см. Расстояние от центра окружности до хорды равно $dist см. Найдите радиус (см).',
    ans: '$r',
  ));

  final base = 12 + v;
  final h = 8 + (v % 5);
  tasks.add(_t(
    id: '${vid}_19',
    grade: 9,
    q:
        'Основание треугольника равно $base см, высота к нему — $h см. Найдите площадь (см²).',
    ans: '${base * h ~/ 2}',
  ));

  final xeq = 7 + 2 * v;
  tasks.add(_t(
    id: '${vid}_20',
    grade: 9,
    q:
        'Решите уравнение: 3(x − 1) = 2(x + ${2 + v}). Найдите x.',
    ans: '$xeq',
  ));

  return {
    'id': vid,
    'title': 'ОГЭ Вариант $v',
    'subtitle': 'Математика, 9 класс (структура КИМ ФИПИ)',
    'timeMinutes': 235,
    'tasks': tasks,
  };
}

Map<String, dynamic> buildEgeVariant(int v) {
  final vid = 'ege_v$v';
  final tasks = <Map<String, dynamic>>[];

  final apple = 75 + 5 * v;
  final pear = 100 + 15 * v;
  final paid = 350 + 50 * v;
  final spent = 2 * apple + pear;
  tasks.add(_t(
    id: '${vid}_01',
    grade: 11,
    q:
        'Покупатель купил 2 кг яблок по $apple руб./кг и 1 кг груш за $pear руб. Он заплатил $paid руб. Сколько рублей сдачи?',
    ans: '${paid - spent}',
  ));

  final vplane = 750 + 50 * v;
  final th = 2.5 + v * 0.1;
  final distPlane = (vplane * th).round();
  tasks.add(_t(
    id: '${vid}_02',
    grade: 11,
    q:
        'Скорость самолёта $vplane км/ч. Какое расстояние (км, целое) он пролетит за $th ч?',
    ans: '$distPlane',
  ));

  final d1 = 100 + v * 10;
  final d2 = 95 + v * 5;
  const d3 = 110;
  final d4 = 120 + v;
  final d5 = 125 + 2 * v;
  final avg = ((d1 + d2 + d3 + d4 + d5) / 5).round();
  tasks.add(_t(
    id: '${vid}_03',
    grade: 11,
    q:
        'За 5 дней продали: $d1, $d2, $d3, $d4, $d5 единиц товара. Найдите среднедневные продажи (целое число).',
    ans: '$avg',
  ));

  final force = 40 + 3 * v;
  final path = 10 + v;
  tasks.add(_t(
    id: '${vid}_04',
    grade: 11,
    q:
        'Работа A = F·s (Дж), F — сила (Н), s — путь (м). При F = $force Н и s = $path м найдите A.',
    ans: '${force * path}',
  ));

  final eqAns = 3 + v;
  final rhs = 21 + 7 * v;
  tasks.add(_t(
    id: '${vid}_05',
    grade: 11,
    q: 'Решите уравнение: 7x − $rhs = 0. Найдите x.',
    ans: '$eqAns',
  ));

  final e1 = 3 + v % 4;
  final e2 = 4 + v % 3;
  final e3 = 5 + v % 5;
  tasks.add(_t(
    id: '${vid}_06',
    grade: 11,
    q: 'Объём прямоугольного параллелепипеда с рёбрами $e1, $e2 и $e3.',
    ans: '${e1 * e2 * e3}',
  ));

  final oldP = 1200 + 100 * v;
  final newP = oldP + 240 + 20 * v;
  final pct = (((newP - oldP) / oldP) * 100).round();
  tasks.add(_t(
    id: '${vid}_07',
    grade: 11,
    q:
        'Товар стоил $oldP руб., затем $newP руб. На сколько процентов подорожал товар?',
    ans: '$pct',
  ));

  final bar1 = 15 + v;
  final bar3 = 18 + 3 * v;
  tasks.add(_t(
    id: '${vid}_08',
    grade: 11,
    q:
        'На рисунке — объёмы продаж за три квартала (условные единицы). На сколько единиц объём III квартала больше, чем I? (см. рисунок)',
    ans: '${bar3 - bar1}',
    image: 'assets/exams/diagrams/${vid}_t08.svg',
  ));

  final unit = 240 + 20 * v;
  tasks.add(_t(
    id: '${vid}_09',
    grade: 11,
    q:
        '3 одинаковых товара по $unit руб. Скидка 10% при покупке от 3 шт. Сколько рублей за 3 штуки со скидкой?',
    ans: '${(unit * 3 * 0.9).round()}',
  ));

  final stud = 22 + v;
  final onlyA = 10 + v % 5;
  final onlyB = 8 + v % 4;
  final both = 4 + v % 3;
  final neither = stud - (onlyA + onlyB + both);
  tasks.add(_t(
    id: '${vid}_10',
    grade: 11,
    q:
        'В группе $stud студентов: только язык A — $onlyA, только B — $onlyB, оба — $both. Сколько не изучают ни A, ни B?',
    ans: '$neither',
  ));

  final dep = 80000 + 10000 * v;
  final rate = 10 + v % 5;
  tasks.add(_t(
    id: '${vid}_11',
    grade: 11,
    q:
        'Вклад $dep руб. под $rate% годовых (простые проценты) на 1 год. Какая сумма на счёте через год?',
    ans: '${dep + (dep * rate ~/ 100)}',
  ));

  final a1 = 4 + v % 5;
  final d = 4 + v % 4;
  final a8 = a1 + 7 * d;
  tasks.add(_t(
    id: '${vid}_12',
    grade: 11,
    q:
        'Арифметическая прогрессия: \$a_1 = $a1\$, \$d = $d\$. Найдите \$a_8\$.',
    ans: '$a8',
  ));

  final b1 = 2 + v % 3;
  final qv = 2 + v % 2;
  final b5 = b1 * qv * qv * qv * qv;
  tasks.add(_t(
    id: '${vid}_13',
    grade: 11,
    q:
        'Геометрическая прогрессия: \$b_1 = $b1\$, \$q = $qv\$. Найдите \$b_5\$.',
    ans: '$b5',
  ));

  final angle = 30 + v * 6;
  tasks.add(_t(
    id: '${vid}_14',
    grade: 11,
    q:
        'На единичной окружности отмечена точка P (см. рисунок). Угол между OP и положительным направлением оси абсцисс равен $angle°. Запишите sin этого угла с точностью до сотых (как в таблице Брадиса: например 0,81).',
    ans: _sinRounded(angle),
    image: 'assets/exams/diagrams/${vid}_t14.svg',
  ));

  final te = _pythTriples[(v + 4) % _pythTriples.length];
  final cat1 = te[0];
  final cat2 = te[1];
  final hyp = te[2];
  tasks.add(_t(
    id: '${vid}_15',
    grade: 11,
    q:
        'Катеты прямоугольного треугольника $cat1 и $cat2. Найдите гипотенузу.',
    ans: '$hyp',
  ));

  final edge = 3 + v % 5;
  tasks.add(_t(
    id: '${vid}_16',
    grade: 11,
    q: 'Ребро куба $edge см. Площадь полной поверхности (см²).',
    ans: '${6 * edge * edge}',
  ));

  final logArg = 1 << (3 + v % 3);
  tasks.add(_t(
    id: '${vid}_17',
    grade: 11,
    q: 'Вычислите: \$\\log_{2} $logArg\$',
    ans: '${3 + v % 3}',
  ));

  final ang = 30 + v * 5;
  tasks.add(_t(
    id: '${vid}_18',
    grade: 11,
    q:
        'Вычислите: sin²($ang°) + cos²($ang°). В ответе запишите число.',
    ans: '1',
  ));

  final pc = 10 + 2 * v;
  final pb = 7 + v;
  tasks.add(_t(
    id: '${vid}_19',
    grade: 11,
    q:
        'Корни уравнения \$x^2 - ${pb}x + $pc = 0\$. Найдите произведение корней.',
    ans: '$pc',
  ));

  final ineqMin = 8 + v;
  tasks.add(_t(
    id: '${vid}_20',
    grade: 11,
    q:
        'Найдите наименьшее целое x, при котором верно: 2x − 3 > x + ${4 + v}.',
    ans: '$ineqMin',
  ));

  return {
    'id': vid,
    'title': 'ЕГЭ Вариант $v',
    'subtitle': 'Математика профильного уровня, 11 класс (часть 1, тренировочный набор)',
    'timeMinutes': 235,
    'tasks': tasks,
  };
}

Map<String, dynamic> _t({
  required String id,
  required int grade,
  required String q,
  required String ans,
  String type = 'textInput',
  List<String>? options,
  String? image,
}) {
  return {
    'id': id,
    'grade': grade,
    'topic': grade == 9 ? 'ОГЭ' : 'ЕГЭ',
    'question': q,
    'type': type,
    'options': options,
    'answer': ans,
    'hint': null,
    'imageAsset': image,
    'explanationSteps': <String>[],
  };
}

int _sqrtFloor(int n) {
  var k = 0;
  while ((k + 1) * (k + 1) <= n) {
    k++;
  }
  return k;
}

String _prob(int a, int b) {
  // decimal with 2-3 places
  final x = a / b;
  if ((x * 100).round() == x * 100) {
    return x.toStringAsFixed(2);
  }
  return x.toStringAsFixed(3);
}

String _sinRounded(int angle) {
  const s = {
    30: '0.5',
    36: '0.59',
    42: '0.67',
    48: '0.74',
    54: '0.81',
    60: '0.87',
    66: '0.91',
    72: '0.95',
    78: '0.98',
    84: '0.99',
    90: '1',
  };
  return s[angle] ?? '0.71';
}
