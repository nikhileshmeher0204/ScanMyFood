import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/common/app_cupertino_picker.dart';
import 'package:read_the_label/views/widgets/common/app_picker_modal.dart';

class QuantityOption {
  final double value;
  final String label;

  const QuantityOption({
    required this.value,
    required this.label,
  });
}

class QuantitySelector extends StatefulWidget {
  const QuantitySelector({super.key});

  @override
  State<QuantitySelector> createState() => QuantitySelectorState();
}

const List<double> kServingValues = [0.25, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

class QuantitySelectorState extends State<QuantitySelector> {
  late final List<QuantityOption> _options;

  @override
  void initState() {
    super.initState();
    _options = kServingValues
        .map((v) => QuantityOption(value: v, label: v.toString()))
        .toList();
  }

  int _findIndexForQuantity(double quantity) {
    for (int i = 0; i < _options.length; i++) {
      if ((_options[i].value - quantity).abs() < 0.001) {
        return i;
      }
    }
    // Default to 1.0 (1 serving)
    return 2;
  }

  Widget _buildServingLabel(double value) {
    final isPlural = value != 1.0;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value % 1 == 0 ? value.toStringAsFixed(0) : value.toString(),
            style: const TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
          TextSpan(
            text: ' ${isPlural ? 'servings' : 'serving'}',
            style: const TextStyle(
              color: AppColors.secondaryBlackTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: AppTextStyles.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoSelector(BuildContext context, int initialIndex) {
    final uiViewModel = context.read<UiViewModel>();
    int tempIndex = initialIndex;

    showAppPickerModal(
      context,
      onDone: () {
        uiViewModel.updatePortionMultiplier(_options[tempIndex].value);
      },
      picker: AppCupertinoPicker(
        itemExtent: 44,
        useMagnifier: false, // matches previous default behavior
        magnification: 1.0,  // matches previous default behavior
        squeeze: 1.45,       // default squeeze
        scrollController:
            FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: (int index) {
          tempIndex = index;
        },
        children: _options.map((option) {
          return Center(child: _buildServingLabel(option.value));
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Selector<UiViewModel, double>(
        selector: (context, uiViewModel) => uiViewModel.portionMultiplier,
        builder: (context, portionMultiplier, child) {
          final selectedIndex = _findIndexForQuantity(portionMultiplier);
          final selectedValue = _options[selectedIndex].value;
          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showCupertinoSelector(context, selectedIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              width: double.infinity,
              child: Row(
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
                  const Spacer(),
                  _buildServingLabel(selectedValue),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.secondaryBlackTextColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
