import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/components/app_button.dart';
import 'package:soberly/screens/registration_screen.dart';
import 'package:soberly/utils/auth_guard.dart';
import 'package:soberly/widgets/app_background.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  final bool showUnauthRedirectMessage;

  const LoginScreen({super.key, this.showUnauthRedirectMessage = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _didShowRedirectMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final showFromArguments =
        ModalRoute.of(context)?.settings.arguments == true;
    final shouldShowMessage =
        widget.showUnauthRedirectMessage || showFromArguments;

    if (!shouldShowMessage || _didShowRedirectMessage) {
      return;
    }

    _didShowRedirectMessage = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to access tracking.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: LoadingOverlay(
          color: Colors.black.withValues(alpha: 0.5),
          isLoading: _isLoading,
          child: Padding(
            padding: kEdgeInsetsSymmetricHorizontal,
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
                    fillColor: Colors.white,
                    filled: true,
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
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter your password',
                  ),
                ),
                SizedBox(height: 24.0),
                AppButton(
                  title: 'Log In',
                  color: kPrimaryColor,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      if (user.user != null) {
                        await navigateAfterAuth(context, auth: _auth);
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
            ),
          ),
        ),
      ),
    );
  }
}
