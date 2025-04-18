import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class CustomDatePickerDialog extends StatelessWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              calendarType: CalendarDatePicker2Type.single,
              calendarViewMode: CalendarDatePicker2Mode.day,
              disableMonthPicker: true,
              selectedDayHighlightColor: Colors.green,
              weekdayLabels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
              weekdayLabelTextStyle: const TextStyle(
                color: AppColors.black,
                fontFamily: 'Inter',
                fontSize: 12,
              ),
              dayTextStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xff858585),
              ),
              selectedDayTextStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white,
              ),
              controlsHeight: 50,
              controlsTextStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.black,
              ),
              lastMonthIcon: PrimarySvgPicture(Assets.icons.icArrowLeft.path),
              nextMonthIcon: PrimarySvgPicture(Assets.icons.icArrowRight.path),
            ),
            value: [initialDate],
            onValueChanged: (dates) {
              if (dates.isNotEmpty) {
                selectedDate = dates.first;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    onDateSelected(DateTime.now());
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDate != null) {
                      onDateSelected(selectedDate!);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
