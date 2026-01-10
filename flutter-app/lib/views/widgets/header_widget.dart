import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({
    super.key,
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(selectedDate),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontFamily: 'Inter',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            // Date picker logic
          },
        ),
      ],
    );
  }
}
