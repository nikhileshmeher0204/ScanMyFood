import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class QuantityOption {
  final double value;
  final String label;
  final bool isCustom;

  const QuantityOption({
    required this.value,
    required this.label,
    this.isCustom = false,
  });
}

class QuantitySelector extends StatefulWidget {
  final List<QuantityOption> options;

  const QuantitySelector({
    super.key,
    this.options = const [
      QuantityOption(value: 0.25, label: '1/4'),
      QuantityOption(value: 0.5, label: '1/2'),
      QuantityOption(value: 1.0, label: 'Full'),
      QuantityOption(value: 0.0, label: 'Custom', isCustom: true),
    ],
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _selectedIndex = 2; // Default to "Full"

  @override
  void initState() {
    super.initState();
    final uiViewModel = context.read<UiViewModel>();
    _selectedIndex = _findIndexForQuantity(uiViewModel.portionMultiplier);
  }

  int _findIndexForQuantity(double quantity) {
    for (int i = 0; i < widget.options.length; i++) {
      if (!widget.options[i].isCustom && widget.options[i].value == quantity) {
        return i;
      }
    }
    // If not found in predefined options, it's a custom value
    return widget.options.indexWhere((option) => option.isCustom);
  }

  void _onSelectionChanged(int? newIndex) {
    if (newIndex != null && newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });

      final uiViewModel = context.read<UiViewModel>();
      if (widget.options[newIndex].isCustom) {
        _showCustomQuantityDialog(uiViewModel);
      } else {
        uiViewModel.updatePortionMultiplier(widget.options[newIndex].value);
      }
    }
  }

  void _showCustomQuantityDialog(UiViewModel uiViewModel) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Enter Custom Quantity',
          style: AppTextStyles.withColor(
            AppTextStyles.heading3,
            AppColors.primaryWhite,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
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
            onPressed: () {
              Navigator.of(context).pop();
              // Reset to previous selection if cancelled
              setState(() {
                _selectedIndex =
                    _findIndexForQuantity(uiViewModel.portionMultiplier);
              });
            },
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
              final double? value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                uiViewModel.updatePortionMultiplier(value);
              } else {
                // Reset to previous selection if invalid input
                setState(() {
                  _selectedIndex =
                      _findIndexForQuantity(uiViewModel.portionMultiplier);
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _getDisplayLabel(int index, double portionMultiplier) {
    final option = widget.options[index];
    if (option.isCustom &&
        portionMultiplier != option.value &&
        _selectedIndex == index) {
      return '${portionMultiplier}x';
    }
    return option.label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.restaurant,
              color: AppColors.secondaryBlackTextColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              "Quantity",
              style: AppTextStyles.withColor(
                AppTextStyles.heading4,
                AppColors.primaryWhite,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Selector<UiViewModel, double>(
                  selector: (context, uiViewModel) =>
                      uiViewModel.portionMultiplier,
                  builder: (context, portionMultiplier, child) {
                    final Map<int, Widget> segmentWidgets = {};

                    for (int i = 0; i < widget.options.length; i++) {
                      segmentWidgets[i] = Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(
                          _getDisplayLabel(i, portionMultiplier),
                          style: AppTextStyles.withColor(
                            AppTextStyles.withWeight(
                              AppTextStyles.bodySmall,
                              FontWeight.w500,
                            ),
                            _selectedIndex == i
                                ? AppColors.primaryBlack
                                : AppColors.primaryWhite,
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedIndex,
                        onValueChanged: _onSelectionChanged,
                        children: segmentWidgets,
                        backgroundColor: AppColors.primaryBlack,
                        thumbColor: AppColors.primaryWhite,
                        padding: const EdgeInsets.all(4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
