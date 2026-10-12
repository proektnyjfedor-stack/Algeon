import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/services/cloud_progress_store.dart';
import 'package:math_pilot/services/cloud_sync_service.dart';

String backup(int grade) => jsonEncode({
  'format': 'algeon-progress',
  'version': 1,
  'data': {'current_grade': grade},
});
CloudProgressCopy copy(int grade, int revision) =>
    CloudProgressCopy(payload: backup(grade), revision: revision);

class MemoryStore implements CloudProgressStore {
  final data = <String, CloudProgressCopy>{};
  final writes = <String>[];
  Future<CloudProgressCopy?> Function(String)? onRead;
  Future<int> Function(String, String, int)? onWrite;
  @override
  Future<CloudProgressCopy?> read(String uid) async =>
      onRead != null ? await onRead!(uid) : data[uid];
  @override
  Future<int> write(
    String uid,
    String payload, {
    required int expectedRevision,
  }) async {
    writes.add(uid);
    if (onWrite != null) return onWrite!(uid, payload, expectedRevision);
    if ((data[uid]?.revision ?? 0) != expectedRevision) {
      throw StateError('Conflict');
    }
    final next = expectedRevision + 1;
    data[uid] = CloudProgressCopy(payload: payload, revision: next);
    return next;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryStore store;
  late CloudSyncService sync;
  late String? owner;
  late String local;
  Future<void> Function(String)? restoring;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = MemoryStore();
    owner = 'a';
    local = backup(5);
    restoring = null;
    sync = CloudSyncService.forTesting(
      store: store,
      currentUid: () => owner,
      export: () async => local,
      restore: (payload) async {
        if (restoring != null) await restoring!(payload);
        local = payload;
      },
    );
  });
  tearDown(() => sync.dispose());
  test('A late connection result cannot change the next account', () async {
    final delayed = Completer<CloudProgressCopy?>();
    store.data['b'] = copy(8, 4);
    store.onRead = (uid) async =>
        uid == 'a' ? await delayed.future : store.data[uid];
    final first = sync.connect();
    await Future<void>.delayed(Duration.zero);
    owner = 'b';
    await sync.connect();
    delayed.complete(copy(3, 2));
    await first;
    expect(sync.uid, 'b');
    expect(sync.revision, 4);
    expect(sync.remoteSummary, contains('8 класс'));
    expect(sync.busy, isFalse);
  });
  test('A late failure cannot disable the new account', () async {
    final delayed = Completer<CloudProgressCopy?>();
    store.onRead = (uid) async => uid == 'a' ? await delayed.future : null;
    final first = sync.connect();
    await Future<void>.delayed(Duration.zero);
    owner = 'b';
    await sync.connect();
    delayed.completeError(StateError('Offline'));
    await first;
    expect(sync.uid, 'b');
    expect(sync.needsChoice, isFalse);
    expect(sync.busy, isFalse);
  });
  test(
    'A late upload changes neither the next account nor its metadata',
    () async {
      await sync.connect();
      final delayed = Completer<int>();
      store.onWrite = (_, _, _) => delayed.future;
      final first = sync.upload();
      await Future<void>.delayed(Duration.zero);
      owner = 'b';
      store.data['b'] = copy(8, 4);
      await sync.connect();
      delayed.complete(1);
      await first;
      expect(sync.uid, 'b');
      expect(sync.revision, 4);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('cloud_revision_b'), isNull);
    },
  );
  testWidgets('Changes during an upload are sent in a subsequent write', (
    tester,
  ) async {
    await sync.connect();
    final delayed = Completer<int>();
    store.onWrite = (uid, payload, expected) async {
      if (store.writes.length == 1) return delayed.future;
      store.data[uid] = CloudProgressCopy(
        payload: payload,
        revision: expected + 1,
      );
      return expected + 1;
    };
    final first = sync.upload();
    await tester.pump();
    local = backup(9);
    sync.schedule();
    await tester.pump(const Duration(seconds: 4));
    delayed.complete(1);
    await first;
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(store.writes, ['a', 'a']);
    expect(store.data['a']!.payload, backup(9));
  });
  test('A remote change after inspection cannot be overwritten', () async {
    store.data['a'] = copy(7, 2);
    await sync.connect();
    store.data['a'] = copy(8, 3);
    await sync.upload(replace: true);
    expect(store.data['a']!.payload, backup(8));
    expect(sync.needsChoice, isTrue);
  });
  test(
    'A different local owner requires a choice even with an empty cloud',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cloud_local_owner', 'someone-else');
      await sync.connect();
      expect(sync.hasRemote, isFalse);
      expect(sync.needsChoice, isTrue);
      await sync.upload();
      expect(store.writes, isEmpty);
    },
  );
  test('Invalid remote backup is refused before any local restore', () async {
    store.data['a'] = const CloudProgressCopy(payload: 'invalid', revision: 1);
    await sync.connect();
    await sync.download();
    expect(local, backup(5));
    expect(sync.needsChoice, isTrue);
  });
  test(
    'Failed restore retains a recovery copy and blocks automatic upload',
    () async {
      store.data['a'] = copy(9, 2);
      await sync.connect();
      restoring = (_) async => throw StateError('Storage failed');
      await sync.download();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cloud_local_recovery'), backup(5));
      expect(local, backup(5));
      expect(sync.needsChoice, isTrue);
      expect(sync.message, contains('восстановления'));
      await sync.upload();
      expect(store.writes, isEmpty);
    },
  );
  test(
    'Switching accounts during restore preserves the restored copy ownership',
    () async {
      store.data['a'] = copy(9, 2);
      await sync.connect();
      final delayed = Completer<void>(), started = Completer<void>();
      restoring = (_) async {
        started.complete();
        await delayed.future;
      };
      final download = sync.download();
      await started.future;
      owner = 'b';
      final connecting = sync.connect();
      delayed.complete();
      await download;
      await connecting;
      final prefs = await SharedPreferences.getInstance();
      expect(local, backup(9));
      expect(prefs.getString('cloud_local_owner'), 'a');
      expect(sync.uid, 'b');
      expect(sync.needsChoice, isTrue);
    },
  );
  test('Signing out discards an outstanding connection result', () async {
    final delayed = Completer<CloudProgressCopy?>();
    store.onRead = (_) async => delayed.future;
    final first = sync.connect();
    await Future<void>.delayed(Duration.zero);
    owner = null;
    await sync.connect();
    delayed.complete(copy(9, 4));
    await first;
    expect(sync.uid, isNull);
    expect(sync.busy, isFalse);
    expect(sync.hasRemote, isFalse);
  });
}
