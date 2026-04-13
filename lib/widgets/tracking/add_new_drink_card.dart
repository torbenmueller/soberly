import 'package:flutter/material.dart';

class AddNewDrinkCard extends StatelessWidget {
  const AddNewDrinkCard({
    super.key,
    required this.drinkNameController,
    required this.alcoholController,
    required this.amountController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController drinkNameController;
  final TextEditingController alcoholController;
  final TextEditingController amountController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.local_bar, size: 22),
                SizedBox(width: 8),
                Text(
                  'Add New Drink',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: const Icon(Icons.add),
              label: Text(isSubmitting ? 'Saving...' : 'Add Drink'),
            ),
          ],
        ),
      ),
    );
  }
}
