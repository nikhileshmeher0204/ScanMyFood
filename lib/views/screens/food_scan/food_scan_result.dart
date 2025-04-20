import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/common/primary_appbar.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/ai_chat/ask_AI_page.dart';
import 'package:read_the_label/views/common/corner_painter.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/food_item_card_shimmer.dart';
import 'package:read_the_label/views/widgets/title_section_widget.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card_shimmer.dart';
import 'package:rive/rive.dart' as rive;

class FoodScanResultPage extends StatefulWidget {
  const FoodScanResultPage({super.key});

  @override
  State<FoodScanResultPage> createState() => _FoodScanResultPageState();
}

class _FoodScanResultPageState extends State<FoodScanResultPage> {
  @override
  void initState() {
    super.initState();
    final mealAnalysisProvider =
        Provider.of<MealAnalysisViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        mealAnalysisProvider.analyzeFoodImage(
          imageFile: mealAnalysisProvider.foodImage!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: "Result"),
      body: Consumer3<UiViewModel, MealAnalysisViewModel, DailyIntakeViewModel>(
        builder: (context, uiProvider, mealAnalysisProvider,
            dailyIntakeProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 2 / 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image(
                            image: FileImage(mealAnalysisProvider.foodImage!)),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CornerPainter(
                            radius: 20,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      if (uiProvider.loading)
                        const Positioned.fill(
                          left: 5,
                          right: 5,
                          top: 5,
                          bottom: 5,
                          child: rive.RiveAnimation.asset(
                            'assets/riveAssets/qr_code_scanner.riv',
                            fit: BoxFit.fill,
                            artboard: 'scan_board',
                            animations: ['anim1'],
                            stateMachines: ['State Machine 1'],
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                if (uiProvider.loading)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FoodItemCardShimmer(),
                      FoodItemCardShimmer(),
                      TotalNutrientsCardShimmer(),
                    ],
                  ),
                if (mealAnalysisProvider.foodImage != null &&
                    mealAnalysisProvider.analyzedFoodItems.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TitleSectionWidget(
                        title: "Analysis Results",
                      ),
                      ...mealAnalysisProvider.analyzedFoodItems
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
                      const SizedBox(height: 16),
                      FoodScanAddToTodayIntakeButton(
                        uiProvider: uiProvider,
                        dailyIntakeProvider: dailyIntakeProvider,
                        productName: mealAnalysisProvider.mealName,
                        totalPlateNutrients:
                            mealAnalysisProvider.totalPlateNutrients,
                        imageFile: mealAnalysisProvider.foodImage,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AskAiPage(
                                mealName: mealAnalysisProvider.mealName,
                                foodImage: mealAnalysisProvider.foodImage!,
                              ),
                            ),
                          );
                        },
                        child: const AskAiWidget(),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FoodScanAddToTodayIntakeButton extends StatelessWidget {
  const FoodScanAddToTodayIntakeButton({
    super.key,
    required this.uiProvider,
    required this.dailyIntakeProvider,
    required this.productName,
    required this.totalPlateNutrients,
    this.imageFile,
  });

  final UiViewModel uiProvider;
  final DailyIntakeViewModel dailyIntakeProvider;
  final String productName;
  final Map<String, dynamic> totalPlateNutrients;
  final File? imageFile;

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
        dailyIntakeProvider.addMealToDailyIntake(
          mealName: productName,
          totalPlateNutrients: totalPlateNutrients,
          foodImage: imageFile,
        );

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
