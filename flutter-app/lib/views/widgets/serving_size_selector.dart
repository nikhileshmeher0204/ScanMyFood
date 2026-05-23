import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class ServingSizeOption {
  final double value;
  final String label;
  final bool isCustom;

  const ServingSizeOption({
    required this.value,
    required this.label,
    this.isCustom = false,
  });
}

class ServingSizeSelector extends StatefulWidget {
  final double totalQuantity;
  final double servingSize;

  const ServingSizeSelector(
    this.totalQuantity,
    this.servingSize, {
    super.key,
  });

  @override
  State<ServingSizeSelector> createState() => _ServingSizeSelectorState();
}

class _ServingSizeSelectorState extends State<ServingSizeSelector> {
  late List<ServingSizeOption> _options;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Build options: totalQuantity, servingSize, 100g
    _options = [
      ServingSizeOption(
          value: widget.totalQuantity,
          label: '${widget.totalQuantity.toStringAsFixed(0)}g'),
      const ServingSizeOption(value: 100, label: '100g'),
      ServingSizeOption(
          value: widget.servingSize,
          label: '${widget.servingSize.toStringAsFixed(0)}g'),
    ];
    final uiViewModel = context.read<UiViewModel>();
    _selectedIndex = _findIndexForServingSize(uiViewModel.servingSize);
  }

  int _findIndexForServingSize(double servingSize) {
    for (int i = 0; i < _options.length; i++) {
      if (_options[i].value == servingSize) {
        return i;
      }
    }
    // Default to servingSize if not found
    return 2;
  }

  void _onSelectionChanged(int? newIndex) {
    if (newIndex != null && newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
      final uiViewModel = context.read<UiViewModel>();
      uiViewModel.updateServingSize(_options[newIndex].value);
    }
  }

  String _getDisplayLabel(int index, double servingSize) {
    return _options[index].label;
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
              Icons.scale,
              color: AppColors.secondaryBlackTextColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              "Serving Size",
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
                  selector: (context, uiViewModel) => uiViewModel.servingSize,
                  builder: (context, servingSize, child) {
                    final Map<int, Widget> segmentWidgets = {};
                    for (int i = 0; i < _options.length; i++) {
                      segmentWidgets[i] = Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(
                          _getDisplayLabel(i, servingSize),
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodySmall,
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
