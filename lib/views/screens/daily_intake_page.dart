import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/date_selector.dart';
import 'package:read_the_label/views/widgets/detailed_nutrients_card.dart';
import 'package:read_the_label/views/widgets/food_history_card.dart';
import 'package:read_the_label/views/widgets/macronutrien_summary_card.dart';

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
              MacronutrientSummaryCard(
                  context, dailyIntakeProvider.dailyIntake),
              FoodHistoryCard(
                  context: context,
                  currentIndex: 2,
                  selectedDate: _selectedDate),
              DetailedNutrientsCard(context, dailyIntakeProvider.dailyIntake),
            ],
          );
        }),
      ),
    );
  }
}
