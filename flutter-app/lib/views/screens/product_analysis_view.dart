import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/views/screens/ask_ai_view.dart';
import 'package:read_the_label/views/widgets/add_to_intake_button.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/nutrient_balance_card.dart';
import 'package:read_the_label/views/widgets/nutrient_info_shimmer.dart';
import 'package:read_the_label/views/widgets/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/pick_image_card.dart';
import 'package:read_the_label/views/widgets/quantity_selector.dart';
import 'package:read_the_label/views/widgets/time_selector.dart';

class ProductAnalysisView extends StatefulWidget {
  const ProductAnalysisView({super.key});

  @override
  State<ProductAnalysisView> createState() => _ProductAnalysisViewState();
}

class _ProductAnalysisViewState extends State<ProductAnalysisView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        pinned: true,
        expandedHeight: 120,
        flexibleSpace: FlexibleSpaceBar(
          expandedTitleScale: 1.75,
          titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
          title: Text(
            'Scan Label',
            style: AppTextStyles.heading2BoldClose,
          ),
          collapseMode: CollapseMode.pin,
        ),
      ),
      SliverToBoxAdapter(
        child: Consumer<ProductAnalysisViewModel>(
            builder: (context, productAnalysisProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PickImageCard(
                icon: AppConstants.productIcon,
                titleDescription: AppConstants.productScanDescription,
                cameraButtonText: AppConstants.scanNowButtonText,
                galleryButtonText: AppConstants.galleryButtonText,
                image: productAnalysisProvider.frontImage,
                isLoading: productAnalysisProvider.loading,
                onImageCapturePressed: (source) =>
                    productAnalysisProvider.handleImageCapture(context, source),
              ),
              if (productAnalysisProvider.loading) const NutrientInfoShimmer(),

              //Good/Moderate nutrients
              if (productAnalysisProvider.getOptimalNutrients().isNotEmpty &&
                  !productAnalysisProvider.loading)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          productAnalysisProvider.productName,
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "OPTIMAL NUTRIENTS",
                          style: AppTextStyles.greenAccentText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            children: productAnalysisProvider
                                .getOptimalNutrients()
                                .map((nutrient) => NutrientTile(
                                      nutrient: nutrient.name,
                                      dvStatus: nutrient.dvStatus,
                                      goal: nutrient.goal,
                                      healthSign: nutrient.healthImpact,
                                      dailyValue: nutrient.dailyValue,
                                      quantity: nutrient.quantity.value,
                                      unit: nutrient.quantity.unit,
                                      insight: nutrientInsights[nutrient.name],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              //Moderate nutrients
              if (productAnalysisProvider.getModerateNutrients().isNotEmpty &&
                  !productAnalysisProvider.loading)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text("MODERATE NUTRIENTS",
                            style: AppTextStyles.orangeAccentText),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            children: productAnalysisProvider
                                .getModerateNutrients()
                                .map((nutrient) => NutrientTile(
                                      nutrient: nutrient.name,
                                      dvStatus: nutrient.dvStatus,
                                      goal: nutrient.goal,
                                      healthSign: nutrient.healthImpact,
                                      dailyValue: nutrient.dailyValue,
                                      quantity: nutrient.quantity.value,
                                      unit: nutrient.quantity.unit,
                                      insight: nutrientInsights[nutrient.name],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              //Bad nutrients
              if (productAnalysisProvider.getWatchOutNutrients().isNotEmpty &&
                  !productAnalysisProvider.loading)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text("WATCH OUT",
                            style: AppTextStyles.redAccentText),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            children: productAnalysisProvider
                                .getWatchOutNutrients()
                                .map((nutrient) => NutrientTile(
                                      nutrient: nutrient.name,
                                      dvStatus: nutrient.dvStatus,
                                      goal: nutrient.goal,
                                      healthSign: nutrient.healthImpact,
                                      dailyValue: nutrient.dailyValue,
                                      quantity: nutrient.quantity.value,
                                      unit: nutrient.quantity.unit,
                                      insight: nutrientInsights[nutrient.name],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (productAnalysisProvider.getWatchOutNutrients().isNotEmpty &&
                  !productAnalysisProvider.loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 94, 255, 82), // Red accent bar
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Recommendations",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              if (productAnalysisProvider.primaryConcerns.isNotEmpty &&
                  !productAnalysisProvider.loading)
                ...productAnalysisProvider.primaryConcerns.map(
                  (concern) => NutrientBalanceCard(concern: concern),
                ),

              if (productAnalysisProvider.nutrients.isNotEmpty &&
                  !productAnalysisProvider.loading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 16,
                    children: [
                      const TimeSelector(),
                      const QuantitySelector(),
                      AddToIntakeButton(
                        source: AppConstants.scanLabel,
                        mealName: productAnalysisProvider.productName,
                        totalPlateNutrients: productAnalysisProvider.nutrients,
                        foodImage: productAnalysisProvider.frontImage,
                        productAnalysis:
                            productAnalysisProvider.productAnalysis,
                      ),
                    ],
                  ),
                ),
              if (productAnalysisProvider.nutrients.isNotEmpty &&
                  !productAnalysisProvider.loading)
                InkWell(
                  onTap: () {
                    print("Tap detected!");
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AskAiView(
                          foodContext: "product",
                          mealName: productAnalysisProvider.productName,
                          foodImage: productAnalysisProvider.frontImage!,
                        ),
                      ),
                    );
                  },
                  child: const AskAiWidget(),
                ),
            ],
          );
        }),
      ),
    ]);
  }
}
