import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CDropdownField<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final String? labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color? fillColor;
  final Color? hintColor;
  final bool enabled;
  final String? Function(T?)? validator;

  final Color? dropdownColor;
  final double menuBorderRadius;
  final double elevation;
  final TextStyle? itemTextStyle;

  const CDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.fillColor,
    this.hintColor,
    this.enabled = true,
    this.validator,
    this.dropdownColor,
    this.menuBorderRadius = 12,
    this.elevation = 3,
    this.itemTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGreen),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: itemTextStyle ??
          const TextStyle(color: Colors.black87, fontSize: 16),
      // ── Tema popup menu (putih, field-nya sendiri tetap coklat) ──
      dropdownColor: dropdownColor ?? Colors.white,
      borderRadius: BorderRadius.circular(menuBorderRadius),
      elevation: elevation.round(),
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(
          color: hintColor ?? AppColors.primaryGreen,
          fontSize: 16,
        ),
        filled: true,
        fillColor: enabled
            ? (fillColor ?? AppColors.textFieldBg)
            : AppColors.textFieldBg.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}