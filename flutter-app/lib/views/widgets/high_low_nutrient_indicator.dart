import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';

class HighLowNutrientIndicator extends StatefulWidget {
  final String nutrientName;
  final String dvStatus;
  final String healthImpact;
  final double quantity;
  final String unit;

  const HighLowNutrientIndicator({
    super.key,
    required this.nutrientName,
    required this.dvStatus,
    required this.healthImpact,
    required this.quantity,
    required this.unit,
  });

  @override
  State<HighLowNutrientIndicator> createState() =>
      _HighLowNutrientIndicatorState();
}

class _HighLowNutrientIndicatorState extends State<HighLowNutrientIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          milliseconds: 2300), // Total cycle time including pause
      vsync: this,
    )..repeat(); // repeat without reverse, the pause is handled by the Interval

    // Determines jump direction based on status
    final bool isUp = widget.dvStatus == 'High';
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: isUp ? -4.0 : 4.0)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 20, // Jump duration
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: isUp ? -4.0 : 4.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 30, // Return duration
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 50, // Pause duration
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displayName = NutrientUtils.toSnakeCase(widget.nutrientName);
    if (displayName.contains(AppConstants.totalCarbohydrate)) {
      displayName = 'Carbs';
    } else if (displayName.contains(AppConstants.dietaryFiber)) {
      displayName = 'Fiber';
    } else if (displayName.contains(AppConstants.protein)) {
      displayName = 'Protein';
    } else if (displayName.contains(AppConstants.totalFat)) {
      displayName = 'Fat';
    } else if (displayName.contains(AppConstants.sugar)) {
      displayName = 'Sugar';
    } else {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }

    final bool isGood = widget.healthImpact == 'Good';
    final Color iconColor =
        isGood ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;
    final IconData arrowIcon =
        widget.dvStatus == 'High' ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          spacing: 2,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${widget.quantity}${widget.unit}',
              style: AppTextStyles.heading2Close.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 20,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: child,
                    );
                  },
                  child: Icon(
                    arrowIcon,
                    color: iconColor,
                    size: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  displayName.toUpperCase(),
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
