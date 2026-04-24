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

  // Apple system dark-mode colors (HIG)
  // https://developer.apple.com/design/human-interface-guidelines/color
  static const Color appleLabel = Color(0xFFFFFFFF);                        // label
  static const Color appleSecondaryLabel = Color.fromRGBO(235, 235, 245, 0.6); // secondaryLabel
  static const Color appleTertiaryLabel = Color.fromRGBO(235, 235, 245, 0.3);  // tertiaryLabel
  static const Color appleQuaternaryLabel = Color.fromRGBO(235, 235, 245, 0.18); // quaternaryLabel
  static const Color appleSeparator = Color.fromRGBO(84, 84, 88, 0.6);     // separator
  static const Color appleIconUnselected = Color.fromRGBO(255, 255, 255, 0.38); // icon unselected tint
  static const Color appleCheckmarkUnselected = Color.fromRGBO(255, 255, 255, 0.24); // unchecked circle
  static const Color appleHighlight = Color.fromRGBO(255, 255, 255, 0.04); // cell press highlight
  static const Color appleGroupedBackground = Color(0xFF1C1C1E);            // systemGroupedBackground

  static Color getTitleColor(Color bg) {
    final luminance = bg.computeLuminance();

    if (luminance < 0.45) {
      final isWarm = bg.red > bg.blue;

      return isWarm
          ? const Color(0xFFFFFAF5).withOpacity(0.96) // warm white
          : const Color(0xFFF5F9FF).withOpacity(0.96); // cool white
    }

    return const Color(0xFF111111).withOpacity(0.9);
  }

  static Color getSubtitleColor(Color bg) {
    final luminance = bg.computeLuminance();

    // Dark backgrounds (most food cards)
    if (luminance < 0.45) {
      // Adjust tint based on warmth of color
      final isWarm = bg.red > bg.blue;

      if (isWarm) {
        // Brown / warm food → slightly warm white
        return const Color(0xFFFFF1E6).withOpacity(0.9);
      } else {
        // Cool backgrounds → cool white (Apple style)
        return const Color(0xFFEAF2FF).withOpacity(0.88);
      }
    }

    // Light backgrounds
    return const Color(0xFF1A1A1A).withOpacity(0.75);
  }
}
