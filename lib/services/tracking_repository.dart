import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soberly/models/tracking_entry.dart';

class TrackingRepository {
  TrackingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tracking_entries');
  }

  Stream<List<TrackingEntry>> streamEntries({required String uid}) {
    return _entriesCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TrackingEntry.fromDocument(doc))
              .toList(),
        );
  }

  Future<void> addEntry({required String uid, required TrackingEntry entry}) {
    return _entriesCollection(uid).add(entry.toCreateMap());
  }

  Future<void> updateEntry({
    required String uid,
    required TrackingEntry entry,
  }) {
    final id = entry.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('TrackingEntry id is required for update.');
    }
    return _entriesCollection(uid).doc(id).update(entry.toUpdateMap());
  }

  Future<void> deleteEntry({required String uid, required String entryId}) {
    return _entriesCollection(uid).doc(entryId).delete();
  }
}
