import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/nutrient_row.dart';
import 'package:read_the_label/views/widgets/portion_buttons.dart';

class TotalNutrientsCard extends StatefulWidget {
  final String mealName;
  final int numberOfFoodItems;
  final Map<String, dynamic> totalPlateNutrients;

  const TotalNutrientsCard({
    super.key,
    required this.mealName,
    required this.numberOfFoodItems,
    required this.totalPlateNutrients,
  });

  @override
  State<TotalNutrientsCard> createState() => _TotalNutrientsCardState();
}

class _TotalNutrientsCardState extends State<TotalNutrientsCard> {
  late double _portionMultiplier;
  late Map<String, dynamic> _adjustedNutrients;
  @override
  void initState() {
    super.initState();
    _portionMultiplier = 1.0;
    _adjustedNutrients = Map<String, dynamic>.from(widget.totalPlateNutrients);
  }

  void _updatePortion(double multiplier) {
    setState(() {
      _portionMultiplier = multiplier;
      _adjustedNutrients = _calculateAdjustedNutrients(multiplier);
    });
  }

  Map<String, dynamic> _calculateAdjustedNutrients(double multiplier) {
    final Map<String, dynamic> result = {};
    widget.totalPlateNutrients.forEach((key, value) {
      if (value is num) {
        result[key] = value * multiplier;
      } else {
        result[key] = value;
      }
    });
    return result;
  }

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
                      if (widget.numberOfFoodItems != 0)
                        Text(
                          '${widget.numberOfFoodItems} items',
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
                NutrientRow(
                  label: 'Calories',
                  value: _adjustedNutrients['calories'] ?? 0,
                  unit: 'kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
                NutrientRow(
                  label: 'Protein',
                  value: _adjustedNutrients['protein'] ?? 0,
                  unit: 'g',
                  icon: Icons.fitness_center_outlined,
                ),
                NutrientRow(
                  label: 'Carbohydrates',
                  value: _adjustedNutrients['carbohydrates'] ?? 0,
                  unit: 'g',
                  icon: Icons.grain_outlined,
                ),
                NutrientRow(
                  label: 'Fat',
                  value: _adjustedNutrients['fat'] ?? 0,
                  unit: 'g',
                  icon: Icons.opacity_outlined,
                ),
                NutrientRow(
                  label: 'Fiber',
                  value: _adjustedNutrients['fiber'] ?? 0,
                  unit: 'g',
                  icon: Icons.grass_outlined,
                  isLast: true,
                ),
                const Divider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PortionButton(
                        portion: 0.25,
                        label: "Quarter",
                        isSelected: _portionMultiplier == 0.25,
                        onPressed: () => _updatePortion(0.25),
                      ),
                      PortionButton(
                        portion: 0.5,
                        label: "Half",
                        isSelected: _portionMultiplier == 0.5,
                        onPressed: () => _updatePortion(0.5),
                      ),
                      PortionButton(
                        portion: 1.0,
                        label: "Normal",
                        isSelected: _portionMultiplier == 1.0,
                        onPressed: () => _updatePortion(1.0),
                      ),
                      CustomPortionButton(
                        onPortionChanged: _updatePortion,
                      ),
                    ],
                  ),
                ),
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
                        "Current total nutrients: ${widget.totalPlateNutrients}");
                    dailyIntakeProvider.addMealToDailyIntake(
                      mealName: widget.mealName,
                      totalPlateNutrients: _adjustedNutrients,
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
}
