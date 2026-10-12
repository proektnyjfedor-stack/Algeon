import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/data/exam_theory.dart';
import 'package:math_pilot/models/exam_answer.dart';
import 'package:math_pilot/services/exam_progress.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'package:math_pilot/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Thirty complete source-backed variants have local graphics and guides',
    () {
      final data =
          jsonDecode(File('assets/exams/catalog.json').readAsStringSync())
              as Map;
      final questions = data['questions'] as Map;
      final variants = data['variants'] as List;
      expect(variants.length, 30);
      expect(questions.length, 658);
      var placements = 0;
      for (final track in ['oge', 'base', 'profile']) {
        final group = variants.where((v) => v['track'] == track).toList();
        expect(group.length, 10);
        for (final v in group) {
          final ids = v['questionIds'] as List;
          expect(
            ids.length,
            track == 'oge'
                ? 25
                : track == 'base'
                ? 21
                : 20,
          );
          expect(ids.toSet().length, ids.length);
          placements += ids.length;
          for (var i = 0; i < ids.length; i++) {
            final q = questions[ids[i]] as Map;
            expect(q['slot'], i + 1);
            expect(q['track'], track);
            expect(q['sourceUrl'], contains('/problem?id=${q['sourceId']}'));
            expect(q['excerptWords'], lessThanOrEqualTo(200));
            expect(examGuide(track, i + 1).text.length, greaterThan(100));
            final html =
                '${q['questionHtml']}${q['contextHtml']}${q['solutionHtml']}';
            expect(html, isNot(contains('<script')));
            expect(html, isNot(contains('display:none')));
            for (final match in RegExp('src="([^"]+)"').allMatches(html)) {
              expect(match[1], startsWith('asset://assets/exams/images/'));
              expect(
                File(match[1]!.replaceFirst('asset://', '')).existsSync(),
                isTrue,
              );
            }
          }
        }
      }
      expect(placements, 660);
      expect(
        questions.values
            .where((q) => q['kind'] == 'short')
            .every((q) => ExamAnswer.canCheck(Map<String, dynamic>.from(q))),
        isTrue,
      );
    },
  );
  test(
    'Answer codes keep their order and source alternatives are accepted',
    () {
      expect(ExamAnswer.matches('32', '23|32'), isTrue);
      expect(ExamAnswer.matches('213', '123'), isFalse);
      expect(ExamAnswer.matches('0.50', '0,5'), isTrue);
      expect(ExamAnswer.matches('-0,20,2', '-0,20,2'), isTrue);
      expect(ExamAnswer.matches('0,2-0,2', '-0,20,2'), isFalse);
      expect(
        ExamAnswer.canCheck({'kind': 'detailed', 'answer': '12'}),
        isFalse,
      );
    },
  );
  test(
    'Exam progress survives backup and is removed by progress reset',
    () async {
      SharedPreferences.setMockInitialValues({});
      await ProgressService.init();
      final record = {
        'index': 7,
        'records': {
          '0': {'input': '42', 'status': 'correct'},
          '7': {'input': 'черновик'},
        },
      };
      await ExamProgress.save('profile-1', record);
      final backup = await BackupService.export();
      expect(BackupService.validate(backup)['exam_profile-1'], isA<String>());
      await ProgressService.resetProgress();
      expect(await ExamProgress.read('profile-1'), isEmpty);
      await BackupService.restore(backup);
      expect(await ExamProgress.read('profile-1'), record);
      expect(
        () => ExamProgress.validate('{"index":30,"records":{}}', 'exam_oge-1'),
        throwsFormatException,
      );
    },
  );
}
