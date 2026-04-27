import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final double imageOpacity;
  final Color baseColor;
  final BoxFit fit;

  const AppBackground({
    super.key,
    required this.child,
    this.imagePath = kAppBackgroundImagePath,
    this.imageOpacity = kAppBackgroundOpacity,
    this.baseColor = kAppBackgroundBaseColor,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: fit,
          opacity: imageOpacity,
        ),
      ),
      child: child,
    );
  }
}
