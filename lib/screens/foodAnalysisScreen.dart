import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/providers/UiProvider.dart';
import 'package:read_the_label/providers/nutrition_provider.dart';
import 'package:read_the_label/widgets/food_item_card.dart';
import 'package:read_the_label/widgets/total_nutrients_card.dart';
import '../widgets/food_item_card_shimmer.dart';
import '../widgets/total_nutrients_card_shimmer.dart';

class FoodAnalysisScreen extends StatefulWidget {
  final Function(int) updateIndex;

  const FoodAnalysisScreen({
    required this.updateIndex,
    super.key,
  });

  @override
  _FoodAnalysisScreenState createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  late int currentIndex;
  @override
  void initState() {
    super.initState();
    // Initialize with a default value or get from provider
    currentIndex = context.read<UiProvider>().currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: const Text('Food Analysis'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: context.read<NutritionProvider>().loadingNotifier,
            builder: (context, isLoading, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Analysis Results',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        const FoodItemCardShimmer(),
                        const FoodItemCardShimmer(),
                        const TotalNutrientsCardShimmer(),
                      ],
                    ),
                  // Results Section
                  if (!isLoading &&
                      context
                          .read<NutritionProvider>()
                          .analyzedFoodItems
                          .isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Analysis Results',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...context
                            .read<NutritionProvider>()
                            .analyzedFoodItems
                            .asMap()
                            .entries
                            .map((entry) => FoodItemCard(
                                  item: entry.value,
                                  index: entry.key,
                                )),
                        TotalNutrientsCard(
                          updateIndex: (index) {
                            uiProvider.updateCurrentIndex(index);
                            widget.updateIndex(index);
                          },
                        ),
                      ],
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
