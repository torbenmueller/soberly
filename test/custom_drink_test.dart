import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soberly/models/custom_drink.dart';

void main() {
  group('CustomDrink', () {
    test('round-trips map data and preserves icon/color selection', () {
      final drink = CustomDrink(
        name: 'Beer',
        alcoholPercent: 5,
        amountMl: 500,
        iconKey: 'beer',
        colorValue: customDrinkColorOptions[1].color.toARGB32(),
      );

      final map = drink.toCreateMap();

      expect(map['name'], 'Beer');
      expect(map['alcoholPercent'], 5.0);
      expect(map['amountMl'], 500);
      expect(map['iconKey'], 'beer');
      expect(map['colorValue'], customDrinkColorOptions[1].color.toARGB32());
      expect(map['createdAt'], isA<FieldValue>());

      final restored = CustomDrink.fromMap({
        'name': map['name'],
        'alcoholPercent': map['alcoholPercent'],
        'amountMl': map['amountMl'],
        'iconKey': map['iconKey'],
        'colorValue': map['colorValue'],
      });

      expect(restored.name, 'Beer');
      expect(restored.alcoholPercent, 5);
      expect(restored.amountMl, 500);
      expect(restored.iconKey, 'beer');
      expect(restored.colorValue, customDrinkColorOptions[1].color.toARGB32());
    });

    test('falls back to default icon and color for unknown values', () {
      final drink = CustomDrink.fromMap({
        'name': 'Mystery drink',
        'alcoholPercent': 12,
        'amountMl': 100,
        'iconKey': 'unknown',
        'colorValue': 123,
      });

      expect(drink.iconKey, 'unknown');
      expect(customDrinkIconOptionFromKey(drink.iconKey).key, 'beer');
      expect(
        customDrinkColorOptionFromValue(drink.colorValue).color.toARGB32(),
        customDrinkColorOptions.first.color.toARGB32(),
      );
    });
  });
}
