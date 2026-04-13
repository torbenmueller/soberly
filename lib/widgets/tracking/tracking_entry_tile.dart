import 'package:flutter/material.dart';

class TrackingEntryTile extends StatelessWidget {
  const TrackingEntryTile({
    super.key,
    required this.drinkName,
    required this.subtitle,
    required this.onEdit,
    this.onDelete,
  });

  final String drinkName;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_bar),
        title: Text(drinkName),
        subtitle: Text(subtitle),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
