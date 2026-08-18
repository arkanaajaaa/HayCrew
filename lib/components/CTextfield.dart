import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';


class CTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color? fillColor;
  final Color? hintColor;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;


  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffixIcon; 

  const CTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.fillColor,
    this.hintColor,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      // Field putih bersih + border tipis krem (bukan fill khaki solid lagi)
      // biar kerasa lebih rapi/profesional dan nyatu sama warna aplikasi;
      // hint dikasih abu-abu netral, bukan hijau, biar nggak ketuker sama
      // isian beneran.
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(
          color: hintColor ?? Colors.grey[500],
          fontSize: 15,
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryGreen) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled
            ? (fillColor ?? AppColors.white)
            : Colors.grey.shade100,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}