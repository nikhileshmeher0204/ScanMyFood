import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysToShow = 7,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysToShow;

  static const double _borderRadius = 16.0;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive dimensions
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final itemSpacing = screenWidth * 0.015; // 1.5% of screen width
    final totalSpacing = itemSpacing * (daysToShow - 1);
    final itemWidth = (availableWidth - totalSpacing) / daysToShow;
    final itemHeight = itemWidth * 1.4; // Maintain aspect ratio

    final now = DateTime.now();
    final List<DateTime> dates = List.generate(daysToShow,
        (index) => now.subtract(Duration(days: daysToShow - 1 - index)));

    return SizedBox(
      height: itemHeight,
      child: Row(
        children: [
          for (int i = 0; i < dates.length; i++) ...[
            if (i > 0) SizedBox(width: itemSpacing),
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(_borderRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  onTap: () => onDateSelected(dates[i]),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: _isSameDay(selectedDate, dates[i])
                          ? AppColors.accent
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(dates[i]).substring(0, 1),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _isSameDay(selectedDate, dates[i])
                                ? AppColors.onPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dates[i].day}',
                          style: AppTextStyles.buttonTextWhite.copyWith(
                            color: _isSameDay(selectedDate, dates[i])
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
