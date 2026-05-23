import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class MacronutrientIndicator extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final IconData icon;
  final Color color;

  const MacronutrientIndicator({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value / goal).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryWhite.withOpacity(0.8),
                  ),
                ),
                Icon(Icons.more_horiz,
                    color: AppColors.primaryWhite.withOpacity(0.6)),
              ],
            ),
            Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${value.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          color: AppColors.primaryWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${goal.toStringAsFixed(0)}g',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryWhite.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: AppColors.primaryWhite.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
