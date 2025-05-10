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
        primary: AppColors.primaryBlack,
        onPrimary: AppColors.primaryWhite,
        secondary: AppColors.secondaryGreen,
        onSecondary: AppColors.primaryBlack,
        error: AppColors.secondaryRed,
        onError: AppColors.primaryWhite,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(color: AppColors.textPrimary),
        titleMedium: TextStyle(color: AppColors.textPrimary),
        titleSmall: TextStyle(color: AppColors.textPrimary),
        labelLarge: TextStyle(color: AppColors.primaryBlack),
        labelMedium: TextStyle(color: AppColors.primaryBlack),
      ),
    );
  }
}

// Extension for custom colors
extension CustomColors on ColorScheme {
  Color get accent => AppColors.accent;
  Color get neutral => const Color(0xFF808080);
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get info => const Color(0xFF29B6F6);
  Color get background => AppColors.background;
  Color get cardBackground => AppColors.cardBackground;
  Color get divider => AppColors.divider;
}
