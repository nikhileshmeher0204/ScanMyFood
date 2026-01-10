import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/models/daily_intake_record.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/add_intake_desc_button.dart';
import 'package:read_the_label/views/widgets/food_history_item_card.dart';
import '../../theme/app_text_styles.dart';

class FoodHistoryCard extends StatelessWidget {
  final DateTime selectedDate;

  const FoodHistoryCard({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Intake',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Consumer<DailyIntakeViewModel>(
                  builder: (context, viewModel, child) {
                final List<DailyIntakeRecord> todayItems = viewModel
                    .userIntakeOutput!.dailyIntake
                    .where((item) =>
                        viewModel.isSameDay(item.createdAt, selectedDate))
                    .toList()
                  ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 5),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayItems.length,
                  itemBuilder: (context, index) {
                    final item = todayItems[index];
                    final isFirst = index == 0;

                    final isLast = index == todayItems.length - 1;

                    BorderRadius? borderRadius;
                    if (todayItems.length == 1) {
                      // Single item - rounded on all corners
                      borderRadius = BorderRadius.circular(16);
                    } else if (isFirst) {
                      // First item - rounded top corners only
                      borderRadius = const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      );
                    } else if (isLast) {
                      // Last item - rounded bottom corners only
                      borderRadius = const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      );
                    }
                    return FoodHistoryItemCard(
                        item: item, borderRadius: borderRadius, isLast: isLast);
                  },
                );
              }),
              const AddIntakeDescButton()
            ],
          ),
        ],
      ),
    );
  }
}
