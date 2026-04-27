import 'dart:async';
import 'package:flutter/material.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/screens/registration_screen.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/utils/auth_guard.dart';
import 'package:soberly/widgets/app_background.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const _autoForwardDelay = Duration(milliseconds: 500);

  late final AnimationController controller;
  late final Animation<Color?> animation;
  Timer? _authForwardTimer;

  void _forwardIfAuthenticated() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _authForwardTimer = Timer(_autoForwardDelay, () async {
        if (!mounted || !isAuthenticated()) {
          return;
        }
        await navigateAfterAuth(context);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    animation = ColorTween(
      begin: const Color(0xff1a3a40),
      end: kAppBackgroundBaseColor,
    ).animate(controller);
    controller.forward();
    _forwardIfAuthenticated();
  }

  @override
  void dispose() {
    _authForwardTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: Padding(
        padding: kEdgeInsetsSymmetricHorizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'soberly_logo',
              child: SizedBox(
                child: Image.asset(
                  'images/soberly_logo.png',
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Track your drinking mindfully, set personal goals, and build healthier habits - one day at a time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            if (!isAuthenticated()) ...[
              const SizedBox(height: 48.0),
              AppButton(
                title: 'Log In',
                color: kPrimaryColor,
                onPressed: () => Navigator.pushNamed(context, LoginScreen.id),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Don\'t have an account yet?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xff52A8F2),
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, RegistrationScreen.id),
                child: const Text('Create a new account'),
              ),
            ],
          ],
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: kAppBackgroundBaseColor,
          body: AppBackground(child: child!),
        );
      },
    );
  }
}
