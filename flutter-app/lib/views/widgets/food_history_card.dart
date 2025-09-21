import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/meal_description_analysis_view.dart';
import 'package:read_the_label/views/widgets/food_history_item_card.dart';
import 'package:read_the_label/views/widgets/food_input_form.dart';
import '../../theme/app_text_styles.dart';

class FoodHistoryCard extends StatefulWidget {
  final BuildContext context;
  final DateTime selectedDate;
  final int currentIndex;

  const FoodHistoryCard({
    super.key,
    required this.context,
    required this.selectedDate,
    required this.currentIndex,
  });

  @override
  State<FoodHistoryCard> createState() => _FoodHistoryCardState();
}

class _FoodHistoryCardState extends State<FoodHistoryCard> {
  @override
  Widget build(context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Intake',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryWhite,
                ),
                onPressed: () {
                  // Show info dialog about nutrients
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      title: const Text('Food Items History'),
                      content: const Text(
                        'This section shows all the food items you have consumed today, along with their caloric values and timestamps.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Consumer<DailyIntakeViewModel>(
                builder: (context, viewModel, child) {
              final todayItems = viewModel.foodHistory
                  .where(
                      (item) => isSameDay(item.dateTime, widget.selectedDate))
                  .toList()
                ..sort(
                    (a, b) => a.dateTime.compareTo(b.dateTime)); // Sort by time

              return ListView.builder(
                padding: const EdgeInsets.only(top: 5),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayItems.length,
                itemBuilder: (context, index) {
                  final item = todayItems[index];
                  final isFirst = index == 0;

                  final isLast = index == todayItems.length - 1;
                  final timeDifference = index > 0
                      ? _calculateTimeDifference(
                          todayItems[index - 1].dateTime, item.dateTime)
                      : null;

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
                  return FutureBuilder<Color>(
                    future: viewModel.extractDominantColor(item.imagePath),
                    builder: (context, snapshot) {
                      final tintColor =
                          snapshot.data ?? Colors.black.withOpacity(0.3);
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            child: Container(
                              height: 100, // Match food card height exactly
                              alignment: Alignment
                                  .center, // Center the time vertically
                              child: Text(
                                DateFormat('h:mm a').format(item.dateTime),
                                style: AppTextStyles.bodyMediumBold.copyWith(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign
                                    .center, // Changed from right to center
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Reduced from 12
                          // Food tile
                          FoodHistoryItemCard(
                              item: item,
                              tintColor: tintColor,
                              borderRadius: borderRadius,
                              isLast: isLast),
                        ],
                      );
                    },
                  );
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
                  children: [
                    const Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 0, 21, 255),
                    ),
                    Text(
                      "Add meal via text description",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: <Color>[
                              Color.fromARGB(255, 0, 21, 255),
                              Color.fromARGB(255, 255, 0, 85),
                              Color.fromARGB(255, 250, 220, 194),
                            ],
                            stops: [
                              0.3,
                              0.5,
                              0.8
                            ], // Four stops for four colors
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
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _calculateTimeDifference(DateTime earlier, DateTime later) {
    final difference = later.difference(earlier);
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}
