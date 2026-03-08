import 'package:flutter/material.dart';


/// Color palette for the Vantaq app
/// 3-tier color system: Primary, Secondary, and Accent colors
class AppColors {
  // Primary Color Palette
  static const Color primary = Color(0xFF08A10E); // Primary (Green)
  static const Color primaryLight = Color(0xFF4DA3FF);
  static const Color primaryDark = Color(0xFF0056CC);
  static const Color primaryPurple = Color(0xFF8E27F5);

  // Secondary Color Palette
  static const Color secondary = Color(0xFFFF6B35); // Orange
  static const Color secondaryLight = Color(0xFFFF8A5C);
  static const Color secondaryDark = Color(0xFFCC4C28);
  static const Color lightGray = Color(0xFFABABAB);

  // Accent Color Palette
  static const Color accent = Color(0xFF00D4AA); // Teal
  static const Color accentLight = Color(0xFF33E0C4);
  static const Color accentDark = Color(0xFF00A885);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Gray Scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Background Colors
  static const Color backgroundLight = white;
  static const Color backgroundDark = white; // White for dark theme
  static const Color surfaceLight = white;
  static const Color surfaceDark = white; // White for dark theme

  // Text Colors
  static const Color textPrimaryLight = gray900;
  static const Color textSecondaryLight = gray600;
  static const Color textPrimaryDark = gray50;
  static const Color textSecondaryDark = gray400;

  // Helper methods to get colors based on brightness
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.light ? backgroundLight : backgroundDark;
  }

  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.light ? surfaceLight : surfaceDark;
  }

  static Color getTextPrimaryColor(Brightness brightness) {
    return brightness == Brightness.light ? textPrimaryLight : textPrimaryDark;
  }

  static Color getTextSecondaryColor(Brightness brightness) {
    return brightness == Brightness.light ? textSecondaryLight : textSecondaryDark;
  }

  // Method to get color from hex string (for dynamic theming)
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
