import 'package:flutter/material.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/models/custom_drink.dart';

class AddNewDrink extends StatelessWidget {
  const AddNewDrink({
    super.key,
    required this.drinkNameController,
    required this.alcoholController,
    required this.amountController,
    required this.isSubmitting,
    required this.customDrinks,
    required this.onSelectCustomDrink,
    required this.onSubmit,
  });

  final TextEditingController drinkNameController;
  final TextEditingController alcoholController;
  final TextEditingController amountController;
  final bool isSubmitting;
  final List<CustomDrink> customDrinks;
  final ValueChanged<CustomDrink> onSelectCustomDrink;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: kEdgeInsetsAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Text(
                  'Add New Drink',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customDrinks.isNotEmpty) ...[
              Text(
                'Quick add from custom drinks',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: kTextOpacity),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final drink in customDrinks)
                    (() {
                      final drinkColor = Color(drink.colorValue);
                      final chipBackground = Color.alphaBlend(
                        drinkColor.withValues(alpha: 0.12),
                        Colors.white,
                      );
                      return ActionChip(
                        color: WidgetStatePropertyAll<Color>(chipBackground),
                        side: BorderSide(
                          color: drinkColor.withValues(alpha: 0.4),
                        ),
                        avatar: Icon(
                          customDrinkIconOptionFromKey(drink.iconKey).icon,
                          size: 20,
                          color: drinkColor,
                        ),
                        label: Text(drink.name),
                        onPressed: () => onSelectCustomDrink(drink),
                      );
                    })(),
                ],
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: drinkNameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Drink Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a drink name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: alcoholController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Alcohol %',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim().replaceAll(',', '.') ?? '';
                if (text.isEmpty) {
                  return 'Please enter alcohol percentage.';
                }
                final v = double.tryParse(text);
                if (v == null || v < 0 || v > 100) {
                  return 'Enter a value between 0 and 100.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (ml)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Please enter an amount.';
                }
                final v = int.tryParse(text);
                if (v == null || v <= 0) {
                  return 'Enter a whole number greater than 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppButton(
              title: isSubmitting ? 'Saving...' : 'Add Drink',
              color: kPrimaryColor,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
