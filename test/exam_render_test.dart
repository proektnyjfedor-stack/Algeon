import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_pilot/widgets/exam_html.dart';

void main() {
  testWidgets('All imported statements fit a phone and render their diagrams', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final catalog =
        jsonDecode(File('assets/exams/catalog.json').readAsStringSync()) as Map;
    for (final q in (catalog['questions'] as Map).values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [ExamHtml('${q['contextHtml']}${q['questionHtml']}')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: q['id'] as String);
    }
  });
}
