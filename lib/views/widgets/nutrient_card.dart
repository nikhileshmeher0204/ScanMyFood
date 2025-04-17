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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                          fontSize: 12,
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
                              text: '$current/$total',
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
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (current / total).clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
