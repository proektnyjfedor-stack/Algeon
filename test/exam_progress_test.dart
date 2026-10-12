import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:math_pilot/services/exam_progress.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/mock_exam_service.dart';
import 'package:math_pilot/services/backup_service.dart';

class DelayedStore extends InMemorySharedPreferencesStore {
  DelayedStore() : super.empty();
  Completer<void>? gate;
  bool failNext = false;
  final List<String> calls = [];
  final List<Object> values = [];
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    calls.add(key);
    values.add(value);
    final delay = gate;
    gate = null;
    if (delay != null) await delay.future;
    if (failNext) {
      failNext = false;
      return false;
    }
    return super.setValue(type, key, value);
  }
}

Map<String, dynamic> snapshot(String text) => {
  'index': 0,
  'records': {
    '0': {'input': text},
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DelayedStore store;
  setUp(() async {
    SharedPreferences.resetStatic();
    store = DelayedStore();
    SharedPreferencesStorePlatform.instance = store;
    await ProgressService.init();
    store.calls.clear();
    store.values.clear();
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  test(
    'A read waits for pending persistence instead of exposing a premature saved result',
    () async {
      final gate = Completer<void>();
      store.gate = gate;
      final write = ExamProgress.save('profile-1', snapshot('first'));
      await Future<void>.delayed(Duration.zero);
      var readFinished = false;
      final read = ExamProgress.read('profile-1').then((v) {
        readFinished = true;
        return v;
      });
      await Future<void>.delayed(Duration.zero);
      final premature = readFinished;
      gate.complete();
      await write;
      expect((await read)['records']['0']['input'], 'first');
      expect(premature, false);
    },
  );

  test(
    'Fast writes persist in order and capture mutable input before awaiting',
    () async {
      final gate = Completer<void>();
      store.gate = gate;
      final data = snapshot('first');
      final first = ExamProgress.save('profile-1', data);
      (data['records'] as Map)['0']['input'] = 'mutation';
      await Future<void>.delayed(Duration.zero);
      final second = ExamProgress.save('profile-1', snapshot('second'));
      await Future<void>.delayed(Duration.zero);
      final simultaneous = store.calls.length;
      gate.complete();
      await Future.wait([first, second]);
      final disk = await store.getAll();
      expect(
        jsonDecode(
          disk['flutter.exam_profile-1'] as String,
        )['records']['0']['input'],
        'second',
      );
      expect(simultaneous, 1);
      expect(
        jsonDecode(store.values.first as String)['records']['0']['input'],
        'first',
      );
    },
  );

  test(
    'Clearing progress waits for pending writes so they cannot reappear',
    () async {
      final gate = Completer<void>();
      store.gate = gate;
      final write = ExamProgress.save('profile-1', snapshot('old'));
      await Future<void>.delayed(Duration.zero);
      final clear = ExamProgress.clear();
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      await Future.wait([write, clear]);
      expect(
        (await store.getAll()).containsKey('flutter.exam_profile-1'),
        false,
      );
    },
  );

  test(
    'Restoring a backup waits for an old write before replacing progress',
    () async {
      final gate = Completer<void>();
      store.gate = gate;
      final write = ExamProgress.save('profile-1', snapshot('old'));
      await Future<void>.delayed(Duration.zero);
      var restored = false;
      final restore =
          BackupService.restore(
            jsonEncode({
              'format': 'algeon-progress',
              'version': 1,
              'data': {'exam_profile-1': jsonEncode(snapshot('restored'))},
            }),
          ).then((_) {
            restored = true;
          });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final premature = restored;
      gate.complete();
      await Future.wait([write, restore]);
      expect(premature, false);
      final disk = await store.getAll();
      expect(
        jsonDecode(
          disk['flutter.exam_profile-1'] as String,
        )['records']['0']['input'],
        'restored',
      );
    },
  );

  test(
    'Export waits for pending exam persistence before producing a backup',
    () async {
      final gate = Completer<void>();
      store.gate = gate;
      final write = ExamProgress.save('profile-1', snapshot('included'));
      await Future<void>.delayed(Duration.zero);
      var exported = false;
      final backup = BackupService.export().then((value) {
        exported = true;
        return value;
      });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final premature = exported;
      gate.complete();
      await write;
      final data = BackupService.validate(await backup);
      expect(
        jsonDecode(data['exam_profile-1'])['records']['0']['input'],
        'included',
      );
      expect(premature, false);
    },
  );

  test('Only successful local exam writes emit a persistence change', () async {
    var examChanges = 0, mockChanges = 0;
    void examChanged() => examChanges++;
    void mockChanged() => mockChanges++;
    ExamProgress.changes.addListener(examChanged);
    MockExamService.changes.addListener(mockChanged);
    try {
      store.failNext = true;
      await expectLater(
        ExamProgress.save('profile-1', snapshot('failed')),
        throwsStateError,
      );
      store.failNext = true;
      final mock = MockExamService.start('base-1', DateTime(2026, 10, 13));
      await expectLater(MockExamService.save(mock), throwsStateError);
      expect(examChanges, 0);
      expect(mockChanges, 0);
      await ExamProgress.save('profile-1', snapshot('saved'));
      await MockExamService.save(mock);
      expect(examChanges, 1);
      expect(mockChanges, 1);
      await ExamProgress.clear();
      await MockExamService.clear();
      expect(examChanges, 2);
      expect(mockChanges, 2);
    } finally {
      ExamProgress.changes.removeListener(examChanged);
      MockExamService.changes.removeListener(mockChanged);
    }
  });

  test(
    'A failed persistence does not block a subsequent successful write',
    () async {
      store.failNext = true;
      await expectLater(
        ExamProgress.save('profile-1', snapshot('failed')),
        throwsStateError,
      );
      await ExamProgress.save('profile-1', snapshot('recovered'));
      expect(
        (await ExamProgress.read('profile-1'))['records']['0']['input'],
        'recovered',
      );
    },
  );
}
