import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/screens/registration_screen.dart';
import 'package:soberly/screens/tracking_screen.dart';
import 'package:soberly/screens/welcome_screen.dart';
import 'package:soberly/utils/auth_guard.dart';
import 'package:soberly/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHyphenation();
  runApp(const Soberly());
}

class Soberly extends StatelessWidget {
  const Soberly({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: kAppBackgroundBaseColor,
          canvasColor: kAppBackgroundBaseColor,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                backgroundColor: kAppBackgroundBaseColor,
              ),
            },
          ),
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white, size: 24),
            actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          RegistrationScreen.id: (context) => const RegistrationScreen(),
          ProfileSetupScreen.id: (context) => const ProfileSetupScreen(),
          TrackingScreen.id: (context) => buildAuthGuardedScreen(
            authenticatedChild: const TrackingScreen(),
          ),
        },
      ),
    );
  }
}
