import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget DateSelector(BuildContext context, DateTime selectedDate,
    Function(DateTime) onDateSelected) {
  final List<DateTime> dates = List.generate(
      7, (index) => DateTime.now().subtract(Duration(days: 6 - index)));
  return Container(
    height: 70,
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isSelected = selectedDate.day == date.day;
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 20 : 8,
            right: index == dates.length - 1 ? 20 : 8,
          ),
          child: Material(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onDateSelected(date),
              child: Container(
                width: 50,
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
                  borderRadius: BorderRadius.circular(16),
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
                        fontFamily: 'Poppins',
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
                        fontFamily: 'Poppins',
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
