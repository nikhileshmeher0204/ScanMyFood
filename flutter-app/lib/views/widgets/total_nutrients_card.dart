import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/widgets/add_to_intake_button.dart';
import 'package:read_the_label/views/widgets/energy_distribution_bar.dart';
import 'package:read_the_label/views/widgets/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/input_picker_button.dart';
import 'package:read_the_label/views/widgets/quantity_selector.dart';

class TotalNutrientsCard extends StatelessWidget {
  final String mealName;
  final int numberOfFoodItems;
  final Map<String, dynamic> totalPlateNutrients;
  final List<Map<String, dynamic>> nutrientInfo;

  const TotalNutrientsCard({
    super.key,
    required this.mealName,
    required this.numberOfFoodItems,
    required this.totalPlateNutrients,
    required this.nutrientInfo,
  });

  @override
  Widget build(BuildContext context) {
    print("🔴 TotalNutrientsCard: build() called - Stack trace:");
    print(StackTrace.current.toString().split('\n').take(10).join('\n'));

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Nutrients', style: AppTextStyles.heading2),
                      const SizedBox(height: 4),
                      if (numberOfFoodItems != 0)
                        Text('$numberOfFoodItems items',
                            style: AppTextStyles.bodyLarge),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primaryWhite,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    children: nutrientInfo
                        .map((nutrient) => NutrientTile(
                              nutrient: nutrient['name'],
                              dvStatus: nutrient['dv_status'],
                              goal: nutrient['goal'],
                              healthSign: nutrient['health_impact'],
                              quantity: nutrient['quantity'],
                              insight: nutrientInsights[nutrient['name']],
                              dailyValue: nutrient['daily_value'],
                            ))
                        .toList(),
                  ),
                ),
                EnergyDistributionBar(originalNutrients: totalPlateNutrients),
                const InputPickerButton(
                  label: "Time",
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.restaurant,
                          color: AppColors.secondaryBlackTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Quantity",
                          style: AppTextStyles.withColor(
                            AppTextStyles.heading4,
                            AppColors.primaryWhite,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: QuantitySelector(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AddToIntakeButton(
                  mealName: mealName,
                  totalPlateNutrients: totalPlateNutrients,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
