import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/common/primary_appbar.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/title_section_widget.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import '../../widgets/food_item_card_shimmer.dart';
import '../../widgets/total_nutrients_card_shimmer.dart';

class FoodLableAnalysisScreen extends StatefulWidget {
  const FoodLableAnalysisScreen({
    super.key,
  });

  @override
  State<FoodLableAnalysisScreen> createState() =>
      FoodLableAnalysisScreenState();
}

class FoodLableAnalysisScreenState extends State<FoodLableAnalysisScreen> {
  late int currentIndex;
  @override
  void initState() {
    super.initState();
    // Initialize with a default value or get from provider
    currentIndex = context.read<UiViewModel>().currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: "Result"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          child: Consumer2<UiViewModel, MealAnalysisViewModel>(
            builder: (context, uiViewModel, mealViewModel, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (uiViewModel.loading)
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FoodItemCardShimmer(),
                        FoodItemCardShimmer(),
                        TotalNutrientsCardShimmer(),
                      ],
                    ),
                  // Results Section
                  if (mealViewModel.analyzedFoodItems.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const TitleSectionWidget(
                          title: "Analysis Results",
                        ),
                        const SizedBox(height: 16),
                        ...mealViewModel.analyzedFoodItems
                            .asMap()
                            .entries
                            .map((entry) => FoodItemCard(
                                  item: entry.value,
                                  index: entry.key,
                                )),
                        const TitleSectionWidget(
                          title: "Total Nutrients",
                        ),
                        const TotalNutrientsCard(),
                        const SizedBox(
                          height: 24,
                        ),
                        FoodLableAnalysisAddToTodayIntakeButton(
                          uiProvider: uiViewModel,
                          dailyIntakeProvider:
                              context.read<DailyIntakeViewModel>(),
                          foodItems: mealViewModel.analyzedFoodItems,
                        ),
                      ],
                    ),
                  // No results state
                  if (!uiViewModel.loading &&
                      mealViewModel.analyzedFoodItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No food items analyzed yet',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class FoodLableAnalysisAddToTodayIntakeButton extends StatelessWidget {
  const FoodLableAnalysisAddToTodayIntakeButton({
    super.key,
    required this.uiProvider,
    required this.dailyIntakeProvider,
    required this.foodItems,
  });

  final UiViewModel uiProvider;
  final DailyIntakeViewModel dailyIntakeProvider;
  final List<FoodItem> foodItems;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 2,
        minimumSize: const Size(200, 50),
      ),
      onPressed: () {
        for (var element in foodItems) {
          dailyIntakeProvider.addMealToDailyIntake(
            mealName: element.name,
            totalPlateNutrients: element.calculateTotalNutrients(),
          );
        }

        uiProvider.updateCurrentIndex(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Added to today\'s intake!'),
            action: SnackBarAction(
              label: 'VIEW',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrimarySvgPicture(
            Assets.icons.icAdd.path,
            width: 20,
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                "Add to today's intake",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
