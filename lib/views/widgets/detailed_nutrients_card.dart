import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/models/user_info.dart';
import 'package:read_the_label/views/widgets/nutrient_card.dart';

class DetailedNutrientsCard extends StatelessWidget {
  final Map<String, double> dailyIntake;
  final UserInfo userInfo;

  const DetailedNutrientsCard({
    super.key,
    required this.dailyIntake,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 16,
              children: nutrientData
                  .where((nutrient) {
                    final name = nutrient['Nutrient'];
                    final current = dailyIntake[name] ?? 0.0;
                    return current > 0.0 &&
                        !['Added Sugars', 'Saturated Fat'].contains(name);
                  })
                  .map((nutrient) => NutrientCard(
                        nutrient: nutrient,
                        dailyIntake: dailyIntake,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
