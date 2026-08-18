import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF2D5F4F);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFE8A547);
  static const Color red = Color(0xFFD64545);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F0);
  static const Color calendarBackground = Color(0xFFE8E7E3);

  // Text Colors
  static const Color textDark = Color(0xFF1F5A3C);
  // Netral putih tulang agak abu — sebelumnya khaki (0xFFEDEBD9) yang
  // keliatan kehijauan di card/border/chip. Ini dipakai luas sebagai token
  // "neutral card" (fill/border) di Calendar, Summary Card, Riwayat Card,
  // dan filter chip, jadi diganti di satu tempat biar konsisten semua.
  static const Color textFieldBg = Color(0xFFE9E7E4);
  
  // Additional Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}