import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/screens/ask_ai/ask_ai_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/common/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/daily_intake/food_item_card_shimmer.dart';
import 'package:read_the_label/views/widgets/daily_intake/list_tile.dart';
import 'package:read_the_label/views/widgets/common/pick_image_card.dart';
import 'package:read_the_label/views/widgets/common/total_nutrients_card.dart';
import 'package:read_the_label/views/widgets/daily_intake/total_nutrients_card_shimmer.dart';

class FoodAnalysisView extends StatefulWidget {
  const FoodAnalysisView({
    super.key,
  });

  @override
  State<FoodAnalysisView> createState() => _FoodAnalysisViewState();
}

class _FoodAnalysisViewState extends State<FoodAnalysisView> {
  MealAnalysisViewModel? _mealAnalysisViewModel;
  Color? _dominantColor;
  String? _lastImagePath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = Provider.of<MealAnalysisViewModel>(context);
    if (_mealAnalysisViewModel != vm) {
      _mealAnalysisViewModel?.removeListener(_onMealAnalysisChanged);
      _mealAnalysisViewModel = vm;
      _mealAnalysisViewModel?.addListener(_onMealAnalysisChanged);
    }
    _onMealAnalysisChanged();
  }

  @override
  void dispose() {
    _mealAnalysisViewModel?.removeListener(_onMealAnalysisChanged);
    super.dispose();
  }

  void _onMealAnalysisChanged() {
    final imagePath = _mealAnalysisViewModel?.foodImage?.path;
    if (imagePath != _lastImagePath) {
      _lastImagePath = imagePath;
      if (imagePath == null) {
        if (mounted) {
          setState(() {
            _dominantColor = null;
          });
        }
      } else {
        _extractColor(imagePath);
      }
    }
  }

  Future<void> _extractColor(String imagePath) async {
    final uiVm = context.read<UiViewModel>();
    final color = await uiVm.extractDominantColor(imagePath);
    if (mounted && _lastImagePath == imagePath) {
      setState(() {
        _dominantColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealAnalysisViewModel = Provider.of<MealAnalysisViewModel>(context);
    final hasResults = mealAnalysisViewModel.foodImage != null &&
        mealAnalysisViewModel.analyzedScannedFoodItems.isNotEmpty &&
        !mealAnalysisViewModel.loading;

    final targetColor = hasResults
        ? (_dominantColor ?? AppColors.background)
        : AppColors.background;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: AppColors.background,
        end: targetColor,
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, animatedColor, child) {
        final displayColor = animatedColor ?? AppColors.background;
        return Container(
          color: displayColor,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: displayColor,
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.75,
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: Text(
                    'Scan Food',
                    style: AppTextStyles.heading2BoldClose.copyWith(
                      color: AppColors.getTitleColor(displayColor),
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Consumer<MealAnalysisViewModel>(
                          builder: (context, mealAnalysisProvider, child) {
                            final isAnalysisComplete =
                                mealAnalysisProvider.foodImage != null &&
                                    mealAnalysisProvider
                                        .analyzedScannedFoodItems.isNotEmpty &&
                                    !mealAnalysisProvider.loading;
                            return PickImageCard(
                              icon: AppConstants.foodIcon,
                              titleDescription:
                                  AppConstants.foodScanDescription,
                              cameraButtonText: AppConstants.cameraButtonText,
                              galleryButtonText: AppConstants.galleryButtonText,
                              image: mealAnalysisProvider.foodImage,
                              isLoading: mealAnalysisProvider.loading,
                              hasResults: isAnalysisComplete,
                              onImageCapturePressed:
                                  mealAnalysisProvider.handleFoodImageCapture,
                              onScanWithDescription: mealAnalysisProvider
                                  .analyzeFoodImageWithDescription,
                              onScanAnother: mealAnalysisProvider.reset,
                              loadingSentences: const [
                                'Analyzing plate composition',
                                'Detecting cooked ingredients',
                                'Estimating portion weights',
                                'Calculating calorie density',
                                'Evaluating nutritional index',
                                'Compiling meal insights',
                              ],
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Text(
                                      mealAnalysisProvider.scannedMealName,
                                      style: AppTextStyles.heading2BoldClose
                                          .copyWith(
                                        color: AppColors.getTitleColor(
                                            displayColor),
                                      ),
                                    ),
                                  ),

                                  // Food item cards
                                  ...mealAnalysisProvider
                                      .analyzedScannedFoodItems
                                      .asMap()
                                      .entries
                                      .map((entry) => AppListTile(
                                            item: entry.value,
                                            index: entry.key,
                                            dominantColor: displayColor,
                                          )),

                                  TotalNutrientsCard(
                                    source: AppConstants.scanMeal,
                                    foodAnalysis:
                                        mealAnalysisProvider.foodAnalysis,
                                    mealName:
                                        mealAnalysisProvider.scannedMealName,
                                    numberOfFoodItems: mealAnalysisProvider
                                        .analyzedScannedFoodItems.length,
                                    totalPlateNutrients: mealAnalysisProvider
                                        .totalScannedPlateNutrients,
                                    nutrientInfo:
                                        mealAnalysisProvider.nutrientInfo,
                                    foodImage: mealAnalysisProvider.foodImage,
                                    showSaveOptions: true,
                                  ),

                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => AskAiView(
                                            foodContext: "food",
                                            mealName: mealAnalysisProvider
                                                .scannedMealName,
                                            foodImage:
                                                mealAnalysisProvider.foodImage!,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
