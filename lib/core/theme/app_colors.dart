import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0057FF);
  static const Color primaryLight = Color(0xFF4D8EFF);
  static const Color primaryDark = Color(0xFF003DB3);

  static const Color emergency1 = Color(0xFFFF3B30);
  static const Color emergency2 = Color(0xFFFF9500);
  static const Color emergency3 = Color(0xFF34C759);

  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0A1628);
  static const Color textSecondary = Color(0xFF6B7A99);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color lightGrey = Color(0xFFE5E7EB);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient darkBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static Color getEmergencyColor(int level) {
    switch (level) {
      case 1:
        return emergency1;
      case 2:
        return emergency2;
      case 3:
        return emergency3;
      default:
        return primary;
    }
  }

  static Color getEmergencyBackgroundColor(int level) {
    switch (level) {
      case 1:
        return emergency1.withOpacity(0.1);
      case 2:
        return emergency2.withOpacity(0.1);
      case 3:
        return emergency3.withOpacity(0.1);
      default:
        return primary.withOpacity(0.1);
    }
  }
}
