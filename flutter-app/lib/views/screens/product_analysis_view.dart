import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (productAnalysisProvider
                            .getOptimalNutrients()
                            .isNotEmpty &&
                        !productAnalysisProvider.loading)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            productAnalysisProvider.productName,
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.start,
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                "OPTIMAL QUANTITY",
                                style: AppTextStyles.bodyLargeBold.copyWith(
                                  color: AppColors.secondaryGreen,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.secondaryGreen,
                                size: 18,
                              ),
                            ],
                          ),
                          ClipRRect(
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
                                        insight: nutrientInsights[
                                            NutrientUtils.toTitleCase(
                                                nutrient.name)],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),

                    if (productAnalysisProvider
                            .getModerateNutrients()
                            .isNotEmpty &&
                        !productAnalysisProvider.loading)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                "MODERATE QUANTITY",
                                style: AppTextStyles.bodyLargeBold.copyWith(
                                  color: AppColors.secondaryOrange,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const Icon(
                                Icons.info_rounded,
                                color: AppColors.secondaryOrange,
                                size: 18,
                              ),
                            ],
                          ),
                          ClipRRect(
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
                                        insight: nutrientInsights[
                                            NutrientUtils.toTitleCase(
                                                nutrient.name)],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),

                    if (productAnalysisProvider.getLimitNutrients().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                "EXCESSIVE QUANTITY",
                                style: AppTextStyles.bodyLargeBold.copyWith(
                                  color: AppColors.secondaryRed,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const Icon(
                                Icons.warning_outlined,
                                color: AppColors.secondaryRed,
                                size: 18,
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              children: productAnalysisProvider
                                  .getLimitNutrients()
                                  .map((nutrient) => NutrientTile(
                                        nutrient: nutrient.name,
                                        dvStatus: nutrient.dvStatus,
                                        goal: nutrient.goal,
                                        healthSign: nutrient.healthImpact,
                                        dailyValue: nutrient.dailyValue,
                                        quantity: nutrient.quantity.value,
                                        unit: nutrient.quantity.unit,
                                        insight: nutrientInsights[
                                            NutrientUtils.toTitleCase(
                                                nutrient.name)],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    if (productAnalysisProvider
                        .getInsufficientNutrients()
                        .isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                "LIMITED QUANTITY",
                                style: AppTextStyles.bodyLargeBold.copyWith(
                                  color: AppColors.secondaryRed,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const Icon(
                                Icons.warning_outlined,
                                color: AppColors.secondaryRed,
                                size: 18,
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              children: productAnalysisProvider
                                  .getInsufficientNutrients()
                                  .map((nutrient) => NutrientTile(
                                        nutrient: nutrient.name,
                                        dvStatus: nutrient.dvStatus,
                                        goal: nutrient.goal,
                                        healthSign: nutrient.healthImpact,
                                        dailyValue: nutrient.dailyValue,
                                        quantity: nutrient.quantity.value,
                                        unit: nutrient.quantity.unit,
                                        insight: nutrientInsights[
                                            NutrientUtils.toTitleCase(
                                                nutrient.name)],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),

                    if (productAnalysisProvider.primaryConcerns.isNotEmpty &&
                        !productAnalysisProvider.loading)
                      Column(
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 5,
                            children: [
                              Text(
                                "REMEDIES",
                                style: AppTextStyles.bodyLargeBold.copyWith(
                                  color: AppColors.secondaryGreen,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              Image.asset(
                                'assets/icons/recommendations_icon.png',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Column(
                              children: productAnalysisProvider.primaryConcerns
                                  .map((concern) =>
                                      NutrientBalanceCard(concern: concern))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),

                    if (productAnalysisProvider.nutrients.isNotEmpty &&
                        !productAnalysisProvider.loading)
                      Column(
                        spacing: 16,
                        children: [
                          const TimeSelector(),
                          const QuantitySelector(),
                          AddToIntakeButton(
                            source: AppConstants.scanLabel,
                            mealName: productAnalysisProvider.productName,
                            totalPlateNutrients:
                                productAnalysisProvider.nutrients,
                            foodImage: productAnalysisProvider.frontImage,
                            productAnalysis:
                                productAnalysisProvider.productAnalysis,
                          ),
                        ],
                      ),
                    if (productAnalysisProvider.nutrients.isNotEmpty &&
                        !productAnalysisProvider.loading)
                      InkWell(
                        onTap: () {
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
                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    ]);
  }
}
