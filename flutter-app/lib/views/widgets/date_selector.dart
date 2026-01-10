import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static const double _itemHeight = 70.0;
  static const double _itemWidth = 50.0;
  static const double _borderRadius = 16.0;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> dates = List.generate(daysToShow,
        (index) => now.subtract(Duration(days: daysToShow - 1 - index)));

    return SizedBox(
      height: _itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(selectedDate, date);
          final isFirstItem = index == 0;
          final isLastItem = index == dates.length - 1;

          return Padding(
            padding: EdgeInsets.only(
              left: isFirstItem ? 20 : 8,
              right: isLastItem ? 20 : 8,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(_borderRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(_borderRadius),
                onTap: () => onDateSelected(date),
                child: Ink(
                  width: _itemWidth,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(_borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
