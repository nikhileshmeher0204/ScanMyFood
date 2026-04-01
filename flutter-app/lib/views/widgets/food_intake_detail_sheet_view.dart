import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/food_history_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card_shimmer.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card_shimmer.dart';
import 'package:read_the_label/views/widgets/list_tile.dart';
import 'package:read_the_label/views/widgets/high_low_nutrient_indicator.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class FoodIntakeDetailSheetView extends StatefulWidget {
  const FoodIntakeDetailSheetView({
    super.key,
    required this.itemCard,
  });

  final FoodHistoryItemCard itemCard;

  @override
  State<FoodIntakeDetailSheetView> createState() =>
      _FoodIntakeDetailSheetViewState();
}

class _FoodIntakeDetailSheetViewState extends State<FoodIntakeDetailSheetView> {
  Color? _dominantColor;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  Future<void> _extractColor() async {
    final imageUrl = widget.itemCard.item.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return;

    final vm = context.read<UiViewModel>();
    final color = await vm.extractDominantColor(imageUrl);

    if (mounted) {
      setState(() {
        _dominantColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _dominantColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: CupertinoPageScaffold(
        backgroundColor: _dominantColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SoftEdgeBlur(
                    edges: [
                      EdgeBlur(
                        type: EdgeType.bottomEdge,
                        size: 220,
                        sigma: 8,
                        tintColor: _dominantColor ??
                            Colors.black.withValues(alpha: 0.2),
                        controlPoints: [
                          ControlPoint(
                            position: 0.2,
                            type: ControlPointType.visible,
                          ),
                          ControlPoint(
                            position: 1,
                            type: ControlPointType.transparent,
                          )
                        ],
                      )
                    ],
                    child: Image.network(
                      widget.itemCard.item.imageUrl!,
                      fit: BoxFit.cover,
                      height: 400,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 400,
                          width: double.infinity,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 400,
                          width: double.infinity,
                          color: Colors.grey.shade800,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppColors.primaryWhite.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color:
                                  AppColors.primaryWhite.withValues(alpha: 0.8),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color:
                                  AppColors.primaryWhite.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  CupertinoIcons.share,
                                  color: AppColors.primaryWhite
                                      .withValues(alpha: 0.8),
                                  size: 26,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  CupertinoIcons.delete,
                                  color: Colors.redAccent,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Builder(
                      builder: (context) {
                        final vm = context.watch<DailyIntakeViewModel>();
                        if (vm.loading) return const SizedBox.shrink();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              vm.scannedMealName,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading2Bold.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "North Indian • 1 Serving • 10:00 AM",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMediumBold.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Left Circle Button
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryWhite
                                              .withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(CupertinoIcons.plus,
                                            color: Colors.white, size: 22),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Middle Pill Button
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _dominantColor != null
                                        ? HSLColor.fromColor(_dominantColor!)
                                            .withLightness(0.3)
                                            .toColor()
                                        : Colors.black,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit_rounded, size: 22),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Edit",
                                        style: AppTextStyles.bodyMediumBold
                                            .copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Right Circle Button
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryWhite
                                              .withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          _isFavorited
                                              ? CupertinoIcons.heart_solid
                                              : CupertinoIcons.heart,
                                          color: _isFavorited
                                              ? Colors.redAccent
                                              : Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isFavorited = !_isFavorited;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  final isLoading = context.select(
                    (DailyIntakeViewModel vm) => vm.loading,
                  );

                  if (isLoading) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FoodItemCardShimmer(),
                          FoodItemCardShimmer(),
                          TotalNutrientsCardShimmer(),
                        ],
                      ),
                    );
                  }

                  final dailyIntakeProvider =
                      context.read<DailyIntakeViewModel>();
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Builder(
                          builder: (context) {
                            final targetNutrients = <String>[
                              AppConstants.protein,
                              AppConstants.totalCarbohydrate,
                              AppConstants.dietaryFiber,
                              AppConstants.totalFat
                            ];

                            final indicators =
                                dailyIntakeProvider.nutrientInfo.where((n) {
                              final name = n['name'] as String?;
                              final status = n['dv_status'] as String?;
                              return name != null &&
                                  targetNutrients.contains(
                                      NutrientUtils.toSnakeCase(name)) &&
                                  (status == 'High' || status == 'Low');
                            }).toList();

                            if (indicators.isEmpty)
                              return const SizedBox.shrink();

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: indicators.map((nutrient) {
                                return HighLowNutrientIndicator(
                                  nutrientName: nutrient['name'],
                                  dvStatus: nutrient['dv_status'],
                                  healthImpact: nutrient['health_impact'],
                                );
                              }).toList(),
                            );
                          },
                        ),
                        Text(
                          "Includes",
                          style: AppTextStyles.heading2Close.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 30,
                          ),
                        ),

                        // Food item cards
                        Column(
                          children: dailyIntakeProvider.analyzedScannedFoodItems
                              .asMap()
                              .entries
                              .map((entry) => AppListTile(
                                    item: entry.value,
                                    index: entry.key,
                                  ))
                              .toList(),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TotalNutrientsCard(
                            source: AppConstants.scanMeal,
                            foodAnalysis: dailyIntakeProvider.intakeDetails,
                            mealName: dailyIntakeProvider.scannedMealName,
                            numberOfFoodItems: dailyIntakeProvider
                                .analyzedScannedFoodItems.length,
                            totalPlateNutrients:
                                dailyIntakeProvider.totalScannedPlateNutrients,
                            nutrientInfo: dailyIntakeProvider.nutrientInfo,
                            showSaveOptions: false,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
