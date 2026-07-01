import 'package:flutter/material.dart';
import 'package:soberly/constants.dart';
import 'package:soberly/models/custom_drink.dart';

class CustomDrinkTile extends StatelessWidget {
  const CustomDrinkTile({
    super.key,
    required this.drink,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomDrink drink;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final iconOption = customDrinkIconOptionFromKey(drink.iconKey);
    final color = Color(drink.colorValue);
    final iconForeground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: 0.16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Icon(iconOption.icon, color: iconForeground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drink.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${drink.amountMl} ml • ${drink.alcoholPercent.toStringAsFixed(1)}% • ${iconOption.label}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: kTextOpacity),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white.withValues(alpha: kTextOpacity),
              ),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red.withValues(alpha: kTextOpacity),
              ),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
