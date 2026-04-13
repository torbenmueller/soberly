import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soberly/screens/login_screen.dart';

class TrackingScreen extends StatefulWidget {
  static const String id = 'tracking_screen';
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _drinksController = TextEditingController();
  final _noteController = TextEditingController();
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
    _drinksController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<bool> addTrackingEntry({required int drinks, String? note}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _redirectIfUnauthenticated();
      return false;
    }

    final cleanedNote = note?.trim();
    final data = <String, dynamic>{
      'drinks': drinks,
      'createdAt': FieldValue.serverTimestamp(),
      if (cleanedNote != null && cleanedNote.isNotEmpty) 'note': cleanedNote,
    };

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tracking_entries')
          .add(data);
      if (!mounted) {
        return true;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tracking entry saved.')));
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

    final drinks = int.parse(_drinksController.text.trim());
    setState(() {
      _isSubmitting = true;
    });

    final saved = await addTrackingEntry(
      drinks: drinks,
      note: _noteController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (saved) {
      _drinksController.clear();
      _noteController.clear();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _trackingEntriesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tracking_entries')
        .orderBy('createdAt', descending: true)
        .snapshots();
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
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tracking_entries')
          .doc(docId)
          .delete();
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

  Future<void> _editEntry(
    String docId,
    int currentDrinks,
    String? currentNote,
  ) async {
    final drinksCtrl = TextEditingController(text: currentDrinks.toString());
    final noteCtrl = TextEditingController(text: currentNote ?? '');
    final editFormKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit entry'),
        content: Form(
          key: editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: drinksCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of drinks',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Please enter a number.';
                  }
                  final v = int.tryParse(text);
                  if (v == null || v <= 0) {
                    return 'Enter a whole number greater than 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (editFormKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      drinksCtrl.dispose();
      noteCtrl.dispose();
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      drinksCtrl.dispose();
      noteCtrl.dispose();
      return;
    }

    final cleanedNote = noteCtrl.text.trim();
    final updatedData = <String, dynamic>{
      'drinks': int.parse(drinksCtrl.text.trim()),
      if (cleanedNote.isNotEmpty)
        'note': cleanedNote
      else
        'note': FieldValue.delete(),
    };

    drinksCtrl.dispose();
    noteCtrl.dispose();

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tracking_entries')
          .doc(docId)
          .update(updatedData);
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
            icon: Icon(Icons.logout),
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
                TextFormField(
                  controller: _drinksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of drinks',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please enter a number.';
                    }
                    final drinks = int.tryParse(text);
                    if (drinks == null || drinks <= 0) {
                      return 'Enter a whole number greater than 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTrackingEntry,
                  child: Text(_isSubmitting ? 'Saving...' : 'Save entry'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your entries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

                      final docs = snapshot.data?.docs ?? const [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No entries yet. Add your first one above.',
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final drinks = data['drinks'];
                          final note = data['note'] as String?;
                          final createdAt = data['createdAt'] as Timestamp?;

                          return Card(
                            child: ListTile(
                              title: Text('Drinks: ${drinks ?? '-'}'),
                              subtitle: Text(
                                (note != null && note.isNotEmpty)
                                    ? '$note\n${_formatTimestamp(createdAt)}'
                                    : _formatTimestamp(createdAt),
                              ),
                              isThreeLine: note != null && note.isNotEmpty,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    tooltip: 'Edit',
                                    onPressed: () => _editEntry(
                                      docs[index].id,
                                      (drinks as num).toInt(),
                                      note,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: () =>
                                        _deleteEntry(docs[index].id),
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
