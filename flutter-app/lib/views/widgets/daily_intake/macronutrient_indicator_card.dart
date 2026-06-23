import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/widgets/daily_intake/macronutrient_indicator.dart';

class MacronutrientsIndicatorCard extends StatelessWidget {
  const MacronutrientsIndicatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('REBUILD: MacronutrientsIndicatorCard');
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      spacing: 10,
      children: [
        MacronutrientIndicator(
          label: 'Protein',
          nutrientName: AppConstants.protein,
          goal: 50.0,
          iconAsset: 'assets/icons/protein_icon.png',
          color: AppColors.limeGreen,
        ),
        MacronutrientIndicator(
          label: 'Carbs',
          nutrientName: AppConstants.totalCarbohydrate,
          goal: 275.0,
          iconAsset: 'assets/icons/carbs_icon.png',
          color: AppColors.yellow,
        ),
        MacronutrientIndicator(
          label: 'Fat',
          nutrientName: AppConstants.totalFat,
          goal: 78.0,
          iconAsset: 'assets/icons/fat_icon.png',
          color: AppColors.amberOrange,
        ),
      ],
    );
  }
}
