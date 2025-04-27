import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/screens/food_analysis_screen.dart';
import 'package:read_the_label/views/widgets/food_input_form.dart';

class FoodHistoryCard extends StatefulWidget {
  final BuildContext context;
  final DateTime selectedDate;
  int currentIndex;

  FoodHistoryCard({
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
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Intake',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onTertiary,
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
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: context.watch<DailyIntakeViewModel>().foodHistory.length,
            itemBuilder: (context, index) {
              final item =
                  context.watch<DailyIntakeViewModel>().foodHistory[index];
              // Only show items from selected date
              if (isSameDay(item.dateTime, widget.selectedDate)) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      item.foodName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('h:mm a').format(item.dateTime),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    trailing: Text(
                      '${item.nutrients['Energy']?.toStringAsFixed(0) ?? 0} kcal',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox
                  .shrink(); // Return empty widget for non-matching dates
            },
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
                                const FoodAnalysisScreen(),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 0, 21, 255),
                  ),
                  Text(
                    "Add Food Item",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: <Color>[
                            Color.fromARGB(255, 0, 21, 255),
                            Color.fromARGB(255, 255, 0, 85),
                            Color.fromARGB(255, 250, 220, 194),
                          ],
                          stops: [0.3, 0.5, 0.8], // Four stops for four colors
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
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
