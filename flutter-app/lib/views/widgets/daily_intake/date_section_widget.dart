import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/daily_intake/date_indicator.dart';

class DateSectionWidget extends StatelessWidget {
  const DateSectionWidget({super.key, this.onCalendarTap});

  final VoidCallback? onCalendarTap;

  @override
  Widget build(BuildContext context) {
    debugPrint('REBUILD: DateSectionWidget');
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
              Selector<DailyIntakeViewModel, DateTime>(
                selector: (context, vm) => vm.selectedDate,
                builder: (context, selectedDate, child) {
                  debugPrint(
                    'REBUILD: DateSectionWidget -> Selected Date Text',
                  );
                  return Text(
                    DateFormat('EEEE, MMMM d').format(selectedDate),
                    style: AppTextStyles.heading3.copyWith(
                      color: titleColor.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: titleColor.withValues(alpha: 0.8),
                  size: 20,
                ),
                onPressed:
                    onCalendarTap ??
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
        const DateIndicator(),
      ],
    );
  }
}
