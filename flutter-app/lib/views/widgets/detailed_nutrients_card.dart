import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/views/widgets/nutrient_card.dart';

Widget DetailedNutrientsCard(
    BuildContext context, Map<String, double> dailyIntake) {
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
                  fontFamily: 'Poppins',
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
        if (dailyIntake.isEmpty)
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
                      fontFamily: 'Poppins',
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
                  final current = dailyIntake[name] ?? 0.0;
                  return current > 0.0 &&
                      !['Added Sugars', 'Saturated Fat'].contains(name);
                })
                .map((nutrient) => NutrientCard(context, nutrient, dailyIntake))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
