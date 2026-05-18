import 'package:flutter/material.dart';

void goToScreen(
  BuildContext context,
  String routeName, {
  Object? arguments,
  bool clearStack = false,
}) {
  final currentRouteName = ModalRoute.of(context)?.settings.name;
  if (currentRouteName == routeName) {
    return;
  }

  if (clearStack) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
    return;
  }

  Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
}
