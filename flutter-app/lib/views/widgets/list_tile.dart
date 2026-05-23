import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';

class AppListTile extends StatefulWidget {
  final FoodItem item;
  final int index;
  final Color? dominantColor;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    required this.item,
    required this.index,
    required this.dominantColor,
    this.onTap,
  });

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.item.name;
    final caloriesValue =
        NutrientUtils.getNutrientValue(widget.item, AppConstants.calories);
    final caloriesUnit =
        NutrientUtils.getNutrientUnit(widget.item, AppConstants.calories);
    final subtitle =
        '$caloriesValue $caloriesUnit • ${widget.item.quantity.value} ${widget.item.quantity.unit}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      // Slightly lighter background when expanded to give card expression
      decoration: BoxDecoration(
        color: _isExpanded
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: _isExpanded ? const EdgeInsets.all(12.0) : EdgeInsets.zero,
      margin: _isExpanded
          ? const EdgeInsets.symmetric(vertical: 8.0)
          : EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap ??
                () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
            child: Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Numbered list
                SizedBox(
                  width:
                      30, // Keeps number column consistently aligned across multiple digits
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                // Title, Subtitle, and Action Block with Bottom Divider
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: !_isExpanded
                          ? Border(
                              bottom: BorderSide(
                                color: AppColors.getSubtitleColor(
                                        widget.dominantColor ?? Colors.black)
                                    .withOpacity(0.15),
                                width: 0.5, // Standard thin divider
                              ),
                            )
                          : null,
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: _isExpanded ? 4.0 : 12.0),
                    child: Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.getTitleColor(
                                      widget.dominantColor ?? Colors.black),
                                  fontSize: 17, // slightly bigger
                                  fontWeight:
                                      FontWeight.w500, // semibold (important)
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.getSubtitleColor(
                                      widget.dominantColor ?? Colors.black),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400, // ❗ NOT bold
                                  letterSpacing: 0.2,
                                  height: 1.2,
                                ),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                              _isExpanded
                                  ? CupertinoIcons.chevron_up
                                  : CupertinoIcons.chevron_down,
                              color: Colors.white54,
                              size: 20),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: [
                _buildNutrient(
                  NutrientUtils.toTitleCase(AppConstants.protein),
                  NutrientUtils.getNutrientValue(
                      widget.item, AppConstants.protein),
                  NutrientUtils.getNutrientUnit(
                      widget.item, AppConstants.protein),
                ),
                _buildNutrient(
                  NutrientUtils.toTitleCase(AppConstants.carbohydrate),
                  NutrientUtils.getNutrientValue(
                      widget.item, AppConstants.totalCarbohydrate),
                  NutrientUtils.getNutrientUnit(
                      widget.item, AppConstants.totalCarbohydrate),
                ),
                _buildNutrient(
                  NutrientUtils.toTitleCase(AppConstants.fat),
                  NutrientUtils.getNutrientValue(
                      widget.item, AppConstants.totalFat),
                  NutrientUtils.getNutrientUnit(
                      widget.item, AppConstants.totalFat),
                ),
                _buildNutrient(
                  NutrientUtils.toTitleCase(AppConstants.dietaryFiber),
                  NutrientUtils.getNutrientValue(
                      widget.item, AppConstants.dietaryFiber),
                  NutrientUtils.getNutrientUnit(
                      widget.item, AppConstants.dietaryFiber),
                ),
                _buildNutrient(
                  NutrientUtils.toTitleCase(AppConstants.sugar),
                  NutrientUtils.getNutrientValue(
                      widget.item, AppConstants.totalSugars),
                  NutrientUtils.getNutrientUnit(
                      widget.item, AppConstants.totalSugars),
                ),
                _buildNutrient(
                  NutrientUtils.toTitleCase(AppConstants.sodium),
                  NutrientUtils.getNutrientValue(
                      widget.item, AppConstants.sodium),
                  NutrientUtils.getNutrientUnit(
                      widget.item, AppConstants.sodium),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildNutrient(String label, double value, String unit) {
    final String? nutrientIcon = NutrientUtils.getNutrientIcon(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: 0.05), // highly translucent to blend with sheet
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: nutrientIcon != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      nutrientIcon,
                      fit: BoxFit.contain,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '$value $unit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
