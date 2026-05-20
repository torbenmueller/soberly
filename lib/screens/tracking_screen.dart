import 'package:flutter/material.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/controllers/tracking_screen_controller.dart';
import 'package:soberly/widgets/tracking/add_new_drink.dart';
import 'package:soberly/widgets/tracking/bottom_action_bar.dart';
import 'package:soberly/widgets/tracking/daily_limit_text.dart';
import 'package:soberly/widgets/tracking/health_status_card.dart';
import 'package:soberly/widgets/tracking/tracking_entries_section.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/app_page_header.dart';

class TrackingScreen extends StatefulWidget {
  static const String id = 'tracking_screen';
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final TrackingScreenController _controller;
  late Future<double> _dailyLimitFuture;

  @override
  void initState() {
    super.initState();
    _controller = TrackingScreenController();
    _controller.redirectIfUnauthenticated(context);
    _controller.redirectIfProfileIncomplete(context);
    _dailyLimitFuture = _controller.getDailyLimitGrams();
  }

  void _refreshDailyLimit() {
    setState(() {
      _dailyLimitFuture = _controller.getDailyLimitGrams();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddDrinkSheet() async {
    await _controller.prefillFromMostRecentEntry();
    if (!mounted) {
      return;
    }

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
              child: AddNewDrink(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        onProfilePressed: () async {
          final updated = await Navigator.pushNamed(
            context,
            ProfileSetupScreen.id,
            arguments: true,
          );
          if (!mounted) return;
          if (updated == true) {
            _refreshDailyLimit();
          }
        },
        onTrackingPressed: null,
        selectedTab: BottomActionBarTab.tracking,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox.square(
        dimension: 60,
        child: FloatingActionButton(
          onPressed: _openAddDrinkSheet,
          backgroundColor: kPrimaryColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: kEdgeInsetsAll.copyWith(bottom: 0),
            child: FutureBuilder<double>(
              future: _dailyLimitFuture,
              builder: (context, snapshot) {
                final dailyLimit = snapshot.data ?? 0.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppPageHeader(
                      title: 'Track Drinks',
                      subtitle: 'Log what you\'re drinking',
                    ),
                    StreamBuilder<List<TrackingEntry>>(
                      stream: _controller.entriesStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const SizedBox(
                            height: 132,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final entries = snapshot.data!;
                        final todayGrams = _controller.computeTodayAlcoholGrams(
                          entries,
                        );

                        return HealthStatusCard(
                          dailyLimit: dailyLimit,
                          todayGrams: todayGrams,
                        );
                      },
                    ),
                    Center(child: DailyLimitText(dailyLimit: dailyLimit)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TrackingEntriesSection(
                        stream: _controller.todayEntriesStream,
                        onEdit: (entry) =>
                            _controller.editEntry(context, entry),
                        onDelete: (entry) {
                          final entryId = entry.id;
                          if (entryId == null) return;
                          _controller.deleteEntry(context, entryId);
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
