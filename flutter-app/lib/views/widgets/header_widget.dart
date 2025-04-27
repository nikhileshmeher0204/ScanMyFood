import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget HeaderCard(BuildContext context, DateTime selectedDate) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Nutrition',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(selectedDate),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            // Date picker logic
          },
        ),
      ],
    ),
  );
}
