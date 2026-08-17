import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Format angka yang diketik jadi format ribuan Indonesia (mis. 500.000)
/// secara live, tanpa titik desimal.
class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatted =
        NumberFormat.decimalPattern('id_ID').format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
