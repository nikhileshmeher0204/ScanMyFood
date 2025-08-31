import 'package:flutter/material.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class EnergyDistributionBar extends StatelessWidget {
  final Map<String, dynamic> nutrients;

  const EnergyDistributionBar({
    super.key,
    required this.nutrients,
  });

  @override
  Widget build(BuildContext context) {
    final protein = nutrients['protein'] ?? 0.0;
    final carbs = nutrients['carbohydrates'] ?? 0.0;
    final fat = nutrients['fat'] ?? 0.0;

    // Calculate calories from each macronutrient
    final proteinCals = protein * 4;
    final carbsCals = carbs * 4;
    final fatCals = fat * 9;
    final totalCals = proteinCals + carbsCals + fatCals;

    if (totalCals == 0) {
      return const SizedBox.shrink();
    }

    // Calculate percentages
    final proteinPercent = (proteinCals / totalCals * 100);
    final carbsPercent = (carbsCals / totalCals * 100);
    final fatPercent = (fatCals / totalCals * 100);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Energy Distribution (${nutrients['calories'] ?? 0.0} kcal)',
            style: AppTextStyles.bodyLargeBold.copyWith(
              color: AppColors.primaryWhite,
            ),
          ),
          const SizedBox(height: 12),

          // Top labels (Protein and Fat)
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${proteinPercent.round()}% Protein',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.secondaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${fatPercent.round()}% Fat',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.secondaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Progress bar
          Container(
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.divider,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // Protein section
                  if (proteinPercent > 0)
                    Expanded(
                      flex: proteinPercent.round(),
                      child: Container(
                        color: AppColors.secondaryGreen,
                      ),
                    ),

                  // Carbs section
                  if (carbsPercent > 0)
                    Expanded(
                      flex: carbsPercent.round(),
                      child: Container(
                        color: AppColors.secondaryYellow,
                      ),
                    ),

                  // Fat section
                  if (fatPercent > 0)
                    Expanded(
                      flex: fatPercent.round(),
                      child: Container(
                        color: AppColors.secondaryOrange,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Carbohydrate label at bottom
          Center(
            child: Text(
              '${carbsPercent.round()}% Carbohydrate',
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.secondaryYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}