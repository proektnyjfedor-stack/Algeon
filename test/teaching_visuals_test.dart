import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/widgets/topic_visual.dart';
import 'package:math_pilot/theme/app_theme.dart';
import 'package:math_pilot/services/task_teaching.dart';
import 'package:math_pilot/models/task.dart';

void main() {
  test('Linear solutions are exact and nonlinear expressions are excluded', () {
    Task task(String question) => Task(
      id: 'test',
      grade: 7,
      topic: 'Уравнения',
      question: question,
      type: TaskType.textInput,
      answer: '',
    );
    expect(
      TaskTeaching.linearCalculation(
        task('Решите: 2x + 6 = 14'),
      )!.value.toString(),
      '4',
    );
    expect(
      TaskTeaching.linearCalculation(
        task('x ÷ 7 = 8. Найди x.'),
      )!.value.toString(),
      '56',
    );
    expect(
      TaskTeaching.linearCalculation(
        task('14 - x = 6. Найди x'),
      )!.value.toString(),
      '8',
    );
    expect(
      TaskTeaching.linearCalculation(task('x × x = 64. Найди x.')),
      isNull,
    );
    expect(
      TaskTeaching.linearCalculation(task('72 ÷ x = 8. Найди x.')),
      isNull,
    );
    expect(TaskTeaching.linearCalculation(task('y = x + 1')), isNull);
  });
  testWidgets(
    'Interactive teaching diagrams fit phone and desktop in both themes',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      for (final width in [320.0, 900.0]) {
        tester.view.physicalSize = Size(width, 760);
        for (final dark in [true, false]) {
          for (final topic in [
            'Дроби',
            'Тригонометрические функции',
            'Линейная функция',
            'Функция y=ax²',
            'Теорема Пифагора',
          ]) {
            await tester.pumpWidget(
              MaterialApp(
                theme: dark ? buildDarkTheme() : buildLightTheme(),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: TopicVisual(
                      key: ValueKey('$topic$dark$width'),
                      topic: topic,
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final sliders = find.byType(Slider);
            if (sliders.evaluate().isNotEmpty) {
              await tester.drag(sliders, const Offset(60, 0));
              await tester.pumpAndSettle();
            }
            expect(
              tester.takeException(),
              isNull,
              reason: '$topic $width $dark',
            );
          }
        }
      }
    },
  );
}
