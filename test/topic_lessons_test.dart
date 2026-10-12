import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/flutter_math.dart';
// ignore: implementation_imports
import 'package:flutter_math_fork/src/parser/tex/parser.dart';
import 'package:math_pilot/data/tasks_data.dart';
import 'package:math_pilot/data/topic_lessons.dart';
import 'package:math_pilot/widgets/topic_lesson_card.dart';
import 'package:math_pilot/widgets/math_text.dart';
import 'package:math_pilot/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Every catalog topic has an authored lesson with valid mathematical notation',
    () {
      final topics = getAllTasks().map((t) => t.topic).toSet();
      expect(topics.length, 116);
      for (final topic in topics) {
        final lesson = topicLessons[topic];
        expect(lesson, isNotNull, reason: topic);
        expect(lesson!.steps.length, greaterThanOrEqualTo(3), reason: topic);
        expect(lesson.meaning.length, greaterThan(60), reason: topic);
        expect(lesson.pitfall, isNotEmpty, reason: topic);
        for (final text in [
          lesson.meaning,
          lesson.example,
          ...lesson.steps,
          lesson.pitfall,
        ]) {
          for (final part in MathNotation.parts(text).where((p) => p.math)) {
            expect(
              () => TexParser(part.content, const TexParserSettings()).parse(),
              returnsNormally,
              reason: '$topic: ${part.content}',
            );
          }
        }
      }
      expect(topicLessons['Тригонометрия']!.visual, 'trigTriangle');
      expect(topicLessons['Тригонометрические функции']!.visual, 'unitCircle');
      expect(topicLessons['Теорема Пифагора']!.steps.last, contains('5'));
    },
  );
  testWidgets(
    'All lesson diagrams and explanations render at narrow and wide sizes in both themes',
    (tester) async {
      await tester.runAsync(() async {
        final manifest =
            jsonDecode(await rootBundle.loadString('FontManifest.json'))
                as List;
        for (final entry in manifest) {
          final loader = FontLoader(entry['family'] as String);
          for (final font in entry['fonts'] as List) {
            loader.addFont(rootBundle.load(font['asset'] as String));
          }
          await loader.load();
        }
        final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
        if (await font.exists()) {
          await (FontLoader('Inter')..addFont(
                Future.value(ByteData.sublistView(await font.readAsBytes())),
              ))
              .load();
        }
      });
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final width in [320.0, 600.0]) {
        tester.view.physicalSize = Size(width, 1500);
        tester.platformDispatcher.textScaleFactorTestValue = width == 320
            ? 1.4
            : 1;
        for (final dark in [true, false]) {
          for (final entry in topicLessons.entries) {
            final key = GlobalKey();
            await tester.pumpWidget(
              MaterialApp(
                theme: dark ? buildDarkTheme() : buildLightTheme(),
                home: Scaffold(
                  body: RepaintBoundary(
                    key: key,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: TopicLessonCard(lesson: entry.value),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.text(entry.value.title), findsOneWidget);
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key} $width $dark',
            );
            if (Platform.environment['ALGEON_CAPTURE_LESSONS'] == '1' &&
                width == 600 &&
                dark &&
                [
                  'Тригонометрия',
                  'Тригонометрические функции',
                  'Обыкновенные дроби',
                  'Цилиндр и конус',
                  'Квадратные уравнения',
                ].contains(entry.key)) {
              await tester.runAsync(() async {
                final boundary =
                    key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary;
                final snapshot = await boundary.toImage();
                final bytes = await snapshot.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                await File(
                  '/tmp/algeon-lesson-${entry.value.visual}.png',
                ).writeAsBytes(bytes!.buffer.asUint8List());
                snapshot.dispose();
              });
            }
          }
        }
      }
    },
  );
}
