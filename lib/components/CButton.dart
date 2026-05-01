import 'package:flutter/material.dart';

class CButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double width;
  final double height;
  final IconData? icon;
  final double fontSize;
  final FontWeight fontWeight; // 1. Tambahkan deklarasi variabel

  const CButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF2D5F3F),
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.width = double.infinity,
    this.height = 56,
    this.icon,
    this.fontSize = 18,
    this.fontWeight =
        FontWeight.w600, // 2. Tambahkan di constructor dengan default w600
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight, // 3. Gunakan variabel di sini
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
