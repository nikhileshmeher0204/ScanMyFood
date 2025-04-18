import 'package:flutter/material.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/models/user_info.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class MacronutrientSummaryCard extends StatelessWidget {
  final Map<String, double> dailyIntake;
  final UserInfo userInfo;

  const MacronutrientSummaryCard({
    super.key,
    required this.dailyIntake,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildNutrientTile(
                'Calories',
                dailyIntake['Energy'] ?? 0.0,
                userInfo.energy,
                'kcal',
                const Color(0xff6BDE36),
                Assets.icons.icCalories.path,
              ),
              const SizedBox(width: 12),
              _buildNutrientTile(
                'Protein',
                dailyIntake['Protein'] ?? 0.0,
                userInfo.protein,
                'g',
                const Color(0xffFFAF40),
                Assets.icons.icProtein.path,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNutrientTile(
                'Carbohydrates',
                dailyIntake['Carbohydrate'] ?? 0.0,
                userInfo.carbohydrate,
                'g',
                const Color(0xff6B25F6),
                Assets.icons.icCarbonHydrates.path,
              ),
              const SizedBox(width: 12),
              _buildNutrientTile(
                'Fat',
                dailyIntake['Fat'] ?? 0.0,
                userInfo.fat,
                'g',
                const Color(0xffFF3F42),
                Assets.icons.icFat.path,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNutrientTile(
                'Fiber',
                dailyIntake['Fiber'] ?? 0.0,
                userInfo.fiber,
                'g',
                const Color(0xff1CAE54),
                Assets.icons.icFiber.path,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildNutrientTile(String label, double value, double goal, String unit,
    Color color, String iconPath) {
  return Expanded(
    child: Container(
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
                  iconPath,
                  color: Colors.white,
                  width: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: RichText(
                        maxLines: 1,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${value.toInt()}/${goal.toInt()}',
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
                    FittedBox(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
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
            value: (value / goal).clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    ),
  );
}
