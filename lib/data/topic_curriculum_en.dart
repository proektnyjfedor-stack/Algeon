/// English curriculum texts (keys match Russian [kTopicCurriculumTexts]).
library;

const Map<String, String> kTopicCurriculumTextsEn = {
  'Счёт до 10': '''
Numbers from 1 to 10 are the first building blocks of arithmetic: we learn quantity, comparison, and putting groups together.

Addition means joining two groups. We write a + b and read it as "a plus b". The result is the sum; the numbers we add are called addends.

A key fact: changing the order of addends does not change the sum (for example 4 + 3 and 3 + 4). On a number line, addition is moving to the right.

• Addends can be swapped — the sum stays the same.
• You can check addition with subtraction, and the other way around.
• A number line helps you "see" the calculation.
''',
  'Счёт до 20': '''
Up to 20, addition and subtraction often cross a ten. Use "make a ten" strategies: split one number so the other reaches 10, then add what is left.

Example: 8 + 5 = 8 + (2 + 3) = (8 + 2) + 3 = 10 + 3 = 13.

If your class uses expressions with several operations: do parentheses first, then multiplication and division, then addition and subtraction from left to right.

• "Make 10" reduces mental mistakes.
• Learn "partner to 10" pairs (for 7, the partner is 3).
• After crossing 10, sanity-check the size of the answer.
''',
  'Вычитание до 10': '''
Subtraction answers "how much is left after removing a part" or "how much larger one number is than another". In a − b, a is the minuend, b is the subtrahend, and the result is the difference.

Subtraction and addition are inverse: if a + b = c, then c − a = b and c − b = a.

On a number line, subtraction moves left from the minuend.

• difference + subtrahend = minuend (check).
• Order matters: you cannot swap minuend and subtrahend.
''',
  'Сравнение чисел': '''
We compare numbers with >, <, and =. A helpful rule: the narrow point of < or > points to the smaller number; the open side points to the larger.

On a number line, the number farther to the right is greater (for non-negative numbers in early grades).

• Use "=" only when values are truly equal.
• Comparisons are transitive: if a > b and b > c, then a > c.
''',
  'Фигуры': '''
We study plane figures by sides, angles, equal sides, and right angles.

A triangle has three sides and three angles. Quadrilaterals have four sides. A rectangle has four right angles; opposite sides are equal. A square is a rectangle with all sides equal.

A circle is the set of points at the same distance from a center; the region inside is often called a disk.

• Count sides along a closed boundary, not only "visible corners".
• A right angle can be checked with a paper corner.
''',
  'Задачи на сложение': '''
Word problems connect a real situation to a mathematical operation. Addition often means combining parts or increasing an amount.

A good routine: read the question; list what is known and what is asked; choose the operation; compute; answer with units (apples, km, rubles).

Words like "total", "together", "found more", or "had and added" often suggest addition — but always read for meaning.

• The answer must match what the question asks.
• Keep numbers and units consistent.
''',
  'Умножение на 2': '''
Multiplication starts as repeated addition: a × 2 = a + a ("double" a).

The table of 2 lists even numbers: 2, 4, 6, … Division by 2 is the inverse of doubling.

• Multiplication is commutative: 2 × 7 = 7 × 2.
• Check with division: (a × 2) ÷ 2 = a.
''',
  'Умножение на 3': '''
Tripling repeats an addend three times: a × 3 = a + a + a.

A useful link: a × 3 = a × 2 + a.

• Commutativity means you need fewer facts to memorize because you can "flip" products.
• Check with division when appropriate.
''',
  'Умножение на 4 и 5': '''
Multiply by 4 as double twice: a × 4 = (a × 2) × 2.

Multiply by 5 using tens: a × 5 = (a × 10) ÷ 2 for whole a.

Products by 5 end in 0 or 5 for whole multipliers.

• Build from facts you already know.
• a × 4 is always even for whole-number a.
''',
  'Деление': '''
Division models splitting into equal groups ("share equally") and measurement ("how many times b fits into a").

If a × b = c, then c ÷ b = a and c ÷ a = b — check with multiplication.

Division by zero is undefined.

• Remainder (when taught) is always less than the divisor for natural-number division.
• Division by 1 returns the same number.
''',
  'Текстовые задачи': '''
Word problems require reading the structure: find a whole, find a part, compare by difference, or group items.

"How much more / less" is usually related to subtraction of quantities.

"How many times larger / smaller" often uses division. Pay close attention to the wording.

• If two steps are needed, name the intermediate result before the second step.
• Draw a sketch or table when data is messy.
''',
  'Время': '''
Time is measured in hours, minutes, and seconds. On an analog clock, the short hand shows hours and the long hand shows minutes.

1 hour = 60 minutes; half an hour = 30 minutes; a quarter hour = 15 minutes.

Duration is often "end time minus start time" on one timeline.

• Clarify AM/PM or 24-hour format as used in your class.
• "In half an hour" needs a clear starting moment.
• Adding minutes can cross 60 — like carrying in place value.
''',
  'Умножение на 6-9': '''
The multiplication facts for 6–9 build on earlier facts and properties.

Commutativity means you do not need a separate memorization for 7 × 9 if you know 9 × 7.

Factor a multiplier (for example 8 = 4 × 2) to reuse smaller products.

• Train pairs that are commonly confused.
• Parity checks can catch some mistakes.
''',
  'Деление с остатком': '''
When division is not exact, dividend = divisor × quotient + remainder.

For natural numbers, remainder is non-negative and strictly less than the divisor.

Example: 23 ÷ 5 → quotient 4 because 5 × 4 = 20; remainder 3; check 3 < 5.

• The remainder is determined uniquely.
• If remainder is 0, division is exact.
''',
  'Периметр': '''
Perimeter is the total length around a shape (sum of side lengths).

For a rectangle with sides a and b: P = 2(a + b). For a square with side a: P = 4a.

Use the same length units (mm, cm, m).

• Do not confuse perimeter with area.
''',
  'Площадь': '''
Area measures how many unit squares fit inside a figure.

Rectangle area: S = ab. Square area: S = a².

Area units are square units (cm², m²).

• Convert all lengths to the same unit before multiplying.
• For composite figures without overlap, area often adds.
''',
  'Единицы длины': '''
Metric length uses km, m, dm, cm, mm.

Common conversions: 1 km = 1000 m; 1 m = 10 dm = 100 cm; 1 dm = 10 cm; 1 cm = 10 mm.

Multiply when going to a smaller unit; divide when going to a larger unit.

• Watch powers of 10 carefully.
• A scale on a drawing links drawn length to real length.
''',
  'Единицы массы': '''
Mass uses grams, kilograms, centners, and tons in school contexts.

1 t = 1000 kg; 1 c = 100 kg; 1 kg = 1000 g.

Convert to one unit before adding or subtracting named quantities.

• Mixed forms like "2 kg 300 g" convert cleanly to grams.
''',
  'Многозначные числа': '''
Place value means a digit's value depends on its position: ones, tens, hundreds, thousands, …

Expand numbers by place value (for example 5847 = 5000 + 800 + 40 + 7).

Compare multi-digit numbers starting from the highest place.

• Align place values in column arithmetic.
• Rounding follows class rules for approximate work.
''',
  'Дроби': '''
A fraction describes equal parts of a whole. The denominator is how many equal parts; the numerator counts how many you take.

A proper fraction is less than 1; an improper fraction can be written as a mixed number.

• Equal parts must truly be equal in the model.
• Later you reduce fractions and find common denominators.
''',
  'Уравнения': '''
An equation is a statement with an unknown; the goal is to find values that make it true.

At this level, use inverse operations: in x + a = b, subtract a; in x − a = b, add a; in c x = b with c ≠ 0, divide by c.

A "balance" model: the same operation on both sides keeps equality.

• Always substitute back to check.
• Parentheses change order — be careful.
''',
  'Скорость, время, расстояние': '''
Uniform motion links distance S, speed V, and time t:

S = V t;  V = S / t;  t = S / V.

Keep units consistent (for example km/h with hours gives km).

• Never divide by zero time in a real interpretation.
• If minutes and hours mix, convert time to one unit.
''',
  'Порядок действий': '''
In one expression, evaluate in a fixed order.

Parentheses first (innermost if nested).

Then multiplication and division left to right.

Then addition and subtraction left to right.

Classic pitfall: 2 + 3 × 4 = 2 + 12 = 14, not 20.

• Parentheses change the order and therefore the result.
''',
  'Натуральные числа': '''
Natural numbers count objects; many courses start at 1.

You study prime factorization, GCD and LCM, and divisibility rules.

Exponentiation repeats multiplication: aⁿ = a · a · … (n times).

• GCD captures shared prime structure; LCM captures a common "step scale".
• Divisibility tests for 2, 3, 5, 9, 10 are useful tools.
''',
  'Обыкновенные дроби': '''
A fraction p/q uses integers with q ≠ 0. Integers are fractions with denominator 1.

Add and subtract after a common denominator.

Multiply numerators and denominators; simplify when possible.

Dividing by a fraction is multiplying by its reciprocal.

• Reduce by dividing numerator and denominator by their GCD.
''',
  'Проценты': '''
A percent is a hundredth part: 1% = 1/100.

"p% of T" means T × (p/100).

"Increase by p%" often means multiply by (1 + p/100); "decrease by p%" means multiply by (1 − p/100).

"What percent is A of B?" uses (A/B) × 100%.

• Identify the "whole" (100%) carefully in word problems.
''',
  'Геометрия: периметр и площадь': '''
Perimeter measures boundary length; area measures region inside a plane figure.

Rectangle: P = 2(a+b), S = ab. Triangle area often starts as S = (base × height)/2.

Circle circumference C = 2πr and area S = πr².

Pythagorean theorem for right triangles: c² = a² + b² with hypotenuse c.

• Keep linear units vs square units separate.
''',
  'Координатная прямая': '''
A number line orders numbers: origin, positive direction, and a unit length.

The point farther right is greater (standard orientation).

Absolute value |a| is distance from a to 0, so |a| ≥ 0.

Distance between x₁ and x₂ is |x₁ − x₂|.

• Inequalities are easy to visualize by shading intervals.
''',
  'Рациональные числа': '''
A rational number can be written as m/n with integers m and n, where n ≠ 0. Integers are rational numbers with denominator 1.

Sign rules extend multiplication and division.

Subtraction is addition of the opposite: a − b = a + (−b).

Compare rationals via a common denominator or decimals when helpful.

• Division by zero is never allowed.
''',
  'Пропорции': '''
A proportion states two ratios are equal: a/b = c/d.

Cross-multiplication gives ad = bc (with valid non-zero denominators).

Direct proportionality has the form y = kx; inverse proportionality has the form y = k/x (x ≠ 0), with the correct interpretation.

• Map matching rows carefully in tables.
''',
  'Координаты на плоскости': '''
Cartesian coordinates (x, y) locate a point relative to perpendicular x- and y-axes.

Axes split the plane into quadrants with fixed sign patterns.

Distance from (x, y) to the origin is √(x² + y²).

Midpoint of ((x₁,y₁),(x₂,y₂)) is ((x₁+x₂)/2, (y₁+y₂)/2).

• A circle centered at the origin has equation x² + y² = R².
''',
  'Линейная функция': '''
y = kx + b is a straight line in the plane.

k is the slope: how much y changes when x increases by 1.

b is the y-intercept at x = 0.

Parallel lines share the same k; intersections solve a 2×2 linear system.

• For two points on the line, Δy = k Δx when Δx ≠ 0.
''',
  'Степени и одночлены': '''
Exponent laws group repeated factors: aᵐ aⁿ = aᵐ⁺ⁿ; aᵐ/aⁿ = aᵐ⁻ⁿ (a ≠ 0); (aᵐ)ⁿ = aᵐⁿ.

Extend with a⁰ = 1 (a ≠ 0) and a⁻ⁿ = 1/aⁿ.

A monomial is a product of a coefficient and powers of variables; its degree is the sum of the variable exponents.

• Combine like terms by matching variable parts.
''',
  'Многочлены': '''
A polynomial is a sum of monomials; its degree is the highest monomial degree after simplification.

Special product formulas speed up algebra.

Factoring uses common factors, grouping, and identities.

• Watch for domain restrictions after cancellations.
''',
  'Геометрия: треугольники': '''
The interior angles of a triangle sum to 180° in Euclidean geometry.

Congruence criteria let you prove triangles match from limited data (for example SAS).

Pythagoras applies only to right triangles.

Median, angle bisector, and altitude have standard definitions.

• Triangle inequality constrains possible side lengths.
''',
  'Системы уравнений': '''
A 2×2 linear system asks for (x, y) satisfying both equations.

Substitution: solve one equation for a variable and plug into the other.

Elimination: multiply equations so one variable cancels when added.

Geometrically, solutions are intersection points of two lines (if they intersect).

• Parallel distinct lines: no solution; coincident lines: infinitely many solutions.
''',
  'Квадратные уравнения': '''
ax² + bx + c = 0 with a ≠ 0 is quadratic.

Discriminant D = b² − 4ac determines real roots: two if D > 0, one repeated if D = 0, none in ℝ if D < 0 (until complex numbers).

Roots: x = (−b ± √D)/(2a).

Vieta links sum and product of roots to coefficients in the monic form.

• Always check by substitution.
''',
  'Алгебраические дроби': '''
P/Q is algebraic when P and Q are polynomials; exclude zeros of Q from the domain.

Reduce by canceling common polynomial factors; track hidden restrictions.

Add/subtract with a common denominator.

Multiply across; divide by multiplying by the reciprocal.

• Factor denominators to find domain and simplify.
''',
  'Квадратичная функция': '''
y = ax² + bx + c with a ≠ 0 is a parabola.

If a > 0, branches open upward (minimum at the vertex); if a < 0, branches open downward (maximum).

Vertex x-coordinate: x₀ = −b/(2a); then y₀ = f(x₀).

Zeros match roots of ax² + bx + c = 0.

• c is the y-intercept at x = 0.
''',
  'Корни и степени': '''
The square root of a ≥ 0 is the non-negative x with x² = a.

Properties include √(ab) = √a · √b for a, b ≥ 0.

Rational exponents connect to roots; negative exponents mean reciprocals.

Rationalizing denominators removes radicals from denominators when required.

• √(a+b) is not √a + √b in general.
''',
  'Неравенства': '''
Solving inequalities keeps the inequality direction when you add or subtract the same value on both sides.

Multiplying or dividing by a positive number keeps the sign; multiplying or dividing by a negative number flips the sign.

For continuous expressions, the interval method finds zeros of numerator and denominator on the domain, then tests sign between critical points.

Quadratic expressions are often factored to determine sign intervals.

Systems of inequalities use intersections of solution sets.

• Raising to an even power can introduce extraneous solutions — check domain and signs.
• Strict vs non-strict inequalities treat boundary points separately.
''',
  'Прогрессии': '''
Arithmetic progression: constant difference d between neighbors, aₙ = a₁ + (n−1)d.

Sum of first n terms: Sₙ = n(a₁ + aₙ)/2.

Geometric progression: constant ratio q, bₙ = b₁ qⁿ⁻¹.

Finite sum for q ≠ 1: Sₙ = b₁(qⁿ − 1)/(q − 1).

Infinite geometric series converges for |q| < 1 to b₁/(1 − q).
''',
  'Степенная функция': '''
y = xⁿ behaves differently for even vs odd integer n on ℝ.

Even powers are non-negative for all real x; odd powers preserve the sign of x.

y = √x is defined for x ≥ 0 and increases.

General real powers xᵃ later use exponentials and logarithms.

• Laws of exponents still govern products and compositions.
''',
  'Элементы тригонометрии': '''
In a right triangle for acute angle α:

sin α = opposite/hypotenuse; cos α = adjacent/hypotenuse; tan α = sin α / cos α (cos α ≠ 0).

Identity: sin²α + cos²α = 1.

Special angles 30°, 45°, 60° have exact values from equilateral and isosceles right triangles.

• Always label which side is opposite which angle.
''',
  'Геометрия: окружность': '''
A circle is the set of points at distance r from a center.

Circumference C = 2πr; disk area S = πr².

An inscribed angle subtending an arc is half the central angle on the same arc (standard configuration).

A tangent is perpendicular to the radius at the point of tangency.

• Opposite angles of a cyclic quadrilateral sum to 180°.
''',
  'Тригонометрия': '''
Beyond right triangles, the unit circle defines sin and cos for arbitrary angles.

Signs depend on quadrant; tan has issues where cos = 0.

Graphs are periodic; sin and cos have period 2π.

Identities include angle-addition formulas in later grades.

• Reduce angles to a base interval when solving.
''',
  'Тригонометрические функции': '''
sin x and cos x are bounded by 1 in absolute value and periodic with period 2π.

tan x has period π with vertical asymptotes where cos x = 0.

Transformations y = A sin(ωx + φ) change amplitude, period, and phase.

• Even/odd symmetry helps simplify integrals later.
''',
  'Тригонометрические уравнения': '''
Equations like sin x = a with |a| ≤ 1 have infinitely many solutions due to periodicity.

cos x = a uses ± arccos a + 2πn patterns; tan x = a uses arctan a + πn with domain restrictions.

Squaring both sides can add extraneous solutions — check in the original equation.

• Graphs help count solutions on a bounded interval.
''',
  'Вероятность и статистика': '''
In the classical model with equally likely outcomes, P(A) = favorable/total.

Mean summarizes center; median is robust to outliers; mode is the most frequent value.

Spread can be described by variance and standard deviation.

• Conditional probability restricts the sample space carefully.
''',
  'Показательная функция': '''
y = aˣ with a > 0 and a ≠ 1 is monotone and always positive.

If a > 1, the function grows as x → +∞; if 0 < a < 1, it decays toward 0.

Laws: aˣ⁺ʸ = aˣ aʸ; (aˣ)ʸ = aˣʸ with valid domains.

The number e defines the natural exponential eˣ in later analysis.

• Exponential growth models constant relative growth rates.
''',
  'Логарифмы': '''
logₐ b = c means aᶜ = b, with domain restrictions a > 0, a ≠ 1, b > 0.

Log rules turn products into sums, quotients into differences, and powers into multiples.

Change of base: logₐ b = ln b / ln a.

Solve log equations by exponentiating and checking the domain.

• Logarithmic inequalities require care with base above/below 1.
''',
  'Стереометрия': '''
Solid geometry studies volumes and surface areas of 3D bodies.

Prism volume V = base area × height (with correct height meaning).

Pyramid volume is one third of prism with same base and height.

Cylinder/cone analogs for circular bases.

Sphere: V = (4/3)πr³, surface area S = 4πr².

• Cross sections often reduce problems to plane geometry.
''',
  'Производная': '''
f′(x) is the instantaneous rate of change of f at x (when the limit exists). Geometrically, it is the slope of the tangent line.

Standard derivative tables and sum/product/quotient rules build complex derivatives.

The chain rule differentiates compositions f(g(x)).

Applications include local extrema via f′ = 0 and sign tests.

• If x is time and y is position, derivative is velocity.
''',
  'Интеграл': '''
An antiderivative F satisfies F′ = f up to +C.

The definite integral relates to signed area under a graph.

Newton–Leibniz: ∫ₐᵇ f(x) dx = F(b) − F(a) for suitable f and F.

Techniques include substitution and integration by parts (when taught).

• Linearity: integral of a sum is sum of integrals (under common hypotheses).
''',
  'Показательные и логарифмы': '''
Exponential and logarithmic functions are inverses (with domain care).

Equations aᶠ⁽ˣ⁾ = aᵍ⁽ˣ⁾ reduce to f(x) = g(x) when bases match and domains allow.

Log equations need domain checks after exponentiating.

• Growth comparisons often use exponentials vs polynomials asymptotically.
''',
  'Комбинаторика': '''
Permutations count orderings: n! ways to arrange n distinct objects.

Combinations count unordered selections: C(n,k).

The binomial theorem expands (a+b)ⁿ with binomial coefficients.

• Addition rule for disjoint cases; multiplication rule for sequential independent choices.
''',
  'Теория вероятностей': '''
Kolmogorov axioms (in elementary form): non-negativity, total probability 1, additivity for disjoint events.

Complement: P(Ā) = 1 − P(A).

Inclusion for two events: P(A∪B) = P(A) + P(B) − P(A∩B).

Independence: P(A∩B) = P(A)P(B) for independent A,B.

Expectation weights outcomes by probabilities.

• Binomial distribution counts successes in Bernoulli trials.
''',
};
