import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class AddToIntakeButton extends StatelessWidget {
  final String source;
  final FoodAnalysisResponse? foodAnalysis;
  final ProductAnalysisResponse? productAnalysis;
  final String mealName;
  final List<FoodNutrient> totalPlateNutrients;
  final File? foodImage;

  const AddToIntakeButton({
    super.key,
    required this.source,
    this.foodAnalysis,
    this.productAnalysis,
    required this.mealName,
    required this.totalPlateNutrients,
    required this.foodImage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final uiProvider = context.read<UiViewModel>();
        final dailyIntakeProvider = context.read<DailyIntakeViewModel>();
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = authService.currentUser;

        final List<FoodNutrient> adjustedNutrients =
            uiProvider.calculateAdjustedNutrients(totalPlateNutrients);
        foodAnalysis?.totalPlateNutrients = adjustedNutrients;

        print("Add to today's intake button pressed");
        print("Current total nutrients: $totalPlateNutrients");
        print("foodAnalysis: $foodAnalysis");

        try {
          //save intake based on source
          if (source == AppConstants.scanMeal ||
              source == AppConstants.scanDescription) {
            await dailyIntakeProvider.saveScannedFood(
                user!.uid, foodImage, source, foodAnalysis);
          } else if (source == AppConstants.scanLabel) {
            await dailyIntakeProvider.saveScannedLabel(
                user!.uid, foodImage, source, productAnalysis);
          }
          //get Daily Intake after saving
          await dailyIntakeProvider.getDailyIntake(user!.uid, DateTime.now());

          // If source is description, generate image after saving intake
          if (source == AppConstants.scanDescription) {
            dailyIntakeProvider.setIsImageGenerating(true);
            await dailyIntakeProvider.aiRepository.generateIntakeImage(
                dailyIntakeProvider.descriptionText,
                dailyIntakeProvider.saveIntakeOutput!.dailyIntakeId);
            dailyIntakeProvider.setIsImageGenerating(false);
            // Refresh daily intake to get updated image
            await dailyIntakeProvider.getDailyIntake(user.uid, DateTime.now());
          }
          uiProvider.updateCurrentIndex(2);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to daily intake'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving intake: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
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
