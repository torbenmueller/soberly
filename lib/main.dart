import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/screens/registration_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/screens/welcome_screen.dart';
import 'package:soberly/utils/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Soberly());
}

class Soberly extends StatelessWidget {
  const Soberly({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF424242),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        ProfileSetupScreen.id: (context) => const ProfileSetupScreen(),
        TrackingScreen.id: (context) =>
            buildAuthGuardedScreen(authenticatedChild: const TrackingScreen()),
      },
    );
  }
}
