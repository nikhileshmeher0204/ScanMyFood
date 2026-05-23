import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class CalorieCard extends StatelessWidget {
  final FoodNutrient? calories;
  const CalorieCard({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    const calorieGoal = 2000.0;
    final caloriePercent = (calories?.quantity.value ?? 0) / calorieGoal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY\'S CALORIES',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${calories?.quantity.value.toStringAsFixed(0) ?? '0'}',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),
                        TextSpan(
                          text: ' kcal',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.onPrimary.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${calorieGoal.toStringAsFixed(0)} goal',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: caloriePercent,
                  backgroundColor: AppColors.primaryWhite.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.secondaryGreen,
                  ),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(caloriePercent * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
