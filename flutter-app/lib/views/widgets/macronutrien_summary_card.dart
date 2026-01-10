import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_nutrient.dart';

class MacronutrientSummaryCard extends StatelessWidget {
  final Map<String, FoodNutrient> totalNutrients;
  const MacronutrientSummaryCard({super.key, required this.totalNutrients});

  @override
  Widget build(BuildContext context) {
    final FoodNutrient? calories = totalNutrients[AppConstants.calories];
    final FoodNutrient? protein = totalNutrients[AppConstants.protein];
    final FoodNutrient? carbs = totalNutrients[AppConstants.totalCarbohydrate];
    final FoodNutrient? fat = totalNutrients[AppConstants.totalFat];
    const calorieGoal = 2000.0;
    final caloriePercent = (calories?.quantity.value ?? 0) / calorieGoal;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    '${calories?.quantity.value ?? 0} / ${calorieGoal.toStringAsFixed(0)} kcal',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: CircularProgressIndicator(
                      value: caloriePercent,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(caloriePercent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacronutrientIndicator(
                'Protein',
                protein?.quantity.value ?? 0.0,
                50.0,
                Icons.fitness_center,
              ),
              _buildMacronutrientIndicator(
                'Carbs',
                carbs?.quantity.value ?? 0.0,
                275.0,
                Icons.grain,
              ),
              _buildMacronutrientIndicator(
                'Fat',
                fat?.quantity.value ?? 0.0,
                78.0,
                Icons.opacity,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildMacronutrientIndicator(
  String label,
  double value,
  double goal,
  IconData icon,
) {
  final percent = (value / goal).clamp(0.0, 1.0);
  return Column(
    spacing: 4,
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${value.toStringAsFixed(1)}g',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            ' / ${goal.toStringAsFixed(1)}g',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
      SizedBox(
        height: 6,
        width: 80,
        child: LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 5,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ],
  );
}
