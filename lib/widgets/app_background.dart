import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const AppBackground({super.key, required this.child, this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors ?? kAppBackgroundGradient,
        ),
      ),
      child: child,
    );
  }
}
