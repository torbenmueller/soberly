import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';

class HealthStatusCard extends StatelessWidget {
  const HealthStatusCard({
    required this.dailyLimit,
    required this.todayGrams,
    super.key,
  });

  final double dailyLimit;
  final double todayGrams;

  String _formatGrams(double grams) {
    return grams.toStringAsFixed(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    String riskLevel;
    String riskText;
    Color riskColor;
    Color riskBackgroundColor;
    Color borderColor;

    if (todayGrams <= dailyLimit) {
      riskLevel = 'Low';
      riskText = 'Within recommended limits';
      riskColor = Colors.green.shade300;
      riskBackgroundColor = Colors.green.shade900.withValues(alpha: 0.2);
      borderColor = Colors.green.shade300.withValues(alpha: 0.3);
    } else if (todayGrams <= dailyLimit * 2) {
      riskLevel = 'Moderate';
      riskText = 'Above recommended intake';
      riskColor = Colors.orange.shade300;
      riskBackgroundColor = Colors.orange.shade900.withValues(alpha: 0.2);
      borderColor = Colors.orange.shade300.withValues(alpha: 0.3);
    } else {
      riskLevel = 'High';
      riskText = 'Significantly above recommended intake';
      riskColor = Colors.red.shade300;
      riskBackgroundColor = Colors.red.shade900.withValues(alpha: 0.2);
      borderColor = Colors.red.shade300.withValues(alpha: 0.3);
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: riskBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: kEdgeInsetsAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: kTextOpacity),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_formatGrams(todayGrams)} g',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 10),
            // Text(
            //   '${_formatGrams(todayGrams)} g alcohol',
            //   style: const TextStyle(fontSize: 16, color: Colors.white),
            // ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.favorite, size: 22, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Risk Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  riskLevel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ],
            ),
            Text(
              riskText,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
