import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/models/sex_for_calculation.dart';
import 'package:soberly/screens/calendar_screen.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/screens/statistics_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/services/user_profile_repository.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/widgets/app_background.dart';
import 'package:soberly/widgets/profile/sex_for_calculation_dropdown.dart';
import 'package:soberly/widgets/tracking/tracking_bottom_action_bar.dart';
import 'package:soberly/widgets/app_page_header.dart';

class ProfileSetupScreen extends StatefulWidget {
  static const String id = 'profile_setup_screen';

  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _auth = FirebaseAuth.instance;
  final _profileRepository = UserProfileRepository();
  SexForCalculation? _selectedSex;
  bool _isSaving = false;
  bool _isOpenedFromSettings = false;
  bool _didLoadExisting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadExisting) {
      return;
    }

    _isOpenedFromSettings = ModalRoute.of(context)?.settings.arguments == true;
    _didLoadExisting = true;
    _loadExistingValue();
  }

  Future<void> _loadExistingValue() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginScreen.id, arguments: true);
      return;
    }

    final existing = await _profileRepository.getSexForCalculation(
      uid: user.uid,
    );
    if (!mounted) return;

    if (existing == null) {
      return;
    }

    if (_isOpenedFromSettings) {
      setState(() {
        _selectedSex = existing;
      });
      return;
    }

    Navigator.pushReplacementNamed(context, TrackingScreen.id);
  }

  Future<void> _saveAndContinue() async {
    final selected = _selectedSex;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option to continue.')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, LoginScreen.id, arguments: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _profileRepository.saveSexForCalculation(
        uid: user.uid,
        sex: selected,
      );
      if (!mounted) return;
      if (_isOpenedFromSettings) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacementNamed(context, TrackingScreen.id);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save profile: ${e.message ?? e.code}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.id,
      (route) => false,
    );
  }

  void _goToTrackingScreen() {
    if (_isOpenedFromSettings) {
      Navigator.pop(context, true);
      return;
    }
    Navigator.pushReplacementNamed(context, TrackingScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TrackingBottomActionBar(
        onTrackingPressed: _goToTrackingScreen,
        onCalendarPressed: () =>
            Navigator.pushReplacementNamed(context, CalendarScreen.id),
        onStatisticsPressed: () =>
            Navigator.pushReplacementNamed(context, StatisticsScreen.id),
        onProfilePressed: () {},
        selectedTab: TrackingBottomActionBarTab.profile,
      ),
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: kEdgeInsetsAll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - kEdgeInsetsAll.vertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppPageHeader(
                      title: _isOpenedFromSettings
                          ? 'Edit Profile'
                          : 'Profile Setup',
                      subtitle: 'Change and edit your profile information',
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      color: Colors.white.withValues(alpha: 0.2),
                      child: Padding(
                        padding: kEdgeInsetsAll,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 16),
                                children: [
                                  const TextSpan(
                                    text: 'Email: ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: _auth.currentUser?.email ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: kTextOpacity,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sex for Calculation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(
                                  alpha: kTextOpacity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SexForCalculationDropdown(
                              selectedSex: _selectedSex,
                              isSaving: _isSaving,
                              onSelected: (value) =>
                                  setState(() => _selectedSex = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      color: Colors.white.withValues(alpha: 0.2),
                      child: Padding(
                        padding: kEdgeInsetsAll,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Daily Goal',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Daily goal in grams (optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(
                                  alpha: kTextOpacity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              decoration: kTextFieldDecoration.copyWith(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Enter your daily goal in grams',
                                border: buildProfileOutlineInputBorder(
                                  color: Colors.blueAccent,
                                ),
                                enabledBorder: buildProfileOutlineInputBorder(
                                  color: Colors.blueAccent,
                                ),
                                focusedBorder: buildProfileOutlineInputBorder(
                                  color: Colors.blueAccent,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      title: _isSaving
                          ? 'Saving...'
                          : (_isOpenedFromSettings ? 'Save' : 'Continue'),
                      color: kPrimaryColor,
                      onPressed: () {
                        if (_isSaving) {
                          return;
                        }
                        _saveAndContinue();
                      },
                    ),
                    if (_isOpenedFromSettings) ...[
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 2,
                        color: Colors.white.withValues(alpha: 0.2),
                        child: Padding(
                          padding: kEdgeInsetsAll,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Log Out from your account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                title: 'Log Out',
                                color: const Color(0xFF000000),
                                textColor: Colors.white,
                                onPressed: _logout,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
