import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/models/task.dart';
import 'package:math_pilot/screens/task_screen.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/study_session_service.dart';
import 'package:math_pilot/services/sound_service.dart';
import 'package:math_pilot/theme/app_theme.dart';
import 'package:math_pilot/widgets/math_text.dart';
import 'package:math_pilot/widgets/math_keyboard.dart';
import 'package:math_pilot/widgets/formula_answer_field.dart';

void main() {
  testWidgets(
    'Every catalog task renders with the appropriate answer controls',
    (tester) async {
      SharedPreferences.setMockInitialValues({'sound_enabled': false});
      await StudySessionService.init();
      await SoundService.init();
      await LanguageService.instance.init();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final task in getAllTasks()) {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: LanguageService.instance,
            child: MaterialApp(
              theme: buildDarkTheme(),
              home: TaskScreen(
                key: ValueKey(task.id),
                tasks: [task],
                topicName: task.topic,
                restart: true,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull, reason: task.id);
        if (task.type == TaskType.multipleChoice) {
          for (final option in task.options!) {
            expect(
              find.byKey(ValueKey('answer_${task.id}_$option')),
              findsOneWidget,
              reason: task.id,
            );
          }
          expect(find.byType(MathInputToolbar), findsNothing, reason: task.id);
          expect(find.byType(MathKeyboard), findsNothing, reason: task.id);
          expect(
            find.byWidgetPredicate(
              (w) => w is MathText && w.text == 'Введи ответ',
            ),
            findsNothing,
            reason: task.id,
          );
        } else {
          expect(
            find.text('Инструменты ввода'),
            findsOneWidget,
            reason: task.id,
          );
          expect(find.byType(MathInputToolbar), findsNothing, reason: task.id);
        }
        if (task.id == 'g10_trig_1') {
          expect(
            find.byWidgetPredicate(
              (w) => w is MathText && w.text == task.question,
            ),
            findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (w) => w is MathText && w.text.trim() == 'y =',
            ),
            findsNothing,
          );
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
