import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CTextfield extends StatelessWidget {
  final bool isNumber;
  final TextEditingController controller;
  final String label;
  final Color labelColor;
  final bool pass;
  final bool obscureText;
  final Color? bordercolor;
  final double? borderWidht;
  final double? borderRadius;

  const CTextfield({
    super.key,
    required this.controller,
    required this.label,
    required this.labelColor,
    required this.pass,
    required this.isNumber,
    required this.borderRadius,
    required this.borderWidht,
    required this.bordercolor,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 20.0),
          borderSide: BorderSide(
            color: bordercolor ?? Colors.grey,
            width: borderWidht ?? 1.0,
          ),
        ),
        prefixIcon: isNumber
            ? const Icon(Icons.numbers)
            : const Icon(Icons.person),
      ),
    );
  }
}
