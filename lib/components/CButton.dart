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
          padding: const EdgeInsets.symmetric(horizontal: 8), // Tambahkan sedikit padding dalam
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
            // 1. Tambahkan Flexible agar teks menyesuaikan ruang yang ada
            Flexible(
              child: Text(
                text,
                // 2. Tambahkan TextAlign agar teks tetap rapi saat turun ke baris baru
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                // 3. Opsional: batasi baris agar tidak merusak layout jika terlalu panjang
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