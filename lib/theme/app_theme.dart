import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Modern Tanzanian Theme
  static const Color primaryColor = Color(0xFF1B5E20); // Deep Green
  static const Color primaryLight = Color(0xFF4CAF50); // Light Green
  static const Color primaryDark = Color(0xFF0D3F0F); // Dark Green
  static const Color accentColor = Color(0xFFFF6B35); // Orange Accent
  static const Color secondaryColor = Color(0xFF2E7D32); // Medium Green

  // Light Theme Colors
  static const Color lightScaffoldBackground = Color(0xFFF8FAFB);
  static const Color lightCardBackground = Colors.white;
  static const Color lightSurfaceColor = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Dark Theme Colors
  static const Color darkScaffoldBackground = Color(0xFF0F172A);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkSurfaceColor = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFB);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryColor,
      primaryLight,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFB),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor,
      Color(0xFFFF8F65),
    ],
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightScaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F5F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightTextSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkScaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF253140),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextTertiary),
        labelStyle: TextStyle(color: darkTextPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  // Static getters for backward compatibility
  static Color get scaffoldBackground => lightScaffoldBackground;
  static Color get cardBackground => lightCardBackground;
  static Color get surfaceColor => lightSurfaceColor;
  static Color get textPrimary => lightTextPrimary;
  static Color get textSecondary => lightTextSecondary;
  static Color get textTertiary => lightTextTertiary;

  // Dynamic getters based on theme mode
  static Color getScaffoldBackground(bool isDark) =>
      isDark ? darkScaffoldBackground : lightScaffoldBackground;
  static Color getCardBackground(bool isDark) =>
      isDark ? darkCardBackground : lightCardBackground;
  static Color getSurfaceColor(bool isDark) =>
      isDark ? darkSurfaceColor : lightSurfaceColor;
  static Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color getTextTertiary(bool isDark) =>
      isDark ? darkTextTertiary : lightTextTertiary;
}
