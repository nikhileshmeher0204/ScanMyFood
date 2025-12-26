import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class AddToIntakeButton extends StatelessWidget {
  final String mealName;
  final Map<String, Quantity> totalPlateNutrients;
  final File? foodImage;

  const AddToIntakeButton({
    super.key,
    required this.mealName,
    required this.totalPlateNutrients,
    required this.foodImage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final uiProvider = context.read<UiViewModel>();
        final dailyIntakeProvider = context.read<DailyIntakeViewModel>();

        final adjustedNutrients =
            uiProvider.calculateAdjustedNutrients(totalPlateNutrients);

        print("Add to today's intake button pressed");
        print("Current total nutrients: $totalPlateNutrients");

        dailyIntakeProvider.addMealToDailyIntake(
          mealName: mealName,
          totalPlateNutrients: adjustedNutrients,
          foodImage: foodImage,
        );

        uiProvider.updateCurrentIndex(2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to daily intake'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Add to today\'s intake'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryBlack,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
