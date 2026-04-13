import 'package:flutter/material.dart';

Future<bool> showDeleteTrackingEntryDialog({
  required BuildContext context,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete entry'),
      content: const Text('Are you sure you want to delete this entry?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  return confirmed == true;
}
