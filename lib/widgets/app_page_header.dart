import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double bottomSpacing;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.bottomSpacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: kFontSizeLarge,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: kTextOpacity),
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
