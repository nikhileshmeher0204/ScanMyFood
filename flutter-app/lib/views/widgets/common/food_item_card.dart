import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/views/widgets/common/food_nutreint_tile.dart';
import 'package:read_the_label/models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final int index;
  final Color? dominantColor;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.index,
    this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDynamic = dominantColor != null;
    return Container(
      decoration: BoxDecoration(
        color: isDynamic
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isDynamic
            ? Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDynamic
                  ? dominantColor!.withValues(alpha: 0.2)
                  : AppColors.secondary,
              borderRadius: const BorderRadius.vertical(
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
                        isDynamic ? Colors.white.withValues(alpha: 0.95) : AppColors.primaryBlack,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDynamic
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.onSecondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '🔥 ${NutrientUtils.getNutrientValue(item, AppConstants.calories)} ${NutrientUtils.getNutrientUnit(item, AppConstants.calories)}',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMediumBold,
                            isDynamic ? Colors.white.withValues(alpha: 0.9) : AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: isDynamic
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.onSecondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '🍽️ ${item.quantity.value}${item.quantity.unit}',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMediumBold,
                            isDynamic ? Colors.white.withValues(alpha: 0.9) : AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        color: isDynamic ? Colors.white.withValues(alpha: 0.8) : AppColors.primaryBlack,
                        onPressed: () => _showEditDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ), // Nutrient grid
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
                label: NutrientUtils.toTitleCase(AppConstants.protein),
                value:
                    NutrientUtils.getNutrientValue(item, AppConstants.protein),
                unit: NutrientUtils.getNutrientUnit(item, AppConstants.protein),
                icon: Icons.fitness_center_outlined,
                iconPath: NutrientUtils.getNutrientIcon(AppConstants.protein),
                dominantColor: dominantColor,
              ),
              FoodNutrientTile(
                label: NutrientUtils.toTitleCase(AppConstants.carbohydrate),
                value: NutrientUtils.getNutrientValue(
                    item, AppConstants.totalCarbohydrate),
                unit: NutrientUtils.getNutrientUnit(
                    item, AppConstants.totalCarbohydrate),
                icon: Icons.grain_outlined,
                iconPath:
                    NutrientUtils.getNutrientIcon(AppConstants.carbohydrate),
                dominantColor: dominantColor,
              ),
              FoodNutrientTile(
                label: NutrientUtils.toTitleCase(AppConstants.fat),
                value:
                    NutrientUtils.getNutrientValue(item, AppConstants.totalFat),
                unit:
                    NutrientUtils.getNutrientUnit(item, AppConstants.totalFat),
                icon: Icons.opacity_outlined,
                iconPath: NutrientUtils.getNutrientIcon(AppConstants.fat),
                dominantColor: dominantColor,
              ),
              FoodNutrientTile(
                label: NutrientUtils.toTitleCase(AppConstants.dietaryFiber),
                value: NutrientUtils.getNutrientValue(
                    item, AppConstants.dietaryFiber),
                unit: NutrientUtils.getNutrientUnit(
                    item, AppConstants.dietaryFiber),
                icon: Icons.grass_outlined,
                iconPath:
                    NutrientUtils.getNutrientIcon(AppConstants.dietaryFiber),
                dominantColor: dominantColor,
              ),
              FoodNutrientTile(
                label: NutrientUtils.toTitleCase(AppConstants.sugar),
                value: NutrientUtils.getNutrientValue(
                    item, AppConstants.totalSugars),
                unit: NutrientUtils.getNutrientUnit(
                    item, AppConstants.totalSugars),
                icon: Icons.cake_outlined,
                iconPath: NutrientUtils.getNutrientIcon(AppConstants.sugar),
                dominantColor: dominantColor,
              ),
              FoodNutrientTile(
                label: NutrientUtils.toTitleCase(AppConstants.sodium),
                value:
                    NutrientUtils.getNutrientValue(item, AppConstants.sodium),
                unit: NutrientUtils.getNutrientUnit(item, AppConstants.sodium),
                icon: Icons.grain_sharp,
                iconPath: NutrientUtils.getNutrientIcon(AppConstants.sodium),
                dominantColor: dominantColor,
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
          side: const BorderSide(
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
            hintText: 'Enter quantity in ${item.quantity.unit}',
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
                // item.updateQuantity(newQuantity);
                // context.read<MealAnalysisViewModel>().updateTotalNutrients();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
