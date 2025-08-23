import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/views/widgets/food_nutreint_tile.dart';
import '../../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final int index;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      style: AppTextStyles.withColor(
                        AppTextStyles.heading2,
                        AppColors.primaryBlack,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.onSecondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${item.quantity}${item.unit}',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyLargeBold,
                            AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        color: AppColors.primaryBlack,
                        onPressed: () => _showEditDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Nutrient grid
          GridView.count(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: [
              FoodNutrientTile(
                label: 'Calories',
                value: item
                        .calculateTotalNutrients()['calories']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'kcal',
                icon: Icons.local_fire_department_outlined,
              ),
              FoodNutrientTile(
                label: 'Protein',
                value: item
                        .calculateTotalNutrients()['protein']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'g',
                icon: Icons.fitness_center_outlined,
              ),
              FoodNutrientTile(
                label: 'Carbohydrates',
                value: item
                        .calculateTotalNutrients()['carbohydrates']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'g',
                icon: Icons.grain_outlined,
              ),
              FoodNutrientTile(
                label: 'Fat',
                value:
                    item.calculateTotalNutrients()['fat']?.toStringAsFixed(1) ??
                        '0',
                unit: 'g',
                icon: Icons.opacity_outlined,
              ),
              FoodNutrientTile(
                label: 'Fiber',
                value: item
                        .calculateTotalNutrients()['fiber']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'g',
                icon: Icons.grass_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        title: Text(
          'Edit Quantity',
          style: AppTextStyles.withColor(
            AppTextStyles.heading3,
            AppColors.primaryWhite,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.withColor(
            AppTextStyles.bodyLarge,
            AppColors.primaryWhite,
          ),
          decoration: InputDecoration(
            hintText: 'Enter quantity in ${item.unit}',
            hintStyle: AppTextStyles.withColor(
              AppTextStyles.bodyMedium,
              AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondaryGreen, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                AppColors.textSecondary,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              'Save',
              style: AppTextStyles.withColor(
                AppTextStyles.withWeight(
                    AppTextStyles.bodyMedium, FontWeight.w600),
                AppColors.secondaryGreen,
              ),
            ),
            onPressed: () {
              double? newQuantity = double.tryParse(controller.text);
              if (newQuantity != null) {
                item.quantity = newQuantity;
                context.read<MealAnalysisViewModel>().updateTotalNutrients();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
