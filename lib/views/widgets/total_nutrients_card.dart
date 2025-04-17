import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/views/widgets/food_nutreint_tile.dart';

class TotalNutrientsCard extends StatelessWidget {
  const TotalNutrientsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: GridView.count(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3.0,
        children: [
          FoodNutrientTile(
            label: 'Calories',
            value:
                "${context.read<MealAnalysisViewModel>().totalPlateNutrients['calories'] ?? 0}",
            unit: 'kcal',
            icon: Assets.icons.icCalories.path,
            color: const Color(0xff6BDE36),
          ),
          FoodNutrientTile(
            label: 'Protein',
            value:
                "${context.read<MealAnalysisViewModel>().totalPlateNutrients['protein'] ?? 0}",
            unit: 'g',
            icon: Assets.icons.icProtein.path,
            color: const Color(0xffFFAF40),
          ),
          FoodNutrientTile(
            label: 'Carbohydrates',
            value:
                "${context.read<MealAnalysisViewModel>().totalPlateNutrients['carbohydrates'] ?? 0}",
            unit: 'g',
            icon: Assets.icons.icCarbonHydrates.path,
            color: const Color(0xff6B25F6),
          ),
          FoodNutrientTile(
            label: 'Fat',
            value:
                "${context.read<MealAnalysisViewModel>().totalPlateNutrients['fat'] ?? 0}",
            unit: 'g',
            icon: Assets.icons.icFat.path,
            color: const Color(0xffFF3F42),
          ),
          FoodNutrientTile(
            label: 'Fiber',
            value:
                "${context.read<MealAnalysisViewModel>().totalPlateNutrients['fiber'] ?? 0}",
            unit: 'g',
            icon: Assets.icons.icFiber.path,
            color: const Color(0xff1CAE54),
          ),
        ],
      ),
    );
  }
}
