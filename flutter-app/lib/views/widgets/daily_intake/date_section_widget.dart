import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/widgets/common/date_selector.dart';

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
    const bgTeal = Color(0xFF0E3E39); // Deep teal background region
    final titleColor = AppColors.getTitleColor(bgTeal);

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
                  color: titleColor.withValues(alpha: 0.8),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: titleColor.withValues(alpha: 0.8),
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
