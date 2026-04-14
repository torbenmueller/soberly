import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soberly/models/sex_for_calculation.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<SexForCalculation?> getSexForCalculation({required String uid}) async {
    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    return SexForCalculation.fromValue(data?['sexForCalculation'] as String?);
  }

  Future<bool> hasSexForCalculation({required String uid}) async {
    final value = await getSexForCalculation(uid: uid);
    return value != null;
  }

  Future<void> saveSexForCalculation({
    required String uid,
    required SexForCalculation sex,
  }) {
    return _userDoc(uid).set({
      'sexForCalculation': sex.value,
      'profileUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
