import 'package:flutter/material.dart';

/// Semua warna brand Study Buddy berdasarkan design system HTML mockup
class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF2E86DE);
  static const Color blueDark = Color(0xFF1A5EAA);
  static const Color blueLight = Color(0xFF5BA4F5);
  static const Color primaryRed = Color(0xFFE63946);
  static const Color redLight = Color(0xFFFF6B74);
  static const Color primaryYellow = Color(0xFFF4A200);
  static const Color yellowLight = Color(0xFFFFD166);
  static const Color onlineGreen = Color(0xFF22C55E);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentTeal = Color(0xFF0891B2);

  static const Color background = Color(0xFFF0F4FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1F3C);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7F0);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueDark, primaryBlue, blueLight],
  );
}
