import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/common/add_to_intake_button.dart';
import 'package:read_the_label/views/widgets/common/date_selector.dart';
import 'package:read_the_label/views/widgets/common/energy_distribution_bar.dart';
import 'package:read_the_label/views/widgets/common/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/common/time_selector.dart';
import 'package:read_the_label/views/widgets/common/quantity_selector.dart';

class TotalNutrientsCard extends StatelessWidget {
  final String source;
  final String mealName;
  final FoodAnalysisResponse? foodAnalysis;
  final ProductAnalysisResponse? productAnalysis;
  final int numberOfFoodItems;
  final List<FoodNutrient> totalPlateNutrients;
  final List<Map<String, dynamic>> nutrientInfo;
  final File? foodImage;
  final bool showSaveOptions;

  const TotalNutrientsCard({
    super.key,
    required this.source,
    required this.mealName,
    this.foodAnalysis,
    this.productAnalysis,
    required this.numberOfFoodItems,
    required this.totalPlateNutrients,
    required this.nutrientInfo,
    this.foodImage,
    required this.showSaveOptions,
  });

  List<Map<String, dynamic>> _getAdjustedNutrientInfo(
      List<Map<String, dynamic>> originalInfo, double portion) {
    if (portion == 1.0) return originalInfo;

    final List<Map<String, dynamic>> adjusted = [];
    for (var item in originalInfo) {
      final Map<String, dynamic> copy = Map.from(item);
      final String name = item['name'] ?? '';
      final double qty =
          (item['quantity'] as num? ?? 0.0).toDouble() * portion;
      copy['quantity'] = qty;

      final matchingNutrient = nutrientDataMap[name];
      if (matchingNutrient != null) {
        double currentDV =
            double.parse(matchingNutrient['Current Daily Value'].toString());
        double fivePercentDV =
            double.parse(matchingNutrient['5%DV'].toString());
        double twentyPercentDV =
            double.parse(matchingNutrient['20%DV'].toString());
        String goal = matchingNutrient['Goal'].toString();

        double dailyValuePercent =
            double.parse(((qty / currentDV) * 100).toStringAsFixed(2));
        copy['daily_value'] = dailyValuePercent;

        String dvStatus;
        if (qty < fivePercentDV) {
          dvStatus = 'Low';
        } else if (qty > twentyPercentDV) {
          dvStatus = 'High';
        } else {
          dvStatus = 'Moderate';
        }
        copy['dv_status'] = dvStatus;

        String healthImpact;
        if ((dvStatus == "High" && goal == "At least") ||
            (dvStatus == "Low" && goal == "Less than")) {
          healthImpact = "Good";
        } else {
          healthImpact = "Bad";
        }
        copy['health_impact'] = healthImpact;
      } else {
        copy['daily_value'] =
            (item['daily_value'] as num? ?? 0.0).toDouble() * portion;
      }
      adjusted.add(copy);
    }
    return adjusted;
  }

  @override
  Widget build(BuildContext context) {
    print("🔴 TotalNutrientsCard: build() called - Stack trace:");
    print(StackTrace.current.toString().split('\n').take(10).join('\n'));

    final uiVm = context.watch<UiViewModel>();
    final portion = uiVm.portionMultiplier;
    final adjustedTotalNutrients =
        uiVm.calculateAdjustedNutrients(totalPlateNutrients);
    final adjustedNutrientInfo = _getAdjustedNutrientInfo(nutrientInfo, portion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppColors.primaryBlack,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final groupedNutrients = <String, List<Map<String, dynamic>>>{
                    "Limit": [],
                    "Insufficient": [],
                    "Moderate": [],
                    "Good": [],
                  };

                  for (var nutrient in adjustedNutrientInfo) {
                    final dvStatus = nutrient['dv_status'] ?? "";
                    final goal = nutrient['goal'] ?? "";

                    String category =
                        NutrientUtils.getNutrientCategory(dvStatus, goal);
                    groupedNutrients[category]!.add(nutrient);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildNutrientSection(
                        Icons.check_circle_rounded,
                        "OPTIMAL QUANTITY",
                        groupedNutrients["Good"]!,
                        AppColors.secondaryGreen,
                      ),
                      ..._buildNutrientSection(
                        Icons.info_rounded,
                        "MODERATE QUANTITY",
                        groupedNutrients["Moderate"]!,
                        AppColors.secondaryOrange,
                      ),
                      ..._buildNutrientSection(
                        Icons.warning_outlined,
                        "EXCESSIVE QUANTITY",
                        groupedNutrients["Limit"]!,
                        AppColors.secondaryRed,
                      ),
                      ..._buildNutrientSection(
                        Icons.warning_outlined,
                        "LIMITED QUANTITY",
                        groupedNutrients["Insufficient"]!,
                        AppColors.secondaryRed,
                      ),
                    ],
                  );
                },
              ),
              EnergyDistributionBar(originalNutrients: adjustedTotalNutrients),
              if (showSaveOptions) ...[
                const DateSelector(),
                const TimeSelector(),
                const QuantitySelector(),
                AddToIntakeButton(
                  source: source,
                  foodAnalysis: foodAnalysis,
                  mealName: mealName,
                  totalPlateNutrients: totalPlateNutrients,
                  foodImage: foodImage,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNutrientSection(
    IconData icon,
    String title,
    List<Map<String, dynamic>> nutrients,
    Color color,
  ) {
    if (nutrients.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 4),
        child: Row(
          spacing: 5,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLargeBold
                  .copyWith(color: color, letterSpacing: -1.0),
            ),
            Icon(
              icon,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: nutrients
              .map((nutrient) => NutrientTile(
                    nutrient: nutrient['name'],
                    dvStatus: nutrient['dv_status'],
                    goal: nutrient['goal'],
                    healthSign: nutrient['health_impact'],
                    quantity: nutrient['quantity'],
                    unit: nutrient['unit'],
                    insight: nutrientInsights[nutrient['name']],
                    dailyValue: nutrient['daily_value'],
                  ))
              .toList(),
        ),
      ),
    ];
  }
}
