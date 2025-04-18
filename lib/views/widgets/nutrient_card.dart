import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class NutrientCard extends StatelessWidget {
  final Map<String, dynamic> nutrient;
  final Map<String, double> dailyIntake;

  const NutrientCard({
    super.key,
    required this.nutrient,
    required this.dailyIntake,
  });

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiViewModel>(context, listen: false);
    final name = nutrient['Nutrient'];
    final current = dailyIntake[name] ?? 0.0;
    final total = double.tryParse(nutrient['Current Daily Value']
            .replaceAll(RegExp(r'[^0-9\.]'), '')) ??
        0.0;
    final unit = uiProvider.getUnit(name);
    // final color = uiProvider.getColorForPercent(current / total);
    final color = uiProvider.getNutrientColor(name);

    log(nutrient.toString());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PrimarySvgPicture(
              uiProvider.getNutrientIcon(name),
              color: Colors.white,
              width: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                FittedBox(
                  child: RichText(
                    maxLines: 1,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${current.toInt()}/${total.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: unit,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
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
