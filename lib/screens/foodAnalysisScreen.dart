import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/logic.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/widgets/food_item_card.dart';
import 'package:read_the_label/widgets/total_nutrients_card.dart';
import 'package:rive/rive.dart' as rive;
import '../widgets/food_item_card_shimmer.dart';
import '../widgets/total_nutrients_card_shimmer.dart';

class FoodAnalysisScreen extends StatefulWidget {
  final Logic logic;
  final Function(int) updateIndex;

  const FoodAnalysisScreen({
    required this.logic,
    required this.updateIndex,
    super.key,
  });

  @override
  _FoodAnalysisScreenState createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  late int currentIndex;

  @override
  Widget build(BuildContext context) {
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
            valueListenable: widget.logic.loadingNotifier,
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
                  if (!isLoading && widget.logic.analyzedFoodItems.isNotEmpty)
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
                        ...widget.logic.analyzedFoodItems.map((item) =>
                            FoodItemCard(
                                item: item,
                                setState: setState,
                                logic: widget.logic)),
                        TotalNutrientsCard(
                          logic: widget.logic,
                          updateIndex: (index) {
                            setState(() {
                              currentIndex = index;
                            });
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
