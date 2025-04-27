import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

Widget NutrientCard(BuildContext context, Map<String, dynamic> nutrient,
    Map<String, double> dailyIntake) {
  final uiProvider = Provider.of<UiViewModel>(context, listen: false);
  final name = nutrient['Nutrient'];
  final current = dailyIntake[name] ?? 0.0;
  final total = double.tryParse(nutrient['Current Daily Value']
          .replaceAll(RegExp(r'[^0-9\.]'), '')) ??
      0.0;
  final percent = current / total;

  final unit = uiProvider.getUnit(name);

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
          color: uiProvider.getColorForPercent(percent).withOpacity(0.1),
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
              uiProvider.getNutrientIcon(name),
              color: uiProvider.getColorForPercent(percent),
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
              uiProvider.getColorForPercent(percent)),
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
                  color: uiProvider.getColorForPercent(percent)),
            ),
          ],
        ),
      ],
    ),
  );
}
