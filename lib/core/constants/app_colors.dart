import 'package:flutter/material.dart';

class AppColors {
  // Primary Sushi Man Colors
  static const Color primaryRed = Color(0xFF8B1538);
  static const Color darkRed = Color(0xFF6B0F29);
  static const Color burgundy = Color(0xFF4A0E1F);
  static const Color accent = Color(0xFFD4AF37); // Gold accent

  // Background
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF252525);
  static const Color lightCard = Color(0xFF2D2D2D);

  // Text
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color textSecondary = Color(0xFFB0B0B0); // Alias for secondaryText
  static const Color hintText = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF29B6F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, darkRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, burgundy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBackground, lightCard],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
