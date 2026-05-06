import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

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
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.local_bar, size: 24, color: Colors.white),
            title: Text(drinkName, style: const TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 24,
                    color: Colors.white.withValues(alpha: kTextOpacity),
                  ),
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
                // const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 24,
                    color: Colors.red.withValues(alpha: kTextOpacity),
                  ),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: kTextOpacity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
