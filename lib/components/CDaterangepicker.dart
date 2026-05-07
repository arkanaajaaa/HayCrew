import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// CDateRangePicker — Reusable date range field yang tampil seperti TextField.
///
/// Penggunaan:
/// ```dart
/// CDateRangePicker(
///   displayText: controller.formattedDateRange,
///   onTap: controller.onTapDatePicker,
/// )
/// ```
class CDateRangePicker extends StatelessWidget {
  final String displayText;
  final VoidCallback onTap;
  final Color? fillColor;
  final Color? textColor;
  final Color? iconColor;
  final double borderRadius;

  const CDateRangePicker({
    Key? key,
    required this.displayText,
    required this.onTap,
    this.fillColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: fillColor ?? AppColors.textFieldBg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  color: textColor ?? AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: iconColor ?? AppColors.primaryGreen,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}