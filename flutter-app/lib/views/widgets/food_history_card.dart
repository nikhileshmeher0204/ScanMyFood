import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/models/daily_intake_record.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/meal_description_analysis_view.dart';
import 'package:read_the_label/views/widgets/food_history_item_card.dart';
import 'package:read_the_label/views/widgets/food_input_form.dart';
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
                    .where((item) => isSameDay(item.createdAt, selectedDate))
                    .toList()
                  ..sort((a, b) =>
                      a.createdAt!.compareTo(b.createdAt!)); // Sort by time

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
              GestureDetector(
                onTap: () {
                  showCupertinoSheet<void>(
                    context: context,
                    enableDrag: true,
                    builder: (context) => Material(
                      child: FoodInputForm(
                        onSubmit: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => Consumer<UiViewModel>(
                                builder: (context, uiProvider, _) =>
                                    const MealDescriptionAnalysisView(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 237, 202, 149),
                        Color.fromARGB(255, 253, 142, 81),
                        Color.fromARGB(255, 255, 0, 85),
                        Color.fromARGB(255, 0, 21, 255),
                      ],
                      stops: [0.2, 0.4, 0.6, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    spacing: 5,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color.fromARGB(255, 0, 21, 255),
                        size: 20,
                      ),
                      Text(
                        "Add intake via text description",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: <Color>[
                                Color.fromARGB(255, 0, 21, 255),
                                Color.fromARGB(255, 255, 0, 85),
                                Color.fromARGB(255, 250, 220, 194),
                              ],
                              stops: [0.3, 0.5, 0.8],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 250.0, 16.0),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
