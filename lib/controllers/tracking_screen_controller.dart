import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/services/tracking_repository.dart';
import 'package:soberly/utils/auth_guard.dart';
import 'package:soberly/widgets/tracking/delete_tracking_entry_dialog.dart';
import 'package:soberly/widgets/tracking/edit_tracking_entry_dialog.dart';
import 'package:soberly/widgets/tracking/add_new_drink.dart';
import 'package:soberly/models/sex_for_calculation.dart';
import 'package:soberly/services/user_profile_repository.dart';
import 'package:soberly/constants.dart';

class TrackingScreenController extends ChangeNotifier {
  TrackingScreenController({
    FirebaseAuth? auth,
    TrackingRepository? trackingRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _trackingRepository = trackingRepository ?? TrackingRepository();

  final FirebaseAuth _auth;
  final TrackingRepository _trackingRepository;
  final _profileRepository = UserProfileRepository();
  static const int _maxBackdateDays = 30;

  int get maxBackdateDays => _maxBackdateDays;

  final formKey = GlobalKey<FormState>();
  final drinkNameController = TextEditingController();
  final alcoholController = TextEditingController();
  final amountController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // ── Auth guards ──────────────────────────────────────────────────────────

  void redirectIfUnauthenticated(BuildContext context) {
    redirectToLoginIfUnauthenticated(context, auth: _auth);
  }

  Future<void> redirectIfProfileIncomplete(BuildContext context) async {
    if (_auth.currentUser == null) return;

    final hasProfile = await hasRequiredProfileForTracking(auth: _auth);
    if (hasProfile) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, ProfileSetupScreen.id);
    });
  }

  // ── Stream ───────────────────────────────────────────────────────────────

  Stream<List<TrackingEntry>> get entriesStream {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _trackingRepository.streamEntries(uid: user.uid);
  }

  /// Stream of tracking entries filtered to today's date only.
  Stream<List<TrackingEntry>> get todayEntriesStream {
    return entriesStream.map((entries) {
      final today = DateTime.now().toLocal();
      return entries.where((entry) {
        final createdAt = entry.createdAt;
        if (createdAt == null) return false;
        final localEntryTime = createdAt.toDate().toLocal();
        return _isSameLocalDay(localEntryTime, today);
      }).toList();
    });
  }

  Future<void> prefillFromMostRecentEntry() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    TrackingEntry? recentEntry;
    try {
      recentEntry = await _trackingRepository.getMostRecentEntry(uid: user.uid);
    } on FirebaseException {
      return;
    }
    if (recentEntry == null) {
      return;
    }

    drinkNameController.text = recentEntry.drinkName;
    alcoholController.text = _formatAlcoholPercent(recentEntry.alcoholPercent);
    amountController.text = recentEntry.amount.toString();
  }

  String _formatAlcoholPercent(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime normalizeLocalDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime oldestAllowedEntryDate({DateTime? now}) {
    final today = normalizeLocalDate((now ?? DateTime.now()).toLocal());
    return today.subtract(const Duration(days: _maxBackdateDays));
  }

  DateTime latestAllowedEntryDate({DateTime? now}) {
    return normalizeLocalDate((now ?? DateTime.now()).toLocal());
  }

  bool isAllowedEntryDate(DateTime date, {DateTime? now}) {
    final normalized = normalizeLocalDate(date.toLocal());
    final oldest = oldestAllowedEntryDate(now: now);
    final latest = latestAllowedEntryDate(now: now);
    return !normalized.isBefore(oldest) && !normalized.isAfter(latest);
  }

  DateTime _entryDateWithCurrentTime(DateTime entryDate, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toLocal();
    final normalizedDate = normalizeLocalDate(entryDate.toLocal());
    return DateTime(
      normalizedDate.year,
      normalizedDate.month,
      normalizedDate.day,
      current.hour,
      current.minute,
      current.second,
      current.millisecond,
      current.microsecond,
    );
  }

  /// Returns the absolute daily alcohol limit in grams for this user.
  /// Falls back to the conservative (female) limit for null / preferNotToSay.
  Future<double> getDailyLimitGrams() async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final sex = await _profileRepository.getSexForCalculation(uid: user.uid);
    switch (sex) {
      case SexForCalculation.male:
        return 24.0;
      case SexForCalculation.female:
      case SexForCalculation.preferNotToSay:
      case null:
        return 12.0;
    }
  }

  double computeTodayAlcoholGrams(
    List<TrackingEntry> entries, {
    DateTime? now,
  }) {
    final today = (now ?? DateTime.now()).toLocal();

    var totalGrams = 0.0;
    for (final entry in entries) {
      final createdAt = entry.createdAt;
      if (createdAt == null) {
        continue;
      }

      final localEntryTime = createdAt.toDate().toLocal();
      if (!_isSameLocalDay(localEntryTime, today)) {
        continue;
      }

      totalGrams += calculatePureAlcoholGrams(
        amountMl: entry.amount,
        alcoholPercent: entry.alcoholPercent,
      );
    }

    return totalGrams;
  }

  // ── Add entry ────────────────────────────────────────────────────────────

  Future<bool> _addEntry({
    required BuildContext context,
    required String drinkName,
    required double alcoholPercent,
    required int amount,
    required DateTime entryDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      redirectIfUnauthenticated(context);
      return false;
    }

    final entry = TrackingEntry(
      drinkName: drinkName,
      alcoholPercent: alcoholPercent,
      amount: amount,
      createdAt: Timestamp.fromDate(_entryDateWithCurrentTime(entryDate)),
    );

    try {
      await _trackingRepository.addEntry(uid: user.uid, entry: entry);
      if (!context.mounted) return true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Drink entry saved.')));
      return true;
    } on FirebaseException catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save entry: ${e.message ?? e.code}')),
      );
      return false;
    }
  }

  Future<bool> submitEntry(BuildContext context, {DateTime? entryDate}) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return false;

    final selectedEntryDate =
        entryDate ?? latestAllowedEntryDate(now: DateTime.now());

    final drinkName = drinkNameController.text.trim();
    final alcoholPercent = double.parse(
      alcoholController.text.trim().replaceAll(',', '.'),
    );
    final amount = int.parse(amountController.text.trim());

    _isSubmitting = true;
    notifyListeners();

    final saved = await _addEntry(
      context: context,
      drinkName: drinkName,
      alcoholPercent: alcoholPercent,
      amount: amount,
      entryDate: selectedEntryDate,
    );

    _isSubmitting = false;
    notifyListeners();

    if (saved) {
      drinkNameController.clear();
      alcoholController.clear();
      amountController.clear();
    }

    return saved;
  }

  // ── Show add-drink bottom sheet ──────────────────────────────────────────

  Future<void> showAddDrinkBottomSheet({
    required BuildContext context,
    required Future<bool> Function() onSubmit,
  }) async {
    await prefillFromMostRecentEntry();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: this,
        builder: (_, _) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Form(
              key: formKey,
              child: AddNewDrink(
                drinkNameController: drinkNameController,
                alcoholController: alcoholController,
                amountController: amountController,
                isSubmitting: isSubmitting,
                onSubmit: () async {
                  final saved = await onSubmit();
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

  // ── Delete entry ─────────────────────────────────────────────────────────

  Future<void> deleteEntry(BuildContext context, String docId) async {
    final confirmed = await showDeleteTrackingEntryDialog(context: context);
    if (!confirmed) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _trackingRepository.deleteEntry(uid: user.uid, entryId: docId);
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete entry: ${e.message ?? e.code}'),
        ),
      );
    }
  }

  // ── Edit entry ───────────────────────────────────────────────────────────

  Future<void> editEntry(BuildContext context, TrackingEntry entry) async {
    final updated = await showEditTrackingEntryDialog(
      context: context,
      entry: entry,
    );
    if (updated == null || !context.mounted) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _trackingRepository.updateEntry(uid: user.uid, entry: updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry updated.')));
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update entry: ${e.message ?? e.code}'),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    drinkNameController.dispose();
    alcoholController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
