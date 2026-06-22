import 'package:flutter/material.dart';

/// Centralized color palette for the Ultraquad ERP app.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF0A1F44);
  static const Color navyLight = Color(0xFF15315E);
  static const Color teal = Color(0xFF0FA3A3);
  static const Color mint = Color(0xFF6FFFB0);
  static const Color red = Color(0xFFE5484D);
  static const Color green = Color(0xFF2ECC71);

  /// Warm accent used for highlights and quick-action emphasis —
  /// deliberately not another shade of blue.
  static const Color amber = Color(0xFFE0A33C);
  static const Color amberDeep = Color(0xFFB97F1F);

  /// Warm off-white background instead of a cool gray, so the app
  /// doesn't read as generic "AI blue/white".
  static const Color background = Color(0xFFFAF6F0);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFFFFBF5);
  static const Color textPrimary = Color(0xFF211B14);
  static const Color textSecondary = Color(0xFF6E6458);
  static const Color border = Color(0xFFE8E0D4);
  static const Color shadow = Color(0x14211B14);
}
