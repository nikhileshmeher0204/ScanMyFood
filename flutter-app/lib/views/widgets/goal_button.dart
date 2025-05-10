import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class GoalButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const GoalButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Image.asset(
              iconPath,
              // color: isSelected ? Colors.white : accentColor,
            ),
            // Title
            Text(title,
                textAlign: TextAlign.center, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
