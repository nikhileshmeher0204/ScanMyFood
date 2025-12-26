import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/ask_ai_view.dart';
import 'package:read_the_label/views/widgets/add_to_intake_button.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/nutrient_balance_card.dart';
import 'package:read_the_label/views/widgets/nutrient_info_shimmer.dart';
import 'package:read_the_label/views/widgets/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/product_image_capture_buttons.dart';
import 'package:read_the_label/views/widgets/quantity_selector.dart';
import 'package:read_the_label/views/widgets/time_selector.dart';

import 'package:rive/rive.dart' as rive;

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
        child: Consumer3<UiViewModel, ProductAnalysisViewModel,
                DailyIntakeViewModel>(
            builder: (context, uiProvider, productAnalysisProvider,
                dailyIntakeProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.transparent),
                ),
                child: DottedBorder(
                  borderPadding: const EdgeInsets.all(-20),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(20),
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  strokeWidth: 1,
                  dashPattern: const [6, 4],
                  child: Builder(builder: (context) {
                    return Column(
                      children: [
                        if (productAnalysisProvider.frontImage != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image(
                                    image: FileImage(
                                        productAnalysisProvider.frontImage!)),
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
                          )
                        else
                          Icon(
                            Icons.document_scanner,
                            size: 70,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          "To get started, scan product front or choose from gallery!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 20),
                        ProductImageCaptureButtons(
                          onImageCapturePressed: _handleImageCapture,
                        ),
                      ],
                    );
                  }),
                ),
              ),
              if (uiProvider.loading) const NutrientInfoShimmer(),

              //Good/Moderate nutrients
              if (productAnalysisProvider.getOptimalNutrients().isNotEmpty)
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
                                      quantity:
                                          "${nutrient.quantity.value} ${nutrient.quantity.unit}",
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
              if (productAnalysisProvider.getModerateNutrients().isNotEmpty)
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
                                      quantity:
                                          "${nutrient.quantity.value} ${nutrient.quantity.unit}",
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
              if (productAnalysisProvider.getWatchOutNutrients().isNotEmpty)
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
                                      quantity:
                                          "${nutrient.quantity.value} ${nutrient.quantity.unit}",
                                      insight: nutrientInsights[nutrient.name],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (productAnalysisProvider.getWatchOutNutrients().isNotEmpty)
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
              if (productAnalysisProvider.primaryConcerns.isNotEmpty)
                ...productAnalysisProvider.primaryConcerns.map(
                  (concern) => NutrientBalanceCard(concern: concern),
                ),

              if (uiProvider.servingSize > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 16,
                    children: [
                      const TimeSelector(),
                      const QuantitySelector(),
                      AddToIntakeButton(
                        mealName: productAnalysisProvider.productName,
                        totalPlateNutrients: productAnalysisProvider.nutrients,
                        foodImage: productAnalysisProvider.frontImage,
                      ),
                    ],
                  ),
                ),
              if (uiProvider.servingSize > 0)
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

  void _handleImageCapture(ImageSource source) async {
    // First, capture front image
    final productAnalysisProvider =
        Provider.of<ProductAnalysisViewModel>(context, listen: false);

    await productAnalysisProvider.captureImage(
      source: source,
      isFrontImage: true,
    );

    if (productAnalysisProvider.frontImage != null) {
      // Show dialog for nutrition label
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Now capture nutrition label',
              style: AppTextStyles.heading2,
            ),
            content: Text(
              'Please capture or select the nutrition facts label of the product',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await productAnalysisProvider.captureImage(
                    source: source,
                    isFrontImage: false,
                  );
                  if (productAnalysisProvider.canAnalyze()) {
                    await productAnalysisProvider.analyzeImages();
                  }
                },
                child: Text('Continue', style: AppTextStyles.buttonTextWhite),
              ),
            ],
          ),
        );
      }
    }
  }
}
