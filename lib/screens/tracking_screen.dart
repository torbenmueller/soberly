import 'package:flutter/material.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/screens/tracking_screen_controller.dart';
import 'package:soberly/widgets/tracking/add_new_drink_card.dart';
import 'package:soberly/widgets/tracking/tracking_entries_section.dart';
import 'package:soberly/constants.dart';

class TrackingScreen extends StatefulWidget {
  static const String id = 'tracking_screen';
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final TrackingScreenController _controller;
  late final Future<double> _dailyLimitFuture;

  @override
  void initState() {
    super.initState();
    _controller = TrackingScreenController();
    _controller.redirectIfUnauthenticated(context);
    _controller.redirectIfProfileIncomplete(context);
    _dailyLimitFuture = _controller.getDailyLimitGrams();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAddDrinkSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: _controller,
        builder: (_, _) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Form(
              key: _controller.formKey,
              child: AddNewDrinkCard(
                drinkNameController: _controller.drinkNameController,
                alcoholController: _controller.alcoholController,
                amountController: _controller.amountController,
                isSubmitting: _controller.isSubmitting,
                onSubmit: () async {
                  final saved = await _controller.submitEntry(context);
                  if (!sheetContext.mounted) return;
                  if (saved) {
                    FocusScope.of(sheetContext).unfocus();
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatGrams(double grams) {
    return grams.toStringAsFixed(1);
  }

  Widget _buildHealthStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: kEdgeInsetsAll,
        child: FutureBuilder<double>(
          future: _dailyLimitFuture,
          builder: (context, dailyLimitSnapshot) {
            final dailyLimit = dailyLimitSnapshot.data ?? 0.0;

            return StreamBuilder<List<TrackingEntry>>(
              stream: _controller.entriesStream,
              builder: (context, snapshot) {
                final entries = snapshot.data ?? const <TrackingEntry>[];
                final todayGrams = _controller.computeTodayAlcoholGrams(
                  entries,
                );
                // final remaining = (dailyLimit - todayGrams).clamp(
                //   0.0,
                //   dailyLimit,
                // );
                final remaining = dailyLimit - todayGrams;
                final isWithinLimit = remaining >= 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.favorite, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Health Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Today: ${_formatGrams(todayGrams)} g alcohol',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isWithinLimit ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${isWithinLimit ? '-' : '+'} ${_formatGrams(remaining.abs())} g',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Your daily limit is ${_formatGrams(dailyLimit)} g alcohol.',
                      style: TextStyle(
                        fontSize: 15,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Edit profile',
            onPressed: () => Navigator.pushNamed(
              context,
              ProfileSetupScreen.id,
              arguments: true,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _controller.signOut(context),
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
      floatingActionButton: SizedBox.square(
        dimension: 60,
        child: FloatingActionButton(
          onPressed: _openAddDrinkSheet,
          backgroundColor: kPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: kEdgeInsetsAll,
          child: Column(
            children: [
              _buildHealthStatusCard(),
              const SizedBox(height: 16),
              Expanded(
                child: TrackingEntriesSection(
                  stream: _controller.entriesStream,
                  onEdit: (entry) => _controller.editEntry(context, entry),
                  onDelete: (entry) {
                    final entryId = entry.id;
                    if (entryId == null) return;
                    _controller.deleteEntry(context, entryId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
