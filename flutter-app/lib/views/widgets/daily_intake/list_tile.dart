import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

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

class _AppListTileState extends State<AppListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final portion = context.watch<UiViewModel>().portionMultiplier;
    final title = widget.item.name;
    final rawCaloriesValue =
        NutrientUtils.getNutrientValue(widget.item, AppConstants.calories);
    final caloriesValue = (rawCaloriesValue * portion).round();
    final caloriesUnit =
        NutrientUtils.getNutrientUnit(widget.item, AppConstants.calories);
    final scaledQuantity = (widget.item.quantity.value * portion)
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');
    final subtitle =
        '$caloriesValue $caloriesUnit • $scaledQuantity ${widget.item.quantity.unit}';

    final baseBgColor =
        widget.dominantColor ?? Theme.of(context).scaffoldBackgroundColor;
    final hsl = HSLColor.fromColor(baseBgColor);
    final expandedColor =
        hsl.withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0)).toColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isExpanded ? expandedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: _isExpanded ? const EdgeInsets.all(12.0) : EdgeInsets.zero,
      margin: _isExpanded
          ? const EdgeInsets.symmetric(vertical: 8.0)
          : EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
              _toggleExpand();
            },
            child: Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Numbered list
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.getSubtitleColor(
                            widget.dominantColor ?? Colors.black),
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
                                width: 0.5,
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    subtitle,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.getSubtitleColor(
                                          widget.dominantColor ?? Colors.black),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (widget.item.dietaryIconAsset != null) ...[
                                    const SizedBox(width: 6),
                                    Image.asset(
                                      widget.item.dietaryIconAsset!,
                                      width: 14,
                                      height: 14,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: AppColors.getSubtitleColor(
                              widget.dominantColor ?? Colors.black),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 4.0, right: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNutrientRow(
                    iconPath: 'assets/icons/protein_icon.png',
                    label: NutrientUtils.toTitleCase(AppConstants.protein),
                    value: NutrientUtils.getNutrientValue(
                            widget.item, AppConstants.protein) *
                        portion,
                    unit: NutrientUtils.getNutrientUnit(
                        widget.item, AppConstants.protein),
                  ),
                  _buildNutrientRow(
                    iconPath: 'assets/icons/carbs_icon.png',
                    label: NutrientUtils.toTitleCase(AppConstants.carbohydrate),
                    value: NutrientUtils.getNutrientValue(
                            widget.item, AppConstants.totalCarbohydrate) *
                        portion,
                    unit: NutrientUtils.getNutrientUnit(
                        widget.item, AppConstants.totalCarbohydrate),
                  ),
                  _buildNutrientRow(
                    iconPath: 'assets/icons/fat_icon.png',
                    label: NutrientUtils.toTitleCase(AppConstants.fat),
                    value: NutrientUtils.getNutrientValue(
                            widget.item, AppConstants.totalFat) *
                        portion,
                    unit: NutrientUtils.getNutrientUnit(
                        widget.item, AppConstants.totalFat),
                  ),
                  _buildNutrientRow(
                    iconPath: 'assets/icons/fibre_icon.png',
                    label: NutrientUtils.toTitleCase(AppConstants.dietaryFiber),
                    value: NutrientUtils.getNutrientValue(
                            widget.item, AppConstants.dietaryFiber) *
                        portion,
                    unit: NutrientUtils.getNutrientUnit(
                        widget.item, AppConstants.dietaryFiber),
                  ),
                  _buildNutrientRow(
                    iconPath: 'assets/icons/sugar_icon.png',
                    label: NutrientUtils.toTitleCase(AppConstants.sugar),
                    value: NutrientUtils.getNutrientValue(
                            widget.item, AppConstants.totalSugars) *
                        portion,
                    unit: NutrientUtils.getNutrientUnit(
                        widget.item, AppConstants.totalSugars),
                  ),
                  _buildNutrientRow(
                    iconPath: 'assets/icons/sodium_icon.png',
                    label: NutrientUtils.toTitleCase(AppConstants.sodium),
                    value: NutrientUtils.getNutrientValue(
                            widget.item, AppConstants.sodium) *
                        portion,
                    unit: NutrientUtils.getNutrientUnit(
                        widget.item, AppConstants.sodium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow({
    required String iconPath,
    required String label,
    required double value,
    required String unit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: '  •  ',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(
                            widget.dominantColor ?? Colors.black)
                        .withOpacity(0.4),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: '$value $unit',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(
                        widget.dominantColor ?? Colors.black),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
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
