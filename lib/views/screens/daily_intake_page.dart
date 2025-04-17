import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/widgets/date_selector.dart';
import 'package:read_the_label/views/widgets/detailed_nutrients_card.dart';
import 'package:read_the_label/views/widgets/food_history_card.dart';
import 'package:read_the_label/views/widgets/macronutrien_summary_card.dart';
import 'package:read_the_label/views/widgets/title_section_widget.dart';

class DailyIntakePage extends StatefulWidget {
  const DailyIntakePage({super.key});

  @override
  State<DailyIntakePage> createState() => _DailyIntakePageState();
}

class _DailyIntakePageState extends State<DailyIntakePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    print("Initializing DailyIntakePage data...");
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);

    // Debug check storage
    await dailyIntakeProvider.debugCheckStorage();

    // Load food history first
    print("Loading food history...");
    await dailyIntakeProvider.loadFoodHistory();

    // Then load daily intake for selected date
    print("Loading daily intake for selected date...");
    await dailyIntakeProvider.loadDailyIntake(DateTime.now());

    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 80,
          top: MediaQuery.of(context).padding.top + 10,
        ),
        child: Consumer<DailyIntakeViewModel>(
            builder: (context, dailyIntakeProvider, _) {
          return Column(
            children: [
              DateSelector(
                selectedDate: _selectedDate,
                onDateSelected: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                    dailyIntakeProvider.loadDailyIntake(newDate);
                  });
                },
              ),
              TitleSectionWidget(
                title: "Daily Nutrition",
              ),
              MacronutrientSummaryCard(
                  dailyIntake: dailyIntakeProvider.dailyIntake),
              TitleSectionWidget(
                title: "Today Intake",
                onTapInfoButton: () {
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
              FoodHistoryCard(
                  context: context,
                  currentIndex: 2,
                  selectedDate: _selectedDate),
              TitleSectionWidget(
                title: "Detailed Nutrients",
                onTapInfoButton: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      title: const Text('About Nutrients'),
                      content: const Text(
                        'This section shows detailed breakdown of your nutrient intake. Values are shown as percentage of daily recommended intake.',
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
              DetailedNutrientsCard(
                  dailyIntake: dailyIntakeProvider.dailyIntake),
            ],
          );
        }),
      ),
    );
  }
}
