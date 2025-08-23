import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/description_analysis_view_model.dart';

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
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.secondaryOrange,
                        ),
                      ),
                    ),
                    Text(
                      "Log your Meal",
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 60), // Balance the layout
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text("Food Items", style: AppTextStyles.heading2),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _foodItemControllers.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Food Item ${index + 1}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.onPrimary.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    CupertinoTextField(
                                      controller: _foodItemControllers[index],
                                      placeholder: 'e.g., Rice 200g or 2 Rotis',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      placeholderStyle:
                                      AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.onSurface.withOpacity(0.5),
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      cursorColor: AppColors.secondaryGreen,
                                      clearButtonMode: OverlayVisibilityMode.editing,
                                    ),
                                  ],
                                ),
                              ),
                              if (_foodItemControllers.length > 1) ...[
                                const SizedBox(width: 12),
                                CupertinoButton(
                                  padding: const EdgeInsets.all(8),
                                  minSize: 0,
                                  onPressed: () {
                                    setState(() {
                                      _foodItemControllers[index].dispose();
                                      _foodItemControllers.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.minus,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _foodItemControllers.add(TextEditingController());
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondaryGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.add,
                              color: AppColors.secondaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Add another item",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.secondaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onPressed: () {
                          final foodItems = _foodItemControllers
                              .where((controller) => controller.text.isNotEmpty)
                              .map((controller) => controller.text)
                              .join('\n, ');

                          if (foodItems.isNotEmpty) {
                            context
                                .read<DescriptionAnalysisViewModel>()
                                .logMealViaText(
                              foodItemsText: foodItems,
                            );
                            Navigator.pop(context);
                            widget.onSubmit();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.sparkles,
                                color: AppColors.onSurface.withOpacity(0.9),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Analyze Meal",
                                style: AppTextStyles.bodyLargeBold.copyWith(
                                  color: AppColors.onSurface.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
