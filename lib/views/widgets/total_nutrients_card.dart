import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class TotalNutrientsCard extends StatelessWidget {
  const TotalNutrientsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Nutrients',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.watch<MealAnalysisViewModel>().analyzedFoodItems.length} items',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.cardBackground,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildNutrientRow(
                    context,
                    'Calories',
                    context
                            .read<MealAnalysisViewModel>()
                            .totalPlateNutrients['calories'] ??
                        0,
                    'kcal',
                    Icons.local_fire_department_outlined),
                _buildNutrientRow(
                    context,
                    'Protein',
                    context
                            .read<MealAnalysisViewModel>()
                            .totalPlateNutrients['protein'] ??
                        0,
                    'g',
                    Icons.fitness_center_outlined),
                _buildNutrientRow(
                    context,
                    'Carbohydrates',
                    context
                            .read<MealAnalysisViewModel>()
                            .totalPlateNutrients['carbohydrates'] ??
                        0,
                    'g',
                    Icons.grain_outlined),
                _buildNutrientRow(
                    context,
                    'Fat',
                    context
                            .read<MealAnalysisViewModel>()
                            .totalPlateNutrients['fat'] ??
                        0,
                    'g',
                    Icons.opacity_outlined),
                _buildNutrientRow(
                    context,
                    'Fiber',
                    context
                            .read<MealAnalysisViewModel>()
                            .totalPlateNutrients['fiber'] ??
                        0,
                    'g',
                    Icons.grass_outlined,
                    isLast: true),
                ElevatedButton.icon(
                  onPressed: () {
                    final uiProvider =
                        Provider.of<UiViewModel>(context, listen: false);
                    final mealAnalysisProvider =
                        Provider.of<MealAnalysisViewModel>(context,
                            listen: false);
                    final dailyIntakeProvider =
                        Provider.of<DailyIntakeViewModel>(context,
                            listen: false);
                    print("Add to today's intake button pressed");
                    print(
                        "Current total nutrients: ${mealAnalysisProvider.totalPlateNutrients}");
                    dailyIntakeProvider.addMealToDailyIntake(
                      mealName: mealAnalysisProvider.mealName,
                      totalPlateNutrients:
                          mealAnalysisProvider.totalPlateNutrients,
                      foodImage: mealAnalysisProvider.foodImage,
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
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
      BuildContext context, String label, num value, String unit, IconData icon,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(child: Container()),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
      ],
    );
  }
}
