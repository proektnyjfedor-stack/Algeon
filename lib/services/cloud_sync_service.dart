library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'progress_service.dart';

class CloudSyncService {
  CloudSyncService._();

  static StreamSubscription<User?>? _authSub;
  static Timer? _syncTimer;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> initAndBind() async {
    _authSub ??= AuthService.authStateChanges().listen((user) async {
      if (user == null) return;
      await syncOnLogin(user.uid);
    });
    _syncTimer ??= Timer.periodic(
      const Duration(seconds: 25),
      (_) => syncCurrentUserProgress(),
    );
  }

  static Future<void> syncOnLogin(String uid) async {
    try {
      final ref = _db.collection('users').doc(uid);
      final snap = await ref.get();
      final local = ProgressService.exportForCloud();

      if (!snap.exists) {
        await ref.set({
          'progress': local,
          'updatedAt': FieldValue.serverTimestamp(),
          'schemaVersion': 1,
        });
        return;
      }

      final remoteData = snap.data() ?? <String, dynamic>{};
      final remoteProgress =
          (remoteData['progress'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final merged = _mergeProgress(local, remoteProgress);

      await ProgressService.importFromCloud(merged);
      await ref.set({
        'progress': merged,
        'updatedAt': FieldValue.serverTimestamp(),
        'schemaVersion': 1,
      }, SetOptions(merge: true));
    } catch (e, st) {
      debugPrint('CloudSyncService.syncOnLogin: $e\n$st');
    }
  }

  static Future<void> syncCurrentUserProgress() async {
    final user = AuthService.currentUser();
    if (user == null) return;
    try {
      final ref = _db.collection('users').doc(user.uid);
      await ref.set({
        'progress': ProgressService.exportForCloud(),
        'updatedAt': FieldValue.serverTimestamp(),
        'schemaVersion': 1,
      }, SetOptions(merge: true));
    } catch (e, st) {
      debugPrint('CloudSyncService.syncCurrentUserProgress: $e\n$st');
    }
  }

  static Map<String, dynamic> _mergeProgress(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = <String, dynamic>{...remote, ...local};

    final localSolved = (local['solved_tasks'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toSet();
    final remoteSolved = (remote['solved_tasks'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toSet();
    merged['solved_tasks'] = localSolved.union(remoteSolved).toList(growable: false);

    int maxInt(String key) {
      final l = local[key];
      final r = remote[key];
      final lv = l is int ? l : int.tryParse('${l ?? 0}') ?? 0;
      final rv = r is int ? r : int.tryParse('${r ?? 0}') ?? 0;
      return lv > rv ? lv : rv;
    }

    merged['total_attempts'] = maxInt('total_attempts');
    merged['correct_attempts'] = maxInt('correct_attempts');
    merged['streak_days'] = maxInt('streak_days');
    merged['coins_balance'] = maxInt('coins_balance');
    merged['today_completed'] = maxInt('today_completed');

    final localName = (local['user_name'] as String?)?.trim() ?? '';
    final remoteName = (remote['user_name'] as String?)?.trim() ?? '';
    merged['user_name'] = localName.isNotEmpty ? localName : remoteName;

    return merged;
  }
}
