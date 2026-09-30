import 'package:flutter/material.dart';

/// App color palette matching reference UI (Soft Lavender & Pastel Palette)
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2E7D32); // Farming Accent Green
  static const Color primaryVariant = Color(0xFF1B5E20);
  static const Color secondary = Color(0xFF4A356A);
  
  // Lavender Theme Colors (matching image)
  static const Color background = Color(0xFFF3EFF7); // Soft lavender tinted background
  static const Color lightLavender = Color(0xFFE7DEF2); // Top bar & accents
  static const Color cardLavender = Color(0xFFE2D7F3); // Soft purple card
  static const Color cardRose = Color(0xFFF2CED8); // Soft dusty rose card
  static const Color cardMint = Color(0xFFE0EFE8); // Soft mint card
  static const Color darkPill = Color(0xFF2D233D); // Dark contrast pill / button
  
  static const Color surface = Colors.white;
  static const Color lavenderDarkText = Color(0xFF261C33);
  static const Color textPrimary = Color(0xFF261C33);
  static const Color textSecondary = Color(0xFF6B6278);
  static const Color error = Color(0xFFD32F2F);
}
