import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/screens/formula_reference_screen.dart';
import 'package:math_pilot/screens/study_hub_screen.dart';
import 'package:math_pilot/services/learning_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/data/exam_catalog.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_layout_test.dart' show loadDesignFonts;

void main() {
  Future<void> capture(
    WidgetTester tester,
    GlobalKey boundary,
    String name,
  ) async {
    if (Platform.environment['ALGEON_CAPTURE_UPGRADE'] != '1') return;
    await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '/tmp/algeon-upgrade-$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('Formula search opens a labeled example on a narrow screen', (
    tester,
  ) async {
    await tester.runAsync(loadDesignFonts);
    tester.view.physicalSize = const Size(320, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Inter'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.2)),
            child: child!,
          ),
          home: const FormulaReferenceScreen(),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'пифагора');
    await tester.pumpAndSettle();
    expect(find.text('Теорема Пифагора'), findsOneWidget);
    await tester.tap(find.text('Теорема Пифагора'));
    await tester.pumpAndSettle();
    expect(find.textContaining('гипотенуза'), findsOneWidget);
    expect(find.text('Пример'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, boundary, 'formula');
    for (final entry in formulaReference) {
      await tester.enterText(find.byType(TextField), entry.title);
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.title).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: entry.title);
    }

    await tester.enterText(find.byType(TextField), 'неттакойформулы');
    await tester.pumpAndSettle();
    expect(find.textContaining('Ничего не найдено'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'Plan settings save topics and time, report opens without sharing automatically',
    (tester) async {
      await tester.runAsync(loadDesignFonts);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final history = LearningService.instance;
      await history.init();
      await ProgressService.init();
      await tester.runAsync(ExamCatalog.load);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Inter'),
            home: const StudyHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Создать план'));
      await tester.tap(find.text('Создать план'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      // Settings include duration and allow an unconstrained all-topics selection.
      await tester.scrollUntilVisible(
        find.text('~15 мин'),
        150,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('~15 мин'));
      await capture(tester, boundary, 'settings');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      expect(history.plan['minutes'], 15);
      expect(history.plan['daily'], 15);
      expect(history.plan['topics'], isEmpty);
      await tester.pumpAndSettle();
      await capture(tester, boundary, 'plan');
      final task = getTaskById('g5_pct_4')!;
      await history.record(
        attemptId: 'ui-report',
        id: task.id,
        topic: LearningService.taskTopic(task),
        ref: LearningService.taskRef(task),
        correct: false,
        input: 'private',
      );
      await tester.tap(find.byTooltip('Экспорт результатов'));
      await tester.pumpAndSettle();
      expect(find.text('Отчёт о подготовке'), findsOneWidget);
      expect(find.text('Копировать'), findsOneWidget);
      expect(
        tester.widget<SelectableText>(find.byType(SelectableText)).data,
        contains('Проценты'),
      );
      expect(
        tester.widget<SelectableText>(find.byType(SelectableText)).data,
        isNot(contains('private')),
      );
      await tester.tap(find.text('Закрыть'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    },
  );
}
