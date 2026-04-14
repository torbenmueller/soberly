import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soberly/screens/login_screen.dart';
import 'package:soberly/screens/profile_setup_screen.dart';
import 'package:soberly/services/user_profile_repository.dart';

const _trackingRouteId = 'tracking_screen';

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

Future<void> navigateAfterAuth(
  BuildContext context, {
  FirebaseAuth? auth,
  UserProfileRepository? profileRepository,
}) async {
  final resolvedAuth = auth ?? FirebaseAuth.instance;
  final user = resolvedAuth.currentUser;
  if (user == null) {
    if (!context.mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, LoginScreen.id, arguments: true);
    return;
  }

  final repository = profileRepository ?? UserProfileRepository();
  final hasProfile = await repository.hasSexForCalculation(uid: user.uid);
  if (!context.mounted) {
    return;
  }

  Navigator.pushReplacementNamed(
    context,
    hasProfile ? _trackingRouteId : ProfileSetupScreen.id,
  );
}

Future<bool> hasRequiredProfileForTracking({
  FirebaseAuth? auth,
  UserProfileRepository? profileRepository,
}) async {
  final user = (auth ?? FirebaseAuth.instance).currentUser;
  if (user == null) {
    return false;
  }

  return (profileRepository ?? UserProfileRepository()).hasSexForCalculation(
    uid: user.uid,
  );
}
