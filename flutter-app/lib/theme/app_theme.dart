// Create a dedicated theme file:
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      fontFamily: AppTextStyles.fontFamily,
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        background: AppColors.surface,
        onBackground: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.black),
        labelMedium: TextStyle(color: Colors.black),
      ),
    );
  }
}

// Extension for custom colors
extension CustomColors on ColorScheme {
  Color get accent => const Color(0xFF61DAFB);
  Color get neutral => const Color(0xFF808080);
  Color get success => const Color(0xFF4CAF50);
  Color get warning => const Color(0xFFFFA726);
  Color get info => const Color(0xFF29B6F6);
  Color get background => const Color(0xFF121212);
  Color get cardBackground => const Color(0xFF1E1E1E);
  Color get divider => const Color(0xFF2D2D2D);
}
