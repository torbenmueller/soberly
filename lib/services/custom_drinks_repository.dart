import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soberly/models/custom_drink.dart';

class CustomDrinksRepository {
  CustomDrinksRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore.collection('users').doc(uid).collection('custom_drinks');
  }

  Stream<List<CustomDrink>> streamCustomDrinks({required String uid}) {
    return _collection(uid).snapshots().map((snapshot) {
      final drinks = snapshot.docs
          .map((doc) => CustomDrink.fromDocument(doc))
          .toList();

      drinks.sort((a, b) {
        final aOrder = a.displayOrder;
        final bOrder = b.displayOrder;
        if (aOrder != null && bOrder != null) {
          final cmp = aOrder.compareTo(bOrder);
          if (cmp != 0) return cmp;
        } else if (aOrder != null) {
          return -1;
        } else if (bOrder != null) {
          return 1;
        }

        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return aTime.compareTo(bTime);
      });

      return drinks;
    });
  }

  Future<void> addCustomDrink({
    required String uid,
    required CustomDrink drink,
  }) {
    return _collection(uid).add(drink.toCreateMap());
  }

  Future<void> updateCustomDrink({
    required String uid,
    required CustomDrink drink,
  }) {
    final id = drink.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('CustomDrink id is required for update.');
    }
    return _collection(uid).doc(id).update(drink.toUpdateMap());
  }

  Future<void> deleteCustomDrink({
    required String uid,
    required String drinkId,
  }) {
    return _collection(uid).doc(drinkId).delete();
  }

  Future<void> updateDisplayOrder({
    required String uid,
    required List<CustomDrink> drinks,
  }) async {
    final batch = _firestore.batch();
    for (var index = 0; index < drinks.length; index++) {
      final id = drinks[index].id;
      if (id == null || id.isEmpty) continue;
      batch.update(_collection(uid).doc(id), <String, dynamic>{
        'displayOrder': index,
      });
    }
    await batch.commit();
  }
}
