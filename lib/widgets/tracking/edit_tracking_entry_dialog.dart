import 'package:flutter/material.dart';
import 'package:soberly/models/tracking_entry.dart';

Future<TrackingEntry?> showEditTrackingEntryDialog({
  required BuildContext context,
  required TrackingEntry entry,
}) async {
  final nameCtrl = TextEditingController(text: entry.drinkName);
  final alcoholCtrl = TextEditingController(
    text: entry.alcoholPercent.toString(),
  );
  final amountCtrl = TextEditingController(text: entry.amount.toString());
  final editFormKey = GlobalKey<FormState>();

  try {
    return await showDialog<TrackingEntry>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('Edit entry'),
        content: SingleChildScrollView(
          child: Form(
            key: editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
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
                  controller: alcoholCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Alcohol %',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim().replaceAll(',', '.') ?? '';
                    if (text.isEmpty) return 'Please enter alcohol percentage.';
                    final v = double.tryParse(text);
                    if (v == null || v < 0 || v > 100) {
                      return 'Enter a value between 0 and 100.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (ml)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Please enter an amount.';
                    final v = int.tryParse(text);
                    if (v == null || v <= 0) {
                      return 'Enter a whole number greater than 0.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!(editFormKey.currentState?.validate() ?? false)) {
                return;
              }
              final updatedEntry = TrackingEntry(
                id: entry.id,
                drinkName: nameCtrl.text.trim(),
                alcoholPercent: double.parse(
                  alcoholCtrl.text.trim().replaceAll(',', '.'),
                ),
                amount: int.parse(amountCtrl.text.trim()),
                createdAt: entry.createdAt,
              );
              Navigator.pop(ctx, updatedEntry);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  } finally {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameCtrl.dispose();
      alcoholCtrl.dispose();
      amountCtrl.dispose();
    });
  }
}
