import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/screens/meal_analysis/meal_description_analysis_view.dart';
import 'package:read_the_label/views/widgets/daily_intake/food_input_form.dart';

class AddIntakeDescButton extends StatefulWidget {
  const AddIntakeDescButton({super.key});

  @override
  State<AddIntakeDescButton> createState() => _AddIntakeDescButtonState();
}

class _AddIntakeDescButtonState extends State<AddIntakeDescButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _shimmerController]),
      builder: (context, child) {
        // Use a lower subtree context to avoid tying the sheet to the parent route
        return Builder(
          builder: (innerContext) {
            return GestureDetector(
              onTap: () {
                Navigator.of(innerContext, rootNavigator: true).push(
                  CupertinoSheetRoute(
                    builder: (sheetContext) => Material(
                      child: FoodInputForm(
                        onSubmit: () {
                          Navigator.of(sheetContext).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  const MealDescriptionAnalysisView(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color.fromARGB(255, 40, 24, 78),   // Siri Deep Indigo/Violet
                      Color.fromARGB(255, 88, 28, 68),   // Siri Dark Plum/Magenta
                      Color.fromARGB(255, 20, 36, 85),   // Siri Midnight Blue
                      Color.fromARGB(255, 12, 54, 60),   // Siri Emerald Teal
                    ],
                    stops: const [0.1, 0.4, 0.7, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform:
                        GradientRotation(_shimmerController.value * 6.28),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 120, 80, 200).withValues(
                          alpha: 0.12 + (_pulseController.value * 0.08)),
                      blurRadius: 16 + (_pulseController.value * 6),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color.fromARGB(255, 178, 140, 255),
                      size: 18,
                    ),
                    Text(
                      "Add intake via text description",
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.appleLabel,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
