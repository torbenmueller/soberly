import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/services/tracking_repository.dart';
import 'package:soberly/widgets/tracking/edit_tracking_entry_dialog.dart';

class TrackingScreen extends StatefulWidget {
  static const String id = 'tracking_screen';
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _auth = FirebaseAuth.instance;
  final _trackingRepository = TrackingRepository();
  final _formKey = GlobalKey<FormState>();
  final _drinkNameController = TextEditingController();
  final _alcoholController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _redirectIfUnauthenticated();
  }

  void _redirectIfUnauthenticated() {
    if (_auth.currentUser != null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, LoginScreen.id, arguments: true);
    });
  }

  @override
  void dispose() {
    _drinkNameController.dispose();
    _alcoholController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<bool> addTrackingEntry({
    required String drinkName,
    required double alcoholPercent,
    required int amount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      _redirectIfUnauthenticated();
      return false;
    }

    final entry = TrackingEntry(
      drinkName: drinkName,
      alcoholPercent: alcoholPercent,
      amount: amount,
    );

    try {
      await _trackingRepository.addEntry(uid: user.uid, entry: entry);
      if (!mounted) {
        return true;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Drink entry saved.')));
      return true;
    } on FirebaseException catch (e) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save entry: ${e.message ?? e.code}')),
      );
      return false;
    }
  }

  Future<void> _submitTrackingEntry() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final drinkName = _drinkNameController.text.trim();
    final alcoholPercent = double.parse(
      _alcoholController.text.trim().replaceAll(',', '.'),
    );
    final amount = int.parse(_amountController.text.trim());

    setState(() {
      _isSubmitting = true;
    });

    final saved = await addTrackingEntry(
      drinkName: drinkName,
      alcoholPercent: alcoholPercent,
      amount: amount,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (saved) {
      _drinkNameController.clear();
      _alcoholController.clear();
      _amountController.clear();
    }
  }

  Stream<List<TrackingEntry>> _trackingEntriesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _trackingRepository.streamEntries(uid: user.uid);
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Saving timestamp...';
    }
    final localTime = timestamp.toDate().toLocal();
    return '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} '
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteEntry(String docId) async {
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

    if (confirmed != true) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _trackingRepository.deleteEntry(uid: user.uid, entryId: docId);
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete entry: ${e.message ?? e.code}'),
        ),
      );
    }
  }

  Future<void> _editEntry(TrackingEntry entry) async {
    final updatedEntry = await showEditTrackingEntryDialog(
      context: context,
      entry: entry,
    );
    if (updatedEntry == null || !mounted) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _trackingRepository.updateEntry(uid: user.uid, entry: updatedEntry);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry updated.')));
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update entry: ${e.message ?? e.code}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.id,
                (route) => false,
              );
            },
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40.0,
              child: Image.asset('images/soberly_logo.png'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ── Add New Drink card ──────────────────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card title row
                        const Row(
                          children: [
                            Icon(Icons.local_bar, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Add New Drink',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Drink Name
                        TextFormField(
                          controller: _drinkNameController,
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
                        // Alcohol %
                        TextFormField(
                          controller: _alcoholController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Alcohol %',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text =
                                value?.trim().replaceAll(',', '.') ?? '';
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
                        // Amount (ml)
                        TextFormField(
                          controller: _amountController,
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : _submitTrackingEntry,
                          icon: const Icon(Icons.add),
                          label: Text(
                            _isSubmitting ? 'Saving...' : 'Add Drink',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your entries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<TrackingEntry>>(
                    stream: _trackingEntriesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Could not load entries.'),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final entries = snapshot.data ?? const <TrackingEntry>[];
                      if (entries.isEmpty) {
                        return const Center(
                          child: Text(
                            'No entries yet. Add your first one above.',
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final drinkName = entry.drinkName.isEmpty
                              ? '-'
                              : entry.drinkName;
                          final alcoholPercent = entry.alcoholPercent;
                          final amount = entry.amount;
                          final createdAt = entry.createdAt;

                          final subtitle =
                              'Alcohol: ${alcoholPercent.toStringAsFixed(1)}%'
                              '  •  Amount: ${amount}ml'
                              '\n${_formatTimestamp(createdAt)}';

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
                                    onPressed: () => _editEntry(entry),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: entry.id == null
                                        ? null
                                        : () => _deleteEntry(entry.id!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
