import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/ask_ai_page.dart';
import 'package:read_the_label/views/widgets/ask_ai_widget.dart';
import 'package:read_the_label/views/widgets/nutrient_balance_card.dart';
import 'package:read_the_label/views/widgets/nutrient_info_shimmer.dart';
import 'package:read_the_label/views/widgets/nutrient_tile.dart';
import 'package:read_the_label/views/widgets/portion_buttons.dart';
import 'package:read_the_label/views/widgets/product_image_capture_buttons.dart';
import 'package:rive/rive.dart' as rive;

class ProductScanPage extends StatefulWidget {
  const ProductScanPage({super.key});

  @override
  State<ProductScanPage> createState() => _ProductScanPageState();
}

class _ProductScanPageState extends State<ProductScanPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 80),
        child: Consumer3<UiViewModel, ProductAnalysisViewModel,
                DailyIntakeViewModel>(
            builder: (context, uiProvider, productAnalysisProvider,
                dailyIntakeProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 100),
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
                              fontFamily: 'Poppins',
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
              if (productAnalysisProvider.getGoodNutrients().isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          productAnalysisProvider.productName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 24),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Optimal Nutrients",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
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
                ),

              //Bad nutrients
              if (productAnalysisProvider.getBadNutrients().isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFFF5252), // Red accent bar
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Watch Out",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .color,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
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
                ),
              if (productAnalysisProvider.getBadNutrients().isNotEmpty)
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
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              if (productAnalysisProvider
                      .nutritionAnalysis['primary_concerns'] !=
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .color,
                                size: 20),
                            onPressed: () {
                              // Show edit dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .cardBackground,
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
                                      context
                                          .read<UiViewModel>()
                                          .updateServingSize(
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              fontSize: 16,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PortionButton(
                            portion: 0.25,
                            label: "¼",
                          ),
                          PortionButton(
                            portion: 0.5,
                            label: "½",
                          ),
                          PortionButton(
                            portion: 0.75,
                            label: "¾",
                          ),
                          PortionButton(
                            portion: 1.0,
                            label: "1",
                          ),
                          CustomPortionButton(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: uiProvider.sliderValue == 0
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          minimumSize: const Size(
                              200, 50), // Set minimum width and height
                        ),
                        onPressed: () {
                          if (uiProvider.sliderValue == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select your consumption to continue'), // Updated message
                              ),
                            );
                          } else {
                            dailyIntakeProvider.addToDailyIntake(
                              source: 'label',
                              productName: productAnalysisProvider.productName,
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
                                    'Added to today\'s intake!'), // Updated message
                                action: SnackBarAction(
                                  label:
                                      'VIEW', // Changed from 'SHOW' to 'VIEW'
                                  onPressed: () {
                                    Provider.of<UiViewModel>(context,
                                            listen: false)
                                        .updateCurrentIndex(2);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Add to today's intake",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${uiProvider.sliderValue.toStringAsFixed(0)} grams, ${(productAnalysisProvider.getCalories() * (uiProvider.sliderValue / uiProvider.servingSize)).toStringAsFixed(0)} calories",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          uiProvider
                              .updateSliderValue(double.tryParse(value) ?? 0.0);
                        },
                        decoration: const InputDecoration(
                            hintText: "Enter serving size in grams or ml",
                            hintStyle: TextStyle(color: Colors.white54)),
                        style: const TextStyle(color: Colors.white),
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
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.white10)),
                                  onPressed: () {
                                    dailyIntakeProvider.addToDailyIntake(
                                      source: 'label',
                                      productName:
                                          productAnalysisProvider.productName,
                                      nutrients: productAnalysisProvider
                                          .parsedNutrients,
                                      servingSize: uiProvider.servingSize,
                                      consumedAmount: uiProvider.sliderValue,
                                      imageFile:
                                          productAnalysisProvider.frontImage,
                                    );
                                    uiProvider.updateCurrentIndex(2);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Added to today\'s intake!',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
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
        }),
      ),
    );
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Poppins'),
            ),
            content: Text(
              'Please capture or select the nutrition facts label of the product',
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontFamily: 'Poppins'),
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
                child: const Text('Continue',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          ),
        );
      }
    }
  }
}
