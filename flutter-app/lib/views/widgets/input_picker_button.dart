import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class InputPickerButton extends StatelessWidget {
  final String label;

  const InputPickerButton({
    super.key,
    required this.label,
  });

  void _showTimePicker(BuildContext context) {
    final uiViewModel = Provider.of<UiViewModel>(context, listen: false);
    DateTime tempTime = uiViewModel.selectedTime;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.secondaryBlackTextColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyMedium,
                          AppColors.textSecondary,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: AppTextStyles.withColor(
                          AppTextStyles.withWeight(
                            AppTextStyles.bodyMedium,
                            FontWeight.w600,
                          ),
                          AppColors.secondaryGreen,
                        ),
                      ),
                      onPressed: () {
                        uiViewModel.updateSelectedTime(tempTime);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  backgroundColor: AppColors.cardBackground,
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: uiViewModel.selectedTime,
                  onDateTimeChanged: (DateTime newTime) {
                    tempTime = newTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Selector<UiViewModel, DateTime>(
        selector: (context, uiViewModel) => uiViewModel.selectedTime,
        builder: (context, selectedTime, child) {
          final uiViewModel = Provider.of<UiViewModel>(context, listen: false);
          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showTimePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              width: double.infinity,
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppColors.secondaryBlackTextColor,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: AppTextStyles.withColor(
                      AppTextStyles.heading4,
                      AppColors.primaryWhite,
                    ),
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: uiViewModel.buildTimeTextSpans(),
                    ),
                  ),
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
