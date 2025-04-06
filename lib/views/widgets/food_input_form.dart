import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/views/screens/food_analysis_screen.dart';

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
  bool _mounted = true;

  @override
  void dispose() {
    for (var controller in _foodItemControllers) {
      controller.dispose();
    }
    _mounted = false;

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
                    fontSize: 24,
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
                            ),
                            fillColor:
                                Theme.of(context).colorScheme.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .cardBackground,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .cardBackground,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .cardBackground,
                              ),
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
            Container(
              width: 150,
              height: 45,
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 100),
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.cardBackground,
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 237, 202, 149),
                    Color.fromARGB(255, 253, 142, 81),
                    Color.fromARGB(255, 255, 0, 85),
                    Color.fromARGB(255, 0, 21, 255),
                  ],
                  stops: [0.2, 0.4, 0.6, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: MaterialButton(
                onPressed: () {
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Analyze",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
