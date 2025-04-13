import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1CAE54); // Green primary color
  static const Color secondary = Color(0xFFFFAF40); // Orange secondary color
  static const Color accent = Color(0xFF27AE60); // Darker green for accents

  // Surface colors
  static const Color surface = Color(0xffF5F5F5);
  static const Color cardBackground = Colors.white; // White card background
  static const Color divider = Color(0xFFE0E0E0); // Light gray divider

  static const Color green = Color(0xFF1CAE54);
  static const Color yellow = Color(0xFFFFAF40);
  static const Color red = Color(0xFFFF1919);
  static const Color grey = Color(0xFF6B6B6B);

  // Semantic colors
  static Color success =
      const Color(0xFF1CAE54).withOpacity(0.1); // Green success
  static Color error = const Color(0xFFFF1919).withOpacity(0.1); // Red error
  static Color warning =
      const Color(0xFFFF9D00).withOpacity(0.1); // Orange warning
  static const Color info = Color(0xFF3498DB); // Blue info

  // Text colors
  static const Color onPrimary = Colors.white; // White text on primary
  static const Color onSurface = Color(0xFF2D3436); // Dark gray text
  static const Color onBackground = Color(0xFF2D3436); // Dark gray text

  // Additional colors
  static const Color inputBackground =
      Color(0xFFF5F6FA); // Light gray input background
  static const Color inputBorder = Color(0xFFE0E0E0); // Light gray border
  static const Color iconColor = Color(0xFF2D3436); // Dark gray icons
}
