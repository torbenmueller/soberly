import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

class DailyLimitText extends StatelessWidget {
  const DailyLimitText({required this.dailyLimit, super.key});

  final double dailyLimit;

  String _formatGrams(double grams) {
    return grams.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Your daily limit is ${_formatGrams(dailyLimit)} g alcohol.',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withValues(alpha: kTextOpacity),
      ),
    );
  }
}
