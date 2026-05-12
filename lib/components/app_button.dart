import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.title,
    required this.color,
    this.textColor = Colors.black,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Material(
        elevation: isDisabled ? 0 : 5.0,
        color: isDisabled ? color.withValues(alpha: 0.4) : color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          disabledColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              color: isDisabled ? textColor.withValues(alpha: 0.5) : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
