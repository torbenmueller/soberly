import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomDrink {
  final String? id;
  final int? displayOrder;
  final String name;
  final double alcoholPercent;
  final int amountMl;
  final String iconKey;
  final int colorValue;
  final Timestamp? createdAt;

  const CustomDrink({
    this.id,
    this.displayOrder,
    required this.name,
    required this.alcoholPercent,
    required this.amountMl,
    required this.iconKey,
    required this.colorValue,
    this.createdAt,
  });

  CustomDrink copyWith({
    String? id,
    int? displayOrder,
    String? name,
    double? alcoholPercent,
    int? amountMl,
    String? iconKey,
    int? colorValue,
    Timestamp? createdAt,
  }) {
    return CustomDrink(
      id: id ?? this.id,
      displayOrder: displayOrder ?? this.displayOrder,
      name: name ?? this.name,
      alcoholPercent: alcoholPercent ?? this.alcoholPercent,
      amountMl: amountMl ?? this.amountMl,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomDrink.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CustomDrink.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory CustomDrink.fromMap(Map<String, dynamic> data, {String? id}) {
    return CustomDrink(
      id: id,
      displayOrder: (data['displayOrder'] as num?)?.toInt(),
      name: (data['name'] as String? ?? '').trim(),
      alcoholPercent: (data['alcoholPercent'] as num?)?.toDouble() ?? 0,
      amountMl: (data['amountMl'] as num?)?.toInt() ?? 0,
      iconKey: (data['iconKey'] as String? ?? customDrinkIconOptions.first.key)
          .trim(),
      colorValue:
          (data['colorValue'] as num?)?.toInt() ??
          customDrinkColorOptions.first.color.toARGB32(),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'name': name,
      'displayOrder': displayOrder,
      'alcoholPercent': alcoholPercent,
      'amountMl': amountMl,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'name': name,
      'displayOrder': displayOrder,
      'alcoholPercent': alcoholPercent,
      'amountMl': amountMl,
      'iconKey': iconKey,
      'colorValue': colorValue,
    };
  }
}

class CustomDrinkIconOption {
  final String key;
  final String label;
  final IconData icon;

  const CustomDrinkIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class CustomDrinkColorOption {
  final String key;
  final String label;
  final Color color;

  const CustomDrinkColorOption({
    required this.key,
    required this.label,
    required this.color,
  });
}

const customDrinkIconOptions = <CustomDrinkIconOption>[
  CustomDrinkIconOption(key: 'beer', label: 'Beer', icon: Icons.sports_bar),
  CustomDrinkIconOption(key: 'wine', label: 'Wine', icon: Icons.wine_bar),
  CustomDrinkIconOption(key: 'shots', label: 'Shots', icon: Icons.local_bar),
  CustomDrinkIconOption(key: 'cocktail', label: 'Cocktail', icon: Icons.liquor),
  CustomDrinkIconOption(key: 'drink', label: 'Drink', icon: Icons.local_drink),
];

const customDrinkColorOptions = <CustomDrinkColorOption>[
  CustomDrinkColorOption(key: 'blue', label: 'Blue', color: Color(0xff72DBF2)),
  CustomDrinkColorOption(
    key: 'green',
    label: 'Green',
    color: Color(0xff5AC8A8),
  ),
  CustomDrinkColorOption(
    key: 'purple',
    label: 'Purple',
    color: Color(0xffA78BFA),
  ),
  CustomDrinkColorOption(
    key: 'orange',
    label: 'Orange',
    color: Color(0xffF59E0B),
  ),
  CustomDrinkColorOption(key: 'pink', label: 'Pink', color: Color(0xffF472B6)),
  CustomDrinkColorOption(key: 'red', label: 'Red', color: Color(0xffFB7185)),
];

CustomDrinkIconOption customDrinkIconOptionFromKey(String key) {
  return customDrinkIconOptions.firstWhere(
    (option) => option.key == key,
    orElse: () => customDrinkIconOptions.first,
  );
}

CustomDrinkColorOption customDrinkColorOptionFromValue(int value) {
  return customDrinkColorOptions.firstWhere(
    (option) => option.color.toARGB32() == value,
    orElse: () => customDrinkColorOptions.first,
  );
}
