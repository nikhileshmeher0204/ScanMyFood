import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class PortionButton extends StatelessWidget {
  final double portion;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const PortionButton({
    super.key,
    required this.portion,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.primaryWhite : AppColors.cardBackground,
        foregroundColor:
            isSelected ? AppColors.primaryBlack : AppColors.primaryWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: isSelected ? 4 : 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.withColor(
          AppTextStyles.withWeight(
            AppTextStyles.bodyMedium,
            isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          isSelected ? AppColors.primaryBlack : AppColors.primaryWhite,
        ),
      ),
    );
  }
}

class CustomPortionButton extends StatelessWidget {
  final Function(double) onPortionChanged;

  const CustomPortionButton({
    super.key,
    required this.onPortionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              'Enter Custom Portion',
              style: AppTextStyles.withColor(
                AppTextStyles.heading3,
                AppColors.primaryWhite,
              ),
            ),
            content: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.withColor(
                AppTextStyles.bodyLarge,
                AppColors.primaryWhite,
              ),
              decoration: InputDecoration(
                hintText: 'Enter multiplier (e.g., 2.5)',
                hintStyle: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    AppColors.textSecondary,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'Apply',
                  style: AppTextStyles.withColor(
                    AppTextStyles.withWeight(
                      AppTextStyles.bodyMedium,
                      FontWeight.w600,
                    ),
                    AppColors.secondaryGreen,
                  ),
                ),
                onPressed: () {
                  final double? value = double.tryParse(_controller.text);
                  if (value != null && value > 0) {
                    onPortionChanged(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: Text(
        "Custom",
        style: AppTextStyles.withColor(
          AppTextStyles.bodyMedium,
          AppColors.primaryWhite,
        ),
      ),
    );
  }
}
