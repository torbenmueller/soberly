import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/models/custom_drink.dart';
import 'package:soberly/services/custom_drinks_repository.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/app_page_header.dart';
import 'package:soberly/widgets/custom_drinks/custom_drink_editor_sheet.dart';
import 'package:soberly/widgets/custom_drinks/custom_drink_tile.dart';
import 'package:soberly/widgets/tracking/bottom_action_bar.dart';

class CustomDrinksScreen extends StatefulWidget {
  static const String id = 'custom_drinks_screen';

  const CustomDrinksScreen({super.key});

  @override
  State<CustomDrinksScreen> createState() => _CustomDrinksScreenState();
}

class _CustomDrinksScreenState extends State<CustomDrinksScreen> {
  late final FirebaseAuth _auth;
  late final CustomDrinksRepository _repository;
  List<CustomDrink> _visibleDrinks = const <CustomDrink>[];
  bool _isPersistingOrder = false;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _repository = CustomDrinksRepository();
  }

  Stream<List<CustomDrink>> get _drinksStream {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _repository.streamCustomDrinks(uid: user.uid);
  }

  Future<void> _openEditor({CustomDrink? drink}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomDrinkEditorSheet(
        initialDrink: drink,
        onSubmit: (draft) async {
          final user = _auth.currentUser;
          if (user == null) {
            return false;
          }

          try {
            final nextOrder = _visibleDrinks.length;
            if (drink == null) {
              await _repository.addCustomDrink(
                uid: user.uid,
                drink: draft.copyWith(displayOrder: nextOrder),
              );
            } else {
              await _repository.updateCustomDrink(uid: user.uid, drink: draft);
            }
            if (!mounted) return true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  drink == null
                      ? 'Custom drink saved.'
                      : 'Custom drink updated.',
                ),
              ),
            );
            return true;
          } on FirebaseException catch (e) {
            if (!mounted) return false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not save custom drink: ${e.message ?? e.code}',
                ),
              ),
            );
            return false;
          }
        },
      ),
    );
  }

  Future<void> _deleteDrink(CustomDrink drink) async {
    final id = drink.id;
    if (id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete custom drink'),
        content: const Text(
          'Are you sure you want to delete this custom drink?',
        ),
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
      await _repository.deleteCustomDrink(uid: user.uid, drinkId: id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Custom drink deleted.')));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete custom drink: ${e.message ?? e.code}',
          ),
        ),
      );
    }
  }

  Future<void> _reorderDrinks(int oldIndex, int newIndex) async {
    if (_isPersistingOrder) return;

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final reordered = List<CustomDrink>.from(_visibleDrinks);
      final moved = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, moved);
      _visibleDrinks = reordered;
      _isPersistingOrder = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isPersistingOrder = false;
      });
      return;
    }

    try {
      await _repository.updateDisplayOrder(
        uid: user.uid,
        drinks: _visibleDrinks,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save custom drink order: ${e.message ?? e.code}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPersistingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        selectedTab: BottomActionBarTab.drinks,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox.square(
        dimension: 60,
        child: FloatingActionButton(
          onPressed: () => _openEditor(),
          backgroundColor: kPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: kEdgeInsetsAll,
            child: StreamBuilder<List<CustomDrink>>(
              stream: _drinksStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Could not load custom drinks. Please check your login and Firestore permissions.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: kTextOpacity),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final drinks = snapshot.data ?? const <CustomDrink>[];
                _visibleDrinks = drinks;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppPageHeader(
                      title: 'Custom Drinks',
                      subtitle: 'Create and edit your custom drinks',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Give your favorite drinks their own icon and color for faster logging.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: kTextOpacity),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tip: drag items to reorder your presets.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: kTextOpacity),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: drinks.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 72),
                              child: Center(
                                child: Text(
                                  'No custom drinks yet. Tap + to add one.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: kTextOpacity,
                                    ),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.only(bottom: 88),
                              buildDefaultDragHandles: false,
                              itemCount: _visibleDrinks.length,
                              onReorder: _reorderDrinks,
                              itemBuilder: (context, index) {
                                final drink = _visibleDrinks[index];
                                return ReorderableDelayedDragStartListener(
                                  key: ValueKey(
                                    drink.id ?? '${drink.name}-$index',
                                  ),
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: CustomDrinkTile(
                                      drink: drink,
                                      onEdit: () => _openEditor(drink: drink),
                                      onDelete: () => _deleteDrink(drink),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
