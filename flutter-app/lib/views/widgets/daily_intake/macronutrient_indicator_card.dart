import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/daily_intake/macronutrient_indicator.dart';

class MacronutrientsIndicatorCard extends StatelessWidget {
  const MacronutrientsIndicatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('REBUILD: MacronutrientsIndicatorCard');
    final protein = context.select(
      (DailyIntakeViewModel vm) => vm.totalNutrients?[AppConstants.protein],
    );
    final carbs = context.select(
      (DailyIntakeViewModel vm) => vm.totalNutrients?[AppConstants.totalCarbohydrate],
    );
    final fat = context.select(
      (DailyIntakeViewModel vm) => vm.totalNutrients?[AppConstants.totalFat],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      spacing: 10,
      children: [
        MacronutrientIndicator(
          label: 'Protein',
          nutrientName: AppConstants.protein,
          value: protein?.quantity.value ?? 0.0,
          goal: 50.0,
          iconAsset: 'assets/icons/protein_icon.png',
          color: AppColors.limeGreen,
        ),
        MacronutrientIndicator(
          label: 'Carbs',
          nutrientName: AppConstants.totalCarbohydrate,
          value: carbs?.quantity.value ?? 0.0,
          goal: 275.0,
          iconAsset: 'assets/icons/carbs_icon.png',
          color: AppColors.yellow,
        ),
        MacronutrientIndicator(
          label: 'Fat',
          nutrientName: AppConstants.totalFat,
          value: fat?.quantity.value ?? 0.0,
          goal: 78.0,
          iconAsset: 'assets/icons/fat_icon.png',
          color: AppColors.amberOrange,
        ),
      ],
    );
  }
}
