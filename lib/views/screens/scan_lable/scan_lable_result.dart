// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/views/widgets/add_to_today_intake.dart';
import 'package:read_the_label/views/widgets/title_section_widget.dart';
import 'package:rive/rive.dart' as rive;

import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/views/common/corner_painter.dart';
import 'package:read_the_label/views/common/primary_appbar.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/ask_AI_page.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/nutrient_balance_card.dart';
import 'package:read_the_label/views/widgets/nutrient_info_shimmer.dart';
import 'package:read_the_label/views/widgets/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/portion_buttons.dart';

import '../../../theme/app_colors.dart';
import '../../../viewmodels/daily_intake_view_model.dart';
import '../../../viewmodels/product_analysis_view_model.dart';
import '../../../viewmodels/ui_view_model.dart';

class ScanLableResultPage extends StatefulWidget {
  const ScanLableResultPage({super.key});

  @override
  State<ScanLableResultPage> createState() => _ScanLableResultPageState();
}

class _ScanLableResultPageState extends State<ScanLableResultPage> {
  @override
  void initState() {
    super.initState();
    final productAnalysisProvider =
        Provider.of<ProductAnalysisViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        productAnalysisProvider.analyzeImages();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(
        title: "Result",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Consumer3<UiViewModel, ProductAnalysisViewModel,
                DailyIntakeViewModel>(
            builder: (context, uiProvider, productAnalysisProvider,
                dailyIntakeProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 2 / 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                          image:
                              FileImage(productAnalysisProvider.frontImage!)),
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
              const SizedBox(height: 32),
              buildFoodInfomation(
                  uiProvider, productAnalysisProvider, dailyIntakeProvider)
            ],
          );
        }),
      ),
    );
  }

  Widget buildFoodInfomation(
      UiViewModel uiProvider,
      ProductAnalysisViewModel productAnalysisProvider,
      DailyIntakeViewModel dailyIntakeProvider) {
    if (uiProvider.loading) {
      return const NutrientInfoShimmer();
    } else {
      return Column(
        children: [
          //Good/Moderate nutrients
          if (productAnalysisProvider.getGoodNutrients().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    productAnalysisProvider.productName,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 8),
                const TitleSectionWidget(
                  title: "Optimal Nutrients",
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: productAnalysisProvider
                        .getGoodNutrients()
                        .map((nutrient) => NutrientTile(
                              nutrient: nutrient['name'],
                              healthSign: nutrient['health_impact'],
                              quantity: nutrient['quantity'],
                              insight: nutrientInsights[nutrient['name']],
                              dailyValue: nutrient['daily_value'],
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          //Bad nutrients
          if (productAnalysisProvider.getBadNutrients().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitleSectionWidget(
                  title: "Watch Out",
                  color: Color(0xFFFF5252),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: productAnalysisProvider
                        .getBadNutrients()
                        .map((nutrient) => NutrientTile(
                              nutrient: nutrient['name'],
                              healthSign: nutrient['health_impact'],
                              quantity: nutrient['quantity'],
                              insight: nutrientInsights[nutrient['name']],
                              dailyValue: nutrient['daily_value'],
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (productAnalysisProvider.nutritionAnalysis['primary_concerns'] !=
              null)
            const TitleSectionWidget(
              title: "Recommendations",
            ),

          if (productAnalysisProvider.nutritionAnalysis['primary_concerns'] !=
              null)
            ...productAnalysisProvider.nutritionAnalysis['primary_concerns']
                .map(
              (concern) => NutrientBalanceCard(
                issue: concern['issue'] ?? '',
                explanation: concern['explanation'] ?? '',
                recommendations: (concern['recommendations'] as List?)
                        ?.map((rec) => {
                              'food': rec['food'] ?? '',
                              'quantity': rec['quantity'] ?? '',
                              'reasoning': rec['reasoning'] ?? '',
                            })
                        .toList() ??
                    [],
              ),
            ),

          if (uiProvider.servingSize > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Serving Size: ${uiProvider.servingSize.round()} g",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: 14,
                            fontFamily: 'Poppins'),
                      ),
                      IconButton(
                        icon: PrimarySvgPicture(Assets.icons.icEdit.path,
                            width: 24),
                        onPressed: () {
                          // Show edit dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor:
                                  Theme.of(context).colorScheme.cardBackground,
                              title: Text('Edit Serving Size',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                      fontFamily: 'Poppins')),
                              content: TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color),
                                decoration: InputDecoration(
                                  hintText: 'Enter serving size in grams',
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                      fontFamily: 'Poppins'),
                                ),
                                onChanged: (value) {
                                  context.read<UiViewModel>().updateServingSize(
                                      double.tryParse(value) ?? 0.0);
                                },
                              ),
                              actions: [
                                TextButton(
                                  child: Text('OK',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .color)),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "How much did you consume?",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                          fontSize: 14,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PortionButton(
                        portion: 0.25,
                        label: "1/4",
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      PortionButton(
                        portion: 0.5,
                        label: "1/2",
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      PortionButton(
                        portion: 0.75,
                        label: "3/4",
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      PortionButton(
                        portion: 1.0,
                        label: "1",
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(child: CustomPortionButton()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AddToTodayIntakeButton(
                    uiProvider: uiProvider,
                    productAnalysisProvider: productAnalysisProvider,
                    dailyIntakeProvider: dailyIntakeProvider,
                  )
                ],
              ),
            ),

          if (uiProvider.servingSize == 0 &&
              productAnalysisProvider.parsedNutrients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Serving size not found, please enter it manually',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      uiProvider
                          .updateSliderValue(double.tryParse(value) ?? 0.0);
                    },
                    decoration: const InputDecoration(
                        hintText: "Enter serving size in grams or ml",
                        hintStyle: TextStyle(color: AppColors.grey)),
                    style: const TextStyle(color: Colors.black),
                  ),
                  if (uiProvider.servingSize > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Slider(
                          value: uiProvider.sliderValue,
                          min: 0,
                          max: uiProvider.servingSize,
                          onChanged: (newValue) {
                            uiProvider.updateSliderValue(newValue);
                          }),
                    ),
                  if (uiProvider.servingSize > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Serving Size: ${uiProvider.servingSize.round()} g",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  if (uiProvider.servingSize > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Builder(
                        builder: (context) {
                          return ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white10)),
                              onPressed: () {
                                dailyIntakeProvider.addToDailyIntake(
                                  source: 'label',
                                  productName:
                                      productAnalysisProvider.productName,
                                  nutrients:
                                      productAnalysisProvider.parsedNutrients,
                                  servingSize: uiProvider.servingSize,
                                  consumedAmount: uiProvider.sliderValue,
                                  imageFile: productAnalysisProvider.frontImage,
                                );
                                uiProvider.updateCurrentIndex(2);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Added to today\'s intake!',
                                        style:
                                            TextStyle(fontFamily: 'Poppins')),
                                    action: SnackBarAction(
                                      label: 'SHOW',
                                      onPressed: () {
                                        uiProvider.updateCurrentIndex(1);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Add to today's intake",
                                  style: TextStyle(fontFamily: 'Poppins')));
                        },
                      ),
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
                    builder: (context) => AskAiPage(
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
    }
  }
}
