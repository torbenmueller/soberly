import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/models/tracking_entry.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/services/tracking_repository.dart';
import 'package:soberly/utils/auth_guard.dart';
import 'package:soberly/widgets/tracking/delete_tracking_entry_dialog.dart';
import 'package:soberly/widgets/tracking/edit_tracking_entry_dialog.dart';
import 'package:soberly/models/sex_for_calculation.dart';
import 'package:soberly/services/user_profile_repository.dart';

class TrackingScreenController extends ChangeNotifier {
  static const double _ethanolDensityGramPerMl = 0.789;

  TrackingScreenController({
    FirebaseAuth? auth,
    TrackingRepository? trackingRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _trackingRepository = trackingRepository ?? TrackingRepository();

  final FirebaseAuth _auth;
  final TrackingRepository _trackingRepository;
  final _profileRepository = UserProfileRepository();

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

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

      final amountMl = entry.amount;
      final alcoholPercent = entry.alcoholPercent;
      if (amountMl <= 0 || alcoholPercent <= 0) {
        continue;
      }

      final pureAlcoholMl = amountMl * (alcoholPercent / 100);
      final pureAlcoholGrams = pureAlcoholMl * _ethanolDensityGramPerMl;
      totalGrams += pureAlcoholGrams;
    }

    return totalGrams;
  }

  // ── Add entry ────────────────────────────────────────────────────────────

  Future<bool> _addEntry({
    required BuildContext context,
    required String drinkName,
    required double alcoholPercent,
    required int amount,
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

  Future<bool> submitEntry(BuildContext context) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return false;

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

  // ── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.id,
      (route) => false,
    );
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
