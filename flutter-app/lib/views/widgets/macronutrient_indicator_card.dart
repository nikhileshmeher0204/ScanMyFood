import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/widgets/macronutrient_indicator.dart';

class MacronutrientsIndicatorCard extends StatelessWidget {
  final Map<String, FoodNutrient> totalNutrients;
  const MacronutrientsIndicatorCard({super.key, required this.totalNutrients});

  @override
  Widget build(BuildContext context) {
    final FoodNutrient? protein = totalNutrients[AppConstants.protein];
    final FoodNutrient? carbs = totalNutrients[AppConstants.totalCarbohydrate];
    final FoodNutrient? fat = totalNutrients[AppConstants.totalFat];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      spacing: 10,
      children: [
        MacronutrientIndicator(
          label: 'Protein',
          value: protein?.quantity.value ?? 0.0,
          goal: 50.0,
          icon: Icons.fitness_center,
          color: AppColors.secondaryGreen,
        ),
        MacronutrientIndicator(
          label: 'Carbs',
          value: carbs?.quantity.value ?? 0.0,
          goal: 275.0,
          icon: Icons.grain,
          color: AppColors.secondaryYellow,
        ),
        MacronutrientIndicator(
          label: 'Fat',
          value: fat?.quantity.value ?? 0.0,
          goal: 78.0,
          icon: Icons.opacity,
          color: AppColors.secondaryOrange,
        ),
      ],
    );
  }
}
