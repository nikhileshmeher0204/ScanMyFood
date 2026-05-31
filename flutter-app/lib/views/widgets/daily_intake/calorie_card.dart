import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class CalorieCard extends StatelessWidget {
  final FoodNutrient? calories;
  const CalorieCard({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    const calorieGoal = 2000.0;
    final currentCalories = calories?.quantity.value ?? 0.0;
    final caloriePercent = (currentCalories / calorieGoal).clamp(0.0, 1.0);
    final caloriesLeft =
        (calorieGoal - currentCalories).clamp(0.0, calorieGoal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Left: compact metric ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label — CAPS + orange + asset icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/energy_icon.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'CALORIES',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.saturatedOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: AppColors.saturatedOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Number + unit inline — tight, Apple-compact
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentCalories.toInt().toString(),
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.label,
                        fontSize: 40,
                        letterSpacing: -2.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryLabel,
                        fontSize: 13,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Remaining — one compact line
                Text(
                  '${caloriesLeft.toInt()} kcal remaining',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryLabel,
                    height: null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ─── Right: Orange ring — compact, proportional ────────────
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(
                  painter: _AppleRingPainter(
                    percent: caloriePercent,
                    trackColor: const Color(0xFFE25227).withValues(alpha: 0.22),
                    ringGradient: const [
                      Color(0xFFFF7043),
                      Color(0xFFE25227),
                    ],
                    strokeWidth: 10.0,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(caloriePercent * 100).toInt()}%',
                    style: AppTextStyles.heading3Bold.copyWith(
                      color: AppColors.label,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'of goal',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.secondaryLabel,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Apple Activity Ring CustomPainter ──────────────────────────────────────
class _AppleRingPainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final List<Color> ringGradient;
  final double strokeWidth;

  _AppleRingPainter({
    required this.percent,
    required this.trackColor,
    required this.ringGradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (percent > 0) {
      final double sweep = 2 * math.pi * percent;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            colors: ringGradient,
            stops: const [0.0, 1.0],
            transform: const GradientRotation(-math.pi / 2),
          ).createShader(rect),
      );

      // End-cap shadow
      if (percent >= 0.05) {
        final double capAngle = -math.pi / 2 + sweep;
        canvas.drawCircle(
          Offset(
            center.dx + radius * math.cos(capAngle),
            center.dy + radius * math.sin(capAngle),
          ),
          strokeWidth / 2 + 0.5,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppleRingPainter old) =>
      old.percent != percent ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
