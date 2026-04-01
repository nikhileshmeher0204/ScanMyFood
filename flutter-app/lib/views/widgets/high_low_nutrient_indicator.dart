import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

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
    String displayName = widget.nutrientName.toLowerCase();
    if (displayName.contains('total carbohydrate')) {
      displayName = 'CARBS';
    } else if (displayName.contains('dietary fiber')) {
      displayName = 'FIBER';
    } else if (displayName.contains('protein')) {
      displayName = 'PROTEIN';
    } else if (displayName.contains('total fat')) {
      displayName = 'FAT';
    } else {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }

    final bool isGood = widget.healthImpact == 'Good';
    final Color iconColor =
        isGood ? Colors.greenAccent.shade400 : Colors.redAccent.shade400;
    final IconData icon =
        widget.dvStatus == 'High' ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quantity and Unit in big font
          Text(
            '${widget.quantity}${widget.unit}',
            style: AppTextStyles.heading2Close
                .copyWith(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 6),
          // Arrow + Display Name below
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
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 4),
              Text(
                displayName,
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
