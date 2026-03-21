import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/screens/ask_ai_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card_shimmer.dart';
import 'package:read_the_label/views/widgets/pick_image_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card_shimmer.dart';

class FoodAnalysisView extends StatefulWidget {
  const FoodAnalysisView({
    super.key,
  });

  @override
  State<FoodAnalysisView> createState() => _FoodAnalysisViewState();
}

class _FoodAnalysisViewState extends State<FoodAnalysisView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.surface,
          pinned: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.75,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Scan Food',
              style: AppTextStyles.heading2BoldClose,
            ),
            collapseMode: CollapseMode.pin,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<MealAnalysisViewModel>(
                  builder: (context, mealAnalysisProvider, child) {
                    return Selector<UiViewModel, bool>(
                      selector: (context, uiViewModel) => uiViewModel.loading,
                      builder: (context, isLoading, child) {
                        return PickImageCard(
                          icon: AppConstants.foodIcon,
                          titleDescription: AppConstants.foodScanDescription,
                          cameraButtonText: AppConstants.cameraButtonText,
                          galleryButtonText: AppConstants.galleryButtonText,
                          image: mealAnalysisProvider.foodImage,
                          isLoading: isLoading,
                          onImageCapturePressed: mealAnalysisProvider.handleFoodImageCapture,
                        );
                      },
                    );
                  },
                ),
                Consumer<MealAnalysisViewModel>(
                  builder: (context, mealAnalysisProvider, child) {
                    final isLoading = mealAnalysisProvider.loading;
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
                    if (mealAnalysisProvider.foodImage != null &&
                        mealAnalysisProvider
                            .analyzedScannedFoodItems.isNotEmpty &&
                        !isLoading) {
                      return Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealAnalysisProvider.scannedMealName,
                            style: AppTextStyles.heading2BoldClose,
                          ),

                          // Food item cards
                          ...mealAnalysisProvider.analyzedScannedFoodItems
                              .asMap()
                              .entries
                              .map((entry) => FoodItemCard(
                                    item: entry.value,
                                    index: entry.key,
                                  )),

                          TotalNutrientsCard(
                            source: AppConstants.scanMeal,
                            foodAnalysis: mealAnalysisProvider.foodAnalysis,
                            mealName: mealAnalysisProvider.scannedMealName,
                            numberOfFoodItems: mealAnalysisProvider
                                .analyzedScannedFoodItems.length,
                            totalPlateNutrients:
                                mealAnalysisProvider.totalScannedPlateNutrients,
                            nutrientInfo: mealAnalysisProvider.nutrientInfo,
                            foodImage: mealAnalysisProvider.foodImage,
                            showSaveOptions: true,
                          ),

                          InkWell(
                            onTap: () {
                              print("Tap detected!");
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => AskAiView(
                                    foodContext: "food",
                                    mealName:
                                        mealAnalysisProvider.scannedMealName,
                                    foodImage: mealAnalysisProvider.foodImage!,
                                  ),
                                ),
                              );
                            },
                            child: const AskAiWidget(),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
