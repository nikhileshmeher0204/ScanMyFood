import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class EnergyDistributionBar extends StatelessWidget {
  final Map<String, Quantity> originalNutrients;

  const EnergyDistributionBar({
    super.key,
    required this.originalNutrients,
  });

  @override
  Widget build(BuildContext context) {
    final protein = originalNutrients['protein']?.value ?? 0.0;
    final carbs = originalNutrients['carbohydrates']?.value ?? 0.0;
    final fat = originalNutrients['fat']?.value ?? 0.0;

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
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Selector<UiViewModel, double>(
            selector: (context, uiViewModel) => uiViewModel.portionMultiplier,
            builder: (context, portionMultiplier, child) {
              final uiViewModel =
                  Provider.of<UiViewModel>(context, listen: false);
              final adjustedNutrients =
                  uiViewModel.calculateAdjustedNutrients(originalNutrients);

              // Safe access to calories value with null checks
              final caloriesQuantity =
                  adjustedNutrients['calories']?.value ?? 0.0;
              final caloriesValue = caloriesQuantity;

              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Energy Distribution • ',
                      style: AppTextStyles.bodyLargeBold,
                    ),
                    TextSpan(
                      text: '${caloriesValue.toStringAsFixed(0)} ',
                      style: AppTextStyles.bodyLargeBold,
                    ),
                    TextSpan(
                      text: 'kcal',
                      style: AppTextStyles.bodyLargeBold
                          .copyWith(color: AppColors.secondaryBlackTextColor),
                    ),
                  ],
                ),
              );
            },
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
