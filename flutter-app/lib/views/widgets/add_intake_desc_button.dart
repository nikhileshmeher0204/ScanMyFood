import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/screens/meal_description_analysis_view.dart';
import 'package:read_the_label/views/widgets/food_input_form.dart';

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
        return GestureDetector(
          onTap: () {
            showCupertinoSheet<void>(
              context: context,
              enableDrag: true,
              builder: (context) => Material(
                child: FoodInputForm(
                  onSubmit: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            const MealDescriptionAnalysisView(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color.fromARGB(255, 237, 202, 149),
                  Color.fromARGB(255, 253, 142, 81),
                  Color.fromARGB(255, 255, 0, 85),
                  Color.fromARGB(255, 0, 21, 255),
                ],
                stops: const [0.2, 0.4, 0.6, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_shimmerController.value * 6.28),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 0, 85)
                      .withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                  blurRadius: 15 + (_pulseController.value * 5),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              spacing: 5,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color.fromARGB(255, 0, 21, 255),
                  size: 20,
                ),
                Text(
                  "Add intake via text description",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryWhite.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
