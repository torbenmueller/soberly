import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/screens/login_screen.dart';

bool isAuthenticated({FirebaseAuth? auth}) {
  return (auth ?? FirebaseAuth.instance).currentUser != null;
}

void redirectToLoginIfUnauthenticated(
  BuildContext context, {
  FirebaseAuth? auth,
}) {
  if (isAuthenticated(auth: auth)) {
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, LoginScreen.id, arguments: true);
  });
}

Widget buildAuthGuardedScreen({
  required Widget authenticatedChild,
  FirebaseAuth? auth,
}) {
  if (isAuthenticated(auth: auth)) {
    return authenticatedChild;
  }

  return const LoginScreen(showUnauthRedirectMessage: true);
}
