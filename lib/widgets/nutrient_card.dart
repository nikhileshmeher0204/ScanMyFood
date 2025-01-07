import 'package:flutter/material.dart';
import 'package:read_the_label/logic.dart';

Widget NutrientCard(BuildContext context, Map<String, dynamic> nutrient,
    Map<String, double> dailyIntake) {
  final name = nutrient['Nutrient'];
  final current = dailyIntake[name] ?? 0.0;
  final total = double.tryParse(nutrient['Current Daily Value']
          .replaceAll(RegExp(r'[^0-9\.]'), '')) ??
      0.0;
  final percent = current / total;
  final Logic logic = Logic();

  final unit = logic.getUnit(name);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: logic.getColorForPercent(percent, context).withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nutrient Name and Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              logic.getNutrientIcon(name),
              color: logic.getColorForPercent(percent, context),
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Indicator
        LinearProgressIndicator(
          value: percent,
          backgroundColor:
              Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
              logic.getColorForPercent(percent, context)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),

        // Values
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${current.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: logic.getColorForPercent(percent, context),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
