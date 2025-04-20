import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';

class FoodInputForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const FoodInputForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FoodInputForm> createState() => _FoodInputFormState();
}

class _FoodInputFormState extends State<FoodInputForm> {
  final List<TextEditingController> _foodItemControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    for (var controller in _foodItemControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  "Log your meal!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _foodItemControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _foodItemControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Food Item ${index + 1}',
                            hintText: 'e.g., Rice 200g or 2 Rotis',
                            filled: true,
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                                fontSize: 14,
                                fontFamily: "Poppins"),
                            hintStyle: const TextStyle(
                              color: Color(0xff6B6B6B),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                            fillColor:
                                Theme.of(context).colorScheme.cardBackground,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: Color(0xff6b6b6b)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: AppColors.green),
                            ),
                          ),
                        ),
                      ),
                      if (_foodItemControllers.length > 1)
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            setState(() {
                              _foodItemControllers[index].dispose();
                              _foodItemControllers.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _foodItemControllers.add(TextEditingController());
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  "Add another item",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                final foodItems = _foodItemControllers
                    .where((controller) => controller.text.isNotEmpty)
                    .map((controller) => controller.text)
                    .join('\n, ');
                print("Food Items: \n $foodItems");
                if (foodItems.isNotEmpty) {
                  context.read<MealAnalysisViewModel>().logMealViaText(
                        foodItemsText: foodItems,
                      );
                  Navigator.pop(context);
                  widget.onSubmit();
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Analyze",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
