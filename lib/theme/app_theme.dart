// Create a dedicated theme file:
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      fontFamily: AppTextStyles.fontFamily,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
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
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.onSurface,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

// Extension for custom colors
extension CustomColors on ColorScheme {
  Color get accent => AppColors.accent;
  Color get neutral => AppColors.iconColor;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;
  Color get cardBackground => AppColors.cardBackground;
  Color get divider => AppColors.divider;
  Color get inputBackground => AppColors.inputBackground;
  Color get inputBorder => AppColors.inputBorder;
}
