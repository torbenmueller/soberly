import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/models/sex_for_calculation.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/services/user_profile_repository.dart';
import 'package:soberly/components/app_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOpenedFromSettings ? 'Edit Profile' : 'Profile Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'To personalize alcohol safety estimates, please choose the sex used for physiological calculations.',
              ),
              const SizedBox(height: 16),
              IgnorePointer(
                ignoring: _isSaving,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _isSaving ? 0.55 : 1,
                  child: RadioGroup<SexForCalculation>(
                    groupValue: _selectedSex,
                    onChanged: (value) {
                      if (_isSaving) {
                        return;
                      }
                      setState(() {
                        _selectedSex = value;
                      });
                    },
                    child: Column(
                      children: [
                        ...SexForCalculation.values.map(
                          (item) => RadioListTile<SexForCalculation>(
                            title: Text(item.label),
                            value: item,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // ElevatedButton(
              //   onPressed: _isSaving ? null : _saveAndContinue,
              //   child: Text(
              //     _isSaving
              //         ? 'Saving...'
              //         : (_isOpenedFromSettings ? 'Save' : 'Continue'),
              //   ),
              // ),
              AppButton(
                title: _isSaving
                    ? 'Saving...'
                    : (_isOpenedFromSettings ? 'Save' : 'Continue'),
                color: Color(0xff72DBF2),
                onPressed: () {
                  if (_isSaving) {
                    return;
                  }
                  _saveAndContinue();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
