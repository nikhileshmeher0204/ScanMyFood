import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<DateTime> dates = List.generate(
        7, (index) => DateTime.now().subtract(Duration(days: 6 - index)));
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = selectedDate.day == date.day;
                final isToday = date.day == DateTime.now().day;
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 20 : 12,
                    right: index == dates.length - 1 ? 12 : 12,
                  ),
                  child: Column(
                    children: [
                      Text(
                        isToday ? 'Today' : DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.green : Colors.grey[600],
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => onDateSelected(date),
                        child: Column(
                          children: [
                            Text(
                              '${date.day} ${DateFormat('MMM').format(date)}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.grey[600],
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (isSelected)
                              Container(
                                height: 2,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: IconButton(
              onPressed: () {},
              icon: PrimarySvgPicture(
                Assets.icons.icCalendar.path,
                color: Colors.green,
                width: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
