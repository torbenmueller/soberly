import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingEntry {
  final String? id;
  final String drinkName;
  final double alcoholPercent;
  final int amount;
  final Timestamp? createdAt;

  const TrackingEntry({
    this.id,
    required this.drinkName,
    required this.alcoholPercent,
    required this.amount,
    this.createdAt,
  });

  factory TrackingEntry.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return TrackingEntry.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory TrackingEntry.fromMap(Map<String, dynamic> data, {String? id}) {
    return TrackingEntry(
      id: id,
      drinkName: (data['drinkName'] as String? ?? '').trim(),
      alcoholPercent: (data['alcoholPercent'] as num?)?.toDouble() ?? 0,
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'drinkName': drinkName,
      'alcoholPercent': alcoholPercent,
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'drinkName': drinkName,
      'alcoholPercent': alcoholPercent,
      'amount': amount,
    };
  }
}
