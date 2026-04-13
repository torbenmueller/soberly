import 'package:flutter/material.dart';
import 'package:soberly/screens/login_screen.dart';
// import 'package:soberly/screens/registration_screen.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/screens/registration_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Color?> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    animation = ColorTween(
      begin: Color(0xff284C54),
      end: Colors.white,
    ).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
            const SizedBox(height: 48.0),
            AppButton(
              title: 'Log In',
              color: Color(0xff72DBF2),
              onPressed: () => Navigator.pushNamed(context, LoginScreen.id),
            ),
            AppButton(
              title: 'Register',
              color: Color(0xff52A8F2),
              onPressed: () =>
                  Navigator.pushNamed(context, RegistrationScreen.id),
            ),
            AppButton(
              title: 'Tracking Screen',
              color: Colors.red,
              onPressed: () => Navigator.pushNamed(context, TrackingScreen.id),
            ),
          ],
        ),
      ),
      builder: (context, child) {
        return Scaffold(backgroundColor: animation.value, body: child);
      },
    );
  }
}
