import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton(onPressed: onPressed, child: Text(text))
        : ElevatedButton(onPressed: onPressed, child: Text(text));
    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}