import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/food_scan/food_lable_analysis_screen.dart';
import 'package:read_the_label/views/widgets/food_input_form.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final allItems =
                  context.watch<DailyIntakeViewModel>().foodHistory;
              final todayItems = allItems
                  .where(
                      (item) => isSameDay(item.dateTime, widget.selectedDate))
                  .toList();

              if (todayItems.isEmpty) {
                return const FoodHistoryItem();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayItems.length,
                itemBuilder: (context, index) {
                  final item = todayItems[index];
                  return FoodHistoryItem(
                    foodName: item.foodName,
                    dateTime: item.dateTime,
                    nutrients: item.nutrients,
                  );
                },
              );
            },
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: FoodInputForm(
                    onSubmit: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => Consumer<UiViewModel>(
                            builder: (context, uiProvider, _) =>
                                const FoodLableAnalysisScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimarySvgPicture(
                    Assets.icons.icAdd.path,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Add Food Item",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class FoodHistoryItem extends StatelessWidget {
  final String? foodName;
  final DateTime? dateTime;
  final Map<String, double>? nutrients;

  const FoodHistoryItem({
    super.key,
    this.foodName,
    this.dateTime,
    this.nutrients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName ?? "No Results Found!",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: foodName == null ? AppColors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (dateTime != null)
                      Text(
                        DateFormat('h:mma').format(dateTime!).toLowerCase(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (nutrients != null)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${nutrients!['Energy']?.toStringAsFixed(0) ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xffDADADA),
        ),
      ],
    );
  }
}
