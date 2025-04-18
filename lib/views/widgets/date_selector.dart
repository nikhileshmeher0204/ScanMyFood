import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/widgets/custom_date_picker_dialog.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final scrollController = ScrollController();
  final List<DateTime> dates = List.generate(
      7, (index) => DateTime.now().subtract(Duration(days: 6 - index)));
  @override
  void initState() {
    super.initState();
    // Nếu Today nằm ở nửa sau của list, scroll đến cuối
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dates.indexWhere((date) => date.day == DateTime.now().day) >
          dates.length ~/ 2) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              DateFormat('EEEE, dd MMMM yyyy').format(widget.selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final isSelected = widget.selectedDate.day == date.day;
                      final isToday = date.day == DateTime.now().day;
                      return GestureDetector(
                        onTap: () => widget.onDateSelected(date),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 20 : 12,
                            right: index == dates.length - 1 ? 12 : 12,
                          ),
                          child: Column(
                            children: [
                              Text(
                                isToday
                                    ? 'Today'
                                    : DateFormat('E').format(date),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey[600],
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Column(
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => CustomDatePickerDialog(
                          initialDate: widget.selectedDate,
                          onDateSelected: widget.onDateSelected,
                        ),
                      );
                      if (result == true) {
                        widget.onDateSelected(widget.selectedDate);
                      }
                    },
                    icon: PrimarySvgPicture(
                      Assets.icons.icCalendar.path,
                      color: Colors.green,
                      width: 28,
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
