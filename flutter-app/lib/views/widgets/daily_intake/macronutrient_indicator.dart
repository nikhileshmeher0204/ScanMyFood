import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/common/rolling_text.dart';
import 'package:read_the_label/views/widgets/daily_intake/macronutrient_history_sheet_view.dart';

class MacronutrientIndicator extends StatelessWidget {
  final String label;
  final String nutrientName;
  final double goal;
  final String iconAsset; // asset path e.g. 'assets/icons/protein_icon.png'
  final Color color;

  const MacronutrientIndicator({
    super.key,
    required this.label,
    required this.nutrientName,
    required this.goal,
    required this.iconAsset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('REBUILD: MacronutrientIndicator ($label)');
    final value = context.select(
      (DailyIntakeViewModel vm) =>
          vm.totalNutrients?[nutrientName]?.quantity.value ?? 0.0,
    );
    final isOverflow = goal > 0 && value > goal;
    final rawPercent = goal > 0 ? (value / goal) : 0.0;
    final percent = rawPercent.clamp(0.0, 1.0);
    final activeColor = isOverflow
        ? Color.lerp(color, Colors.orangeAccent, 0.4)!
        : color;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          showCupertinoSheet<void>(
            context: context,
            builder: (context) => MacronutrientHistorySheetView(
              label: label,
              nutrientName: nutrientName,
              goal: goal,
              color: color,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverflow
                  ? activeColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.02),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isOverflow
                    ? activeColor.withOpacity(0.12)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconAsset,
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: activeColor, // label rendered in macro accent color
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOverflow) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: activeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(rawPercent * 100).toInt()}%',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: activeColor,
                  ),
                ],
              ),
              Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      RollingText(
                        text: value.toStringAsFixed(0),
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          color: isOverflow ? activeColor : AppColors.label,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        ' / ${goal.toStringAsFixed(0)}g',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: percent),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutQuint,
                      builder: (context, animPercent, child) {
                        return LinearProgressIndicator(
                          value: animPercent,
                          backgroundColor:
                              AppColors.secondaryLabel.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
