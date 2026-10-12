import 'package:cloud_firestore/cloud_firestore.dart';

/// A snapshot and revision belong to one account. Writes compare the revision
/// inside a transaction so another device's work cannot be silently replaced.
class CloudProgressCopy {
  const CloudProgressCopy({
    required this.payload,
    required this.revision,
    this.updatedAt,
  });
  final String payload;
  final int revision;
  final DateTime? updatedAt;
}

abstract interface class CloudProgressStore {
  Future<CloudProgressCopy?> read(String uid);
  Future<int> write(
    String uid,
    String payload, {
    required int expectedRevision,
  });
}

class FirebaseProgressStore implements CloudProgressStore {
  DocumentReference<Map<String, dynamic>> _document(String uid) =>
      FirebaseFirestore.instance.collection('progress').doc(uid);
  @override
  Future<CloudProgressCopy?> read(String uid) async {
    final snapshot = await _document(uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20));
    final data = snapshot.data();
    if (data == null) return null;
    if (data['payload'] is! String ||
        data['revision'] is! int ||
        (data['revision'] as int) <= 0) {
      throw const FormatException('Invalid cloud progress');
    }
    return CloudProgressCopy(
      payload: data['payload'] as String,
      revision: data['revision'] as int,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<int> write(
    String uid,
    String payload, {
    required int expectedRevision,
  }) {
    final document = _document(uid);
    return FirebaseFirestore.instance.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(document);
      final revision = snapshot.data()?['revision'] as int? ?? 0;
      if (revision != expectedRevision) {
        throw StateError('Cloud revision changed');
      }
      transaction.set(document, {
        'payload': payload,
        'revision': revision + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return revision + 1;
    });
  }
}
