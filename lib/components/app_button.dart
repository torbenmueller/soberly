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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 42.0,
        child: MaterialButton(
          onPressed: onPressed,
          color: color,
          disabledColor: color,
          textColor: textColor,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(title, style: const TextStyle(fontSize: 20.0)),
        ),
      ),
    );
  }
}
