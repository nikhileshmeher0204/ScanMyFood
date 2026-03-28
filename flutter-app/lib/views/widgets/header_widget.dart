import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

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
          style: AppTextStyles.heading3
              .copyWith(color: AppColors.primaryWhite.withValues(alpha: 0.5)),
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
