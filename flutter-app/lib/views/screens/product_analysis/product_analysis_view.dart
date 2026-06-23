import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/ask_ai/ask_ai_view.dart';
import 'package:read_the_label/views/widgets/common/add_to_intake_button.dart';
import 'package:read_the_label/views/widgets/common/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/product_analysis/nutrient_balance_card.dart';
import 'package:read_the_label/views/widgets/product_analysis/nutrient_info_shimmer.dart';
import 'package:read_the_label/views/widgets/common/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/common/pick_image_card.dart';
import 'package:read_the_label/views/widgets/common/quantity_selector.dart';
import 'package:read_the_label/views/widgets/common/time_selector.dart';

class ProductAnalysisView extends StatefulWidget {
  const ProductAnalysisView({super.key});

  @override
  State<ProductAnalysisView> createState() => _ProductAnalysisViewState();
}

class _ProductAnalysisViewState extends State<ProductAnalysisView> {
  ProductAnalysisViewModel? _productAnalysisViewModel;
  Color? _dominantColor;
  String? _lastImagePath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = Provider.of<ProductAnalysisViewModel>(context);
    if (_productAnalysisViewModel != vm) {
      _productAnalysisViewModel?.removeListener(_onProductAnalysisChanged);
      _productAnalysisViewModel = vm;
      _productAnalysisViewModel?.addListener(_onProductAnalysisChanged);
    }
    _onProductAnalysisChanged();
  }

  @override
  void dispose() {
    _productAnalysisViewModel?.removeListener(_onProductAnalysisChanged);
    super.dispose();
  }

  void _onProductAnalysisChanged() {
    final imagePath = _productAnalysisViewModel?.frontImage?.path;
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
    final productAnalysisViewModel =
        Provider.of<ProductAnalysisViewModel>(context);
    final hasResults = productAnalysisViewModel.frontImage != null &&
        productAnalysisViewModel.nutrients.isNotEmpty &&
        !productAnalysisViewModel.loading;

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
                    'Scan Label',
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
                  child: Consumer<ProductAnalysisViewModel>(
                    builder: (context, productAnalysisProvider, _) {
                      final isAnalysisComplete =
                          productAnalysisProvider.frontImage != null &&
                              productAnalysisProvider.nutrients.isNotEmpty &&
                              !productAnalysisProvider.loading;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: PickImageCard(
                              icon: AppConstants.productIcon,
                              titleDescription:
                                  AppConstants.productScanDescription,
                              cameraButtonText: AppConstants.scanNowButtonText,
                              galleryButtonText: AppConstants.galleryButtonText,
                              image: productAnalysisProvider.frontImage,
                              isLoading: productAnalysisProvider.loading,
                              hasResults: isAnalysisComplete,
                              onImageCapturePressed: (source) =>
                                  productAnalysisProvider.handleImageCapture(
                                      context, source),
                              onScanAnother: productAnalysisProvider.reset,
                              loadingSentences: const [
                                'Initializing optical scan',
                                'Reading nutrition facts label',
                                'Deciphering food additives',
                                'Checking daily value status',
                                'Analyzing macro balance',
                                'Evaluating health warnings',
                                'Compiling product report',
                              ],
                            ),
                          ),
                          if (productAnalysisProvider.loading)
                            const NutrientInfoShimmer(),
                          if (isAnalysisComplete)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlack,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Column(
                                  spacing: 24,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (productAnalysisProvider
                                            .getOptimalNutrients()
                                            .isNotEmpty &&
                                        !productAnalysisProvider.loading)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Text(
                                            productAnalysisProvider.productName,
                                            style:
                                                AppTextStyles.heading2.copyWith(
                                              color: AppColors.primaryWhite,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Text(
                                                "OPTIMAL QUANTITY",
                                                style: AppTextStyles
                                                    .bodyLargeBold
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryGreen,
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
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Column(
                                              children: productAnalysisProvider
                                                  .getOptimalNutrients()
                                                  .map((nutrient) =>
                                                      NutrientTile(
                                                        nutrient: nutrient.name,
                                                        dvStatus:
                                                            nutrient.dvStatus,
                                                        goal: nutrient.goal,
                                                        healthSign: nutrient
                                                            .healthImpact,
                                                        dailyValue:
                                                            nutrient.dailyValue,
                                                        quantity: nutrient
                                                            .quantity.value,
                                                        unit: nutrient
                                                            .quantity.unit,
                                                        insight: nutrientInsights[
                                                            NutrientUtils
                                                                .toTitleCase(
                                                                    nutrient
                                                                        .name)],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Text(
                                                "MODERATE QUANTITY",
                                                style: AppTextStyles
                                                    .bodyLargeBold
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryOrange,
                                                  letterSpacing: -1.0,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.info_rounded,
                                                color:
                                                    AppColors.secondaryOrange,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Column(
                                              children: productAnalysisProvider
                                                  .getModerateNutrients()
                                                  .map((nutrient) =>
                                                      NutrientTile(
                                                        nutrient: nutrient.name,
                                                        dvStatus:
                                                            nutrient.dvStatus,
                                                        goal: nutrient.goal,
                                                        healthSign: nutrient
                                                            .healthImpact,
                                                        dailyValue:
                                                            nutrient.dailyValue,
                                                        quantity: nutrient
                                                            .quantity.value,
                                                        unit: nutrient
                                                            .quantity.unit,
                                                        insight: nutrientInsights[
                                                            NutrientUtils
                                                                .toTitleCase(
                                                                    nutrient
                                                                        .name)],
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (productAnalysisProvider
                                        .getLimitNutrients()
                                        .isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Text(
                                                "EXCESSIVE QUANTITY",
                                                style: AppTextStyles
                                                    .bodyLargeBold
                                                    .copyWith(
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
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Column(
                                              children: productAnalysisProvider
                                                  .getLimitNutrients()
                                                  .map((nutrient) =>
                                                      NutrientTile(
                                                        nutrient: nutrient.name,
                                                        dvStatus:
                                                            nutrient.dvStatus,
                                                        goal: nutrient.goal,
                                                        healthSign: nutrient
                                                            .healthImpact,
                                                        dailyValue:
                                                            nutrient.dailyValue,
                                                        quantity: nutrient
                                                            .quantity.value,
                                                        unit: nutrient
                                                            .quantity.unit,
                                                        insight: nutrientInsights[
                                                            NutrientUtils
                                                                .toTitleCase(
                                                                    nutrient
                                                                        .name)],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Text(
                                                "LIMITED QUANTITY",
                                                style: AppTextStyles
                                                    .bodyLargeBold
                                                    .copyWith(
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
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Column(
                                              children: productAnalysisProvider
                                                  .getInsufficientNutrients()
                                                  .map((nutrient) =>
                                                      NutrientTile(
                                                        nutrient: nutrient.name,
                                                        dvStatus:
                                                            nutrient.dvStatus,
                                                        goal: nutrient.goal,
                                                        healthSign: nutrient
                                                            .healthImpact,
                                                        dailyValue:
                                                            nutrient.dailyValue,
                                                        quantity: nutrient
                                                            .quantity.value,
                                                        unit: nutrient
                                                            .quantity.unit,
                                                        insight: nutrientInsights[
                                                            NutrientUtils
                                                                .toTitleCase(
                                                                    nutrient
                                                                        .name)],
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (productAnalysisProvider
                                            .primaryConcerns.isNotEmpty &&
                                        !productAnalysisProvider.loading)
                                      Column(
                                        spacing: 8,
                                        children: [
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Text(
                                                "REMEDIES",
                                                style: AppTextStyles
                                                    .bodyLargeBold
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryGreen,
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
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Column(
                                              children: productAnalysisProvider
                                                  .primaryConcerns
                                                  .map((concern) =>
                                                      NutrientBalanceCard(
                                                          concern: concern))
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (productAnalysisProvider
                                            .nutrients.isNotEmpty &&
                                        !productAnalysisProvider.loading)
                                      Column(
                                        spacing: 16,
                                        children: [
                                          const TimeSelector(),
                                          const QuantitySelector(),
                                          AddToIntakeButton(
                                            source: AppConstants.scanLabel,
                                            mealName: productAnalysisProvider
                                                .productName,
                                            totalPlateNutrients:
                                                productAnalysisProvider
                                                    .nutrients,
                                            foodImage: productAnalysisProvider
                                                .frontImage,
                                            productAnalysis:
                                                productAnalysisProvider
                                                    .productAnalysis,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (isAnalysisComplete)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 20.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => AskAiView(
                                        foodContext: "product",
                                        mealName:
                                            productAnalysisProvider.productName,
                                        foodImage:
                                            productAnalysisProvider.frontImage!,
                                      ),
                                    ),
                                  );
                                },
                                child: const AskAiWidget(),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
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
