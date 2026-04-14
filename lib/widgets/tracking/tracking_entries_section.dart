import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/widgets/tracking/tracking_entry_tile.dart';

class TrackingEntriesSection extends StatelessWidget {
  final Stream<List<TrackingEntry>> stream;
  final ValueChanged<TrackingEntry> onEdit;
  final ValueChanged<TrackingEntry> onDelete;

  const TrackingEntriesSection({
    super.key,
    required this.stream,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Saving timestamp...';
    }

    final localTime = timestamp.toDate().toLocal();
    return '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} '
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your entries',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<TrackingEntry>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Could not load entries.'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = snapshot.data ?? const <TrackingEntry>[];
              if (entries.isEmpty) {
                return const Center(
                  child: Text('No entries yet. Add your first one above.'),
                );
              }

              return ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final drinkName = entry.drinkName.isEmpty
                      ? '-'
                      : entry.drinkName;
                  final pureAlcohol =
                      entry.amount * (entry.alcoholPercent / 100) * 0.789;
                  final subtitle =
                      '${entry.alcoholPercent.toStringAsFixed(1)}%  •  ${entry.amount}ml  • ${pureAlcohol.toStringAsFixed(1)}g'
                      '\n${_formatTimestamp(entry.createdAt)}';

                  return TrackingEntryTile(
                    drinkName: drinkName,
                    subtitle: subtitle,
                    onEdit: () => onEdit(entry),
                    onDelete: entry.id == null ? null : () => onDelete(entry),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
