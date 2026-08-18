import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


class CDropdownField extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color? fillColor;
  final Color? hintColor;

  const CDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.fillColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: (value == null || value!.isEmpty) ? null : value,
      isExpanded: true,
      hint: Text(
        hintText,
        style: TextStyle(
          color: hintColor ?? Colors.grey[500],
          fontSize: 15,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primaryGreen,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      // Samain sama CTextField — putih bersih + border tipis krem, bukan
      // fill khaki solid.
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor ?? AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textFieldBg, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textFieldBg, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
