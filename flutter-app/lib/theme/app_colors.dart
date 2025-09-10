import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryBlack = Color(0xFF000000);

  // Primary colors for text styles
  static const Color primaryBlackTextColor = Colors.black;
  static const Color secondaryBlackTextColor = Colors.white54;
  static const Color accentTextColor = Color(0xFF9ACD32); // Lime green accent

  // Material Theme mappings
  static const Color onPrimary = primaryWhite;
  static const Color secondary = secondaryGreen;
  static const Color onSecondary = primaryBlack;
  static const Color tertiaryPurple = Color(0xFF6e30b0);
  static const Color onTertiary = primaryWhite;
  static const Color error = secondaryRed;
  static const Color onError = primaryWhite;
  static const Color onBackground = primaryWhite;
  static const Color onSurface = primaryWhite;

  // Secondary Colors
  static const Color secondaryYellow = Color(0xFFECCD01);
  static const Color secondaryGreen = Color(0xFF9ACD32);
  static const Color secondaryOrange = Color(0xFFFFA500);
  static const Color secondaryRed = Color(0xFFDF303A);
  static const Color onSecondaryContainer = Color(0xFF6B990D);

  // UI Colors - derived from primary/secondary
  static const Color background = primaryBlack;
  static const Color surface = primaryBlack;
  static const Color textPrimary = primaryWhite;
  static const Color textSecondary = Color(0xB3FFFFFF); // White with opacity

  // Accent/Brand Color
  static const Color accent = secondaryGreen;

  // State Colors
  static const Color success = secondaryGreen;
  static const Color warning = secondaryYellow;

  // Additional UI element colors
  static const Color divider = Color(0xFF2C2C2C);
  static const Color cardBackground = Color.fromARGB(255, 16, 16, 22);
  static const Color onCardBackground = Color.fromARGB(255, 38, 38, 38);

  static const Color inputBackground = Color(0xFF1A1A1A);
}
