import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/services/tracking_repository.dart';
import 'package:soberly/widgets/tracking/add_new_drink_card.dart';
import 'package:soberly/widgets/tracking/delete_tracking_entry_dialog.dart';
import 'package:soberly/widgets/tracking/edit_tracking_entry_dialog.dart';
import 'package:soberly/widgets/tracking/tracking_entries_section.dart';

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

  Future<void> _deleteEntry(String docId) async {
    final confirmed = await showDeleteTrackingEntryDialog(context: context);

    if (!confirmed) {
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
                AddNewDrinkCard(
                  drinkNameController: _drinkNameController,
                  alcoholController: _alcoholController,
                  amountController: _amountController,
                  isSubmitting: _isSubmitting,
                  onSubmit: _submitTrackingEntry,
                ),
                const SizedBox(height: 16),
                TrackingEntriesSection(
                  stream: _trackingEntriesStream(),
                  onEdit: _editEntry,
                  onDelete: (entry) {
                    final entryId = entry.id;
                    if (entryId == null) {
                      return;
                    }
                    _deleteEntry(entryId);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
