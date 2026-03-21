import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'date_selector.dart';

class DateSectionWidget extends StatelessWidget {
  const DateSectionWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.onCalendarTap,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date text with calendar icon
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(selectedDate),
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryWhite.withValues(alpha: 0.5),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  size: 20,
                ),
                onPressed: onCalendarTap ??
                    () {
                      // Date picker logic can be added here
                    },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Date selector
        DateSelector(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        ),
      ],
    );
  }
}
