import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/food_history_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card_shimmer.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card_shimmer.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class FoodIntakeDetailSheetView extends StatelessWidget {
  const FoodIntakeDetailSheetView({
    super.key,
    required this.widget,
  });

  final FoodHistoryItemCard widget;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SoftEdgeBlur(
                    edges: [
                      EdgeBlur(
                        type: EdgeType.bottomEdge,
                        size: 80,
                        sigma: 5,
                        tintColor: Colors.black.withValues(alpha: 0.2),
                        controlPoints: [
                          ControlPoint(
                            position: 0.5,
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
                      widget.item.imageUrl!,
                      fit: BoxFit.cover,
                      height: 150,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
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
                            color: Colors.black.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppColors.primaryWhite.withValues(alpha: 0.3),
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
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Builder(
                      builder: (context) {
                        final vm = context.watch<DailyIntakeViewModel>();
                        if (vm.loading) return const SizedBox.shrink();
                        return Text(
                          vm.scannedMealName,
                          style: AppTextStyles.heading2Bold.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FoodItemCardShimmer(),
                        FoodItemCardShimmer(),
                        TotalNutrientsCardShimmer(),
                      ],
                    );
                  }

                  final dailyIntakeProvider =
                      context.read<DailyIntakeViewModel>();
                  return Column(
                    children: [
                      const SizedBox(height: 16),

                      // Food item cards
                      ...dailyIntakeProvider.analyzedScannedFoodItems
                          .asMap()
                          .entries
                          .map((entry) => FoodItemCard(
                                item: entry.value,
                                index: entry.key,
                              )),

                      TotalNutrientsCard(
                        source: AppConstants.scanMeal,
                        foodAnalysis: dailyIntakeProvider.intakeDetails,
                        mealName: dailyIntakeProvider.scannedMealName,
                        numberOfFoodItems:
                            dailyIntakeProvider.analyzedScannedFoodItems.length,
                        totalPlateNutrients:
                            dailyIntakeProvider.totalScannedPlateNutrients,
                        nutrientInfo: dailyIntakeProvider.nutrientInfo,
                        showSaveOptions: false,
                      ),
                    ],
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
