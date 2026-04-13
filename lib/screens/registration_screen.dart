import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/screens/tracking_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        color: Colors.black.withValues(alpha: 0.5),
        isLoading: _isLoading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'soberly_logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('images/soberly_logo.png'),
                  ),
                ),
              ),
              SizedBox(height: 48.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(height: 24.0),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(height: 24.0),
              AppButton(
                title: 'Register',
                color: Color(0xff52A8F2),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final UserCredential userCredential = await _auth
                        .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                    if (!context.mounted) {
                      return;
                    }
                    if (userCredential.user != null) {
                      Navigator.pushNamed(context, TrackingScreen.id);
                    }
                  } catch (e) {
                    debugPrint('$e');
                  }
                  if (context.mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
