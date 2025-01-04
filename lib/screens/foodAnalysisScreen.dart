import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/logic.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/widgets/food_item_card.dart';
import 'package:read_the_label/widgets/total_nutrients_card.dart';
import 'package:rive/rive.dart' as rive;

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
                  //Loading animation
                  if (isLoading)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        spacing: 16,
                        children: [
                          const SizedBox(
                            height: 50,
                            width: 50,
                            child: rive.RiveAnimation.asset(
                              'assets/riveAssets/ai_generate_loading.riv',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            "Analyzing nutrition label...",
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
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
