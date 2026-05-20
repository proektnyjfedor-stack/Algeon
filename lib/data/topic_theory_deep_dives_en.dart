part of 'topic_theory.dart';

/// English deep-dive sections (same topic keys as [_topicDeepDiveSections]).
List<TheorySection> _topicDeepDiveSectionsEnglish(String topicName) {
  switch (topicName) {
    case 'Натуральные числа':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What natural numbers are',
          content:
              'Natural numbers are the numbers we use to count objects: 1, 2, 3, … Zero is usually treated separately (your class will say explicitly).\n\n'
              'In decimal notation each digit has a place: ones, tens, hundreds, and so on. This matters for long division and for GCD/LCM.',
        ),
        const TheorySection(
          type: TheorySectionType.steps,
          title: 'GCD and LCM — what the words mean',
          content: '',
          items: [
            'GCD(a, b) is the largest integer that divides both a and b without remainder — the shared prime structure of the two numbers.',
            'LCM(a, b) is the smallest positive integer that is a multiple of both a and b — a common step scale when two repeating processes align.',
            'A prime has only divisors 1 and itself. Prime factorization helps find GCD (shared factors) and LCM (all factors with the largest needed powers).',
          ],
        ),
      ];

    case 'Обыкновенные дроби':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What the notation a/b means',
          content:
              'A fraction splits a whole into equal parts. The denominator b is how many equal parts; the numerator a counts how many parts you take.\n\n'
              'If a > b, the fraction is improper and can be written as a mixed number.',
        ),
        const TheorySection(
          type: TheorySectionType.steps,
          title: 'Operations — what they mean',
          content: '',
          items: [
            'Addition and subtraction: you can only combine parts of the same size, so you find a common denominator — a shared part size.',
            'Multiplication: “a fraction of a fraction”. Multiply numerators and denominators separately.',
            'Dividing by a fraction: multiply by the reciprocal, because division is the inverse of multiplication.',
          ],
        ),
      ];

    case 'Проценты':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What a percent is',
          content:
              'A percent is a part of a whole measured in hundredths: 1% = 1/100 of the whole.\n\n'
              'If the whole is 100%, then P% means P equal hundredth parts of that whole.',
        ),
        const TheorySection(
          type: TheorySectionType.formula,
          title: 'How to read common wording',
          content:
              '“P% of x” means x × (P/100).\n\n'
              '“Increase by P%” often means: it was x, now it is x × (1 + P/100).\n\n'
              '“Decrease by P%” means: x × (1 − P/100).',
        ),
      ];

    case 'Геометрия: периметр и площадь':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Perimeter vs area — different questions',
          content:
              'Perimeter answers “how long is the boundary?” and is measured in cm, m, and so on.\n\n'
              'Area answers “how much region does the shape cover?” and is measured in square units (cm², m²).',
        ),
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Pythagoras — what it says',
          content:
              'In a right triangle, the square of the hypotenuse equals the sum of squares of the legs: c² = a² + b².\n\n'
              'The hypotenuse is opposite the right angle; the legs form the right angle.',
        ),
      ];

    case 'Координатная прямая':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Absolute value and distance',
          content:
              '|a| is the distance from a to 0 on the number line, so |a| ≥ 0.\n\n'
              'The distance between a and b is |a − b|: the length of the segment between the two points.',
        ),
      ];

    case 'Рациональные числа':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What extends beyond ordinary fractions',
          content:
              'Rational numbers are numbers of the form p/q with integer p and natural q (usually q ≠ 0). They include integers (for example 5 = 5/1), fractions, and finite or repeating decimals.',
        ),
        const TheorySection(
          type: TheorySectionType.steps,
          title: 'Sign rules — the logic',
          content: '',
          items: [
            'A product of two numbers with the same sign is positive: “minus times minus is plus” because two reflections restore direction.',
            'A product of numbers with opposite signs is negative.',
            'Subtraction a − b is the same as addition a + (−b): subtracting means adding the opposite.',
          ],
        ),
      ];

    case 'Пропорции':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Why cross multiplication works',
          content:
              'Equality a/b = c/d compares two scales. Multiplying both sides by bd gives ad = bc.\n\n'
              'This is a convenient rule: multiply “the extremes” and “the means”.',
        ),
      ];

    case 'Координаты на плоскости':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Quadrants and coordinate signs',
          content:
              'A point (x, y): x is horizontal displacement from the y-axis; y is vertical displacement from the x-axis.\n\n'
              'The signs of x and y determine the quadrant (when the point is not on an axis).',
        ),
      ];

    case 'Линейная функция':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What k and b mean in y = kx + b',
          content:
              'k is how fast y changes when x increases by 1 (when x is measured in steps along the axis).\n\n'
              'b is the value of y at x = 0 — the height where the line crosses the y-axis.',
        ),
      ];

    case 'Степени и одночлены':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Why exponent rules exist',
          content:
              'Rules like aᵐaⁿ = aᵐ⁺ⁿ and aᵐ/aⁿ = aᵐ⁻ⁿ group repeated factors.\n\n'
              '(aᵐ)ⁿ = aᵐⁿ means: first take m copies, then repeat that block n times.',
        ),
      ];

    case 'Многочлены':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Degree of a polynomial and like terms',
          content:
              'A polynomial is a sum of monomials. Its degree is the largest degree among its terms after combining like terms.\n\n'
              'Like terms share the same variable part — you add them like identical objects.',
        ),
      ];

    case 'Геометрия: треугольники':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Congruence — what you can “transfer”',
          content:
              'Two triangles are congruent if they match on enough sides and angles that everything else is forced to match.\n\n'
              'For example, with two sides and the included angle, the third side and the other two angles are uniquely determined.',
        ),
      ];

    case 'Системы уравнений':
      return [
        const TheorySection(
          type: TheorySectionType.steps,
          title: 'Substitution — the logic',
          content: '',
          items: [
            'Solve one equation for one variable.',
            'Substitute that expression into the other equation — you get one equation in one variable.',
            'Solve it, then substitute back to find the second variable.',
            'Check by plugging (x, y) into both equations.',
          ],
        ),
        const TheorySection(
          type: TheorySectionType.steps,
          title: 'Elimination — why you multiply equations',
          content: '',
          items: [
            'The goal is to add equations so one variable cancels (coefficients become opposites).',
            'Sometimes you multiply one or both equations by a number to create that cancellation.',
            'After finding one variable, substitute into a simpler equation of the system.',
          ],
        ),
      ];

    case 'Квадратные уравнения':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What “quadratic equation” means',
          content:
              'Standard form: ax² + bx + c = 0 with a ≠ 0.\n\n'
              'If a = 0, the quadratic term disappears and you have a linear equation. So a ≠ 0 is part of the definition.',
        ),
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'What the discriminant is',
          content:
              'D = b² − 4ac appears when you complete the square.\n\n'
              'The sign of D tells you the situation without drawing the graph:\n'
              '• D > 0 — two distinct real roots;\n'
              '• D = 0 — one real double root;\n'
              '• D < 0 — no real roots (complex roots come later).\n\n'
              'Geometrically, roots are x-intercepts of the parabola y = ax² + bx + c.',
        ),
        const TheorySection(
          type: TheorySectionType.steps,
          title: 'A typical sequence using D',
          content: '',
          items: [
            'Rewrite the equation as ax² + bx + c = 0 (everything on one side, 0 on the other).',
            'Read coefficients a, b, c with their signs.',
            'Compute D = b² − 4ac.',
            'If D ≥ 0, use x = (−b ± √D)/(2a); if D = 0, x = −b/(2a).',
            'Check by substituting into the original equation.',
          ],
        ),
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Vieta’s formulas (meaning)',
          content:
              'If roots exist and the equation is written as x² + px + q = 0, the sum of roots equals −p and the product equals q.\n\n'
              'For ax² + bx + c = 0 you often divide by a first to reach the monic form.',
        ),
      ];

    case 'Алгебраические дроби':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Domain — why you watch the denominator',
          content:
              'P(x)/Q(x) is only defined where Q(x) ≠ 0. Exclude those values from the domain.\n\n'
              'After cancellations, “hidden” restrictions can appear — check the original expression in the problem.',
        ),
      ];

    case 'Квадратичная функция':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Parabola and the coefficient a',
          content:
              'The graph of y = ax² + bx + c is a parabola. The sign of a sets branch direction: a > 0 opens up (a minimum exists); a < 0 opens down (a maximum).\n\n'
              'The vertex is the extremum; the axis of symmetry is the vertical line through the vertex.',
        ),
      ];

    case 'Корни и степени':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'nth root — inverse to a power',
          content:
              'ⁿ√a is a (real, under suitable conditions) number whose nth power equals a.\n\n'
              'For a ≥ 0, the square root is taken to be non-negative by convention.',
        ),
      ];

    case 'Неравенства':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Why multiplying by a negative flips the sign',
          content:
              'Multiplying an inequality by a negative number reflects the number line: “who is farther right” swaps.\n\n'
              'So when you multiply or divide by a negative expression, flip the inequality sign.',
        ),
      ];

    case 'Прогрессии':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Common difference vs common ratio',
          content:
              'In an arithmetic progression, neighbors differ by the same d — the common difference.\n\n'
              'In a geometric progression, neighbors scale by the same factor q — the common ratio.',
        ),
      ];

    case 'Степенная функция':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'How the exponent n affects the domain',
          content:
              'For y = xⁿ with integer n, behavior for negative x depends on parity: odd powers keep the sign of x; even powers remove a minus when squaring in the even case.\n\n'
              'Fractional powers like x^(1/2) need careful domain restrictions.',
        ),
      ];

    case 'Элементы тригонометрии':
    case 'Тригонометрия':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Sine and cosine in a right triangle',
          content:
              'Pick an acute angle α. Opposite over hypotenuse is sin α; adjacent over hypotenuse is cos α.\n\n'
              'So sin and cos are ratios of lengths — dimensionless numbers between 0 and 1 for acute angles.',
        ),
      ];

    case 'Геометрия: окружность':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Central and inscribed angles',
          content:
              'A central angle subtends an arc and is measured at the center.\n\n'
              'An inscribed angle subtending the same arc is half the central angle — a key fact for circle problems.',
        ),
      ];

    case 'Тригонометрические функции':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Period and bounds of sin and cos',
          content:
              'sin x and cos x are periodic with period 2π: values repeat after a full turn.\n\n'
              'For all x, |sin x| ≤ 1 and |cos x| ≤ 1 from the unit-circle definition.',
        ),
      ];

    case 'Тригонометрические уравнения':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Why “+ 2πn” appears',
          content:
              'Solving sin x = a has infinitely many solutions on the line because angles that differ by full turns 2πn share the same sine (and sometimes symmetry adds another family).\n\n'
              'Similarly for cos x; tan x has period π and domain restrictions.',
        ),
      ];

    case 'Вероятность и статистика':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Classical probability',
          content:
              'If outcomes are symmetric and equally likely, P(A) = (number of favorable outcomes)/(number of all outcomes).\n\n'
              'The mean is a weighted “center” of data; the median is robust to rare extreme values; the mode is the most frequent value.',
        ),
      ];

    case 'Показательная функция':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Why the base satisfies a > 0 and a ≠ 1',
          content:
              'For integer exponents, aˣ is repeated multiplication. For real exponents you need conventions with a positive base.\n\n'
              'If a = 1, then 1ˣ = 1 always — a degenerate case without exponential growth/decay.',
        ),
      ];

    case 'Логарифмы':
    case 'Показательные и логарифмы':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Logarithm — the exponent in a power',
          content:
              'log_a b = c means aᶜ = b. So the logarithm answers: “To what power must we raise a to obtain b?”\n\n'
              'Domain: a > 0, a ≠ 1, b > 0.',
        ),
      ];

    case 'Стереометрия':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Volume and surface area',
          content:
              'Volume measures “how much space is inside” a solid (cubic units). Surface area sums the areas of all faces (square units).\n\n'
              'For prisms and cylinders you often use nets or standard formulas.',
        ),
      ];

    case 'Производная':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Meaning of the derivative',
          content:
              'f′(x) is the instantaneous rate of change of f at x (when the limit exists). Geometrically, it is the slope of the tangent line.\n\n'
              'If f′ > 0 locally, f increases; if f′ < 0, f decreases.',
        ),
      ];

    case 'Интеграл':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Integral and area',
          content:
              'A definite integral is numerically related to signed area under a graph (watch the sign if the graph goes below the axis).\n\n'
              'An antiderivative F satisfies F′ = f; it helps compute integrals via the Newton–Leibniz formula.',
        ),
      ];

    case 'Комбинаторика':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Permutations, arrangements, combinations',
          content:
              'Permutations count ways to order all objects.\n\n'
              'Arrangements (ordered selections) count ordered picks of k from n.\n\n'
              'Combinations count unordered selections: only which objects are chosen matters.',
        ),
      ];

    case 'Теория вероятностей':
      return [
        const TheorySection(
          type: TheorySectionType.definition,
          title: 'Events, probability, independence',
          content:
              'An event is a statement that may or may not happen in a trial.\n\n'
              'Probabilities are non-negative, sum to 1 over a full set of disjoint outcomes, and add for disjoint events.\n\n'
              'Independent events: knowing one does not change the probability of the other.',
        ),
      ];

    default:
      return const <TheorySection>[];
  }
}
