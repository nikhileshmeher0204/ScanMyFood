import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/nutrient_card.dart';

class DetailedNutrientsCard extends StatelessWidget {
  const DetailedNutrientsCard({
    super.key,
    required this.totalNutrients,
  });

  final Map<String, FoodNutrient>? totalNutrients;

  @override
  Widget build(BuildContext context) {
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);
    final Map<String, FoodNutrient> totalNutrients =
        dailyIntakeProvider.totalNutrients!;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detailed Nutrients',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontFamily: 'Inter',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                  onPressed: () {
                    // Show info dialog about nutrients
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        title: const Text('About Nutrients'),
                        content: const Text(
                          'This section shows detailed breakdown of your nutrient intake. Values are shown as percentage of daily recommended intake.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (totalNutrients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Log your meals to see detailed nutrient breakdown.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Nutrients Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: nutrientData
                  .where((nutrient) {
                    final name = nutrient['Nutrient'];
                    final current =
                        totalNutrients[NutrientUtils.toSnakeCase(name)]
                                ?.quantity
                                .value ??
                            0.0;
                    return current > 0.0 &&
                        ![
                          AppConstants.addedSugars,
                          AppConstants.saturatedFat,
                          AppConstants.transFat
                        ].contains(name);
                  })
                  .map((nutrient) => NutrientCard(
                        nutrient: nutrient,
                        dailyIntake: dailyIntake,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
