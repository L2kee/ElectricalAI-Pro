import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const AppButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}