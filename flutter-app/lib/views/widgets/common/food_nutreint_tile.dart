import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class FoodNutrientTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final String? iconPath;
  final Color? dominantColor;

  const FoodNutrientTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconPath,
    this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDynamic = dominantColor != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.black.withValues(alpha: 0.15)
            : AppColors.primaryBlack,
        borderRadius: BorderRadius.circular(12),
        border: isDynamic
            ? Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Align(
              alignment: Alignment.centerRight,
              child: iconPath != null
                  ? Image.asset(
                      iconPath!,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      color: isDynamic
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.secondaryGreen,
                      size: 16,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: isDynamic
                      ? AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        )
                      : AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '$value $unit',
                  style: isDynamic
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        )
                      : AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
