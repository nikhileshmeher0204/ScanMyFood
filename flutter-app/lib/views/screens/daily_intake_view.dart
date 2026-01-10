import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/date_selector.dart';
import 'package:read_the_label/views/widgets/detailed_nutrients_card.dart';
import 'package:read_the_label/views/widgets/food_history_card.dart';
import 'package:read_the_label/views/widgets/header_widget.dart';
import 'package:read_the_label/views/widgets/macronutrien_summary_card.dart';

class DailyIntakeView extends StatelessWidget {
  const DailyIntakeView({super.key});

  void _initializeData(BuildContext context) {
    print("Initializing DailyIntakePage data...");
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);
    dailyIntakeProvider.updateSelectedDate(dailyIntakeProvider.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    // Initialize data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData(context);
    });

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          pinned: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.75,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Daily Intake',
              style: AppTextStyles.heading2BoldClose,
            ),
            collapseMode: CollapseMode.pin,
          ),
        ),
        SliverToBoxAdapter(
          child: Consumer<DailyIntakeViewModel>(
              builder: (context, dailyIntakeProvider, _) {
            if (dailyIntakeProvider.totalNutrients == null) {
              return Column(
                children: [
                  HeaderCard(
                    selectedDate: dailyIntakeProvider.selectedDate,
                  ),
                  DateSelector(
                    selectedDate: dailyIntakeProvider.selectedDate,
                    onDateSelected: dailyIntakeProvider.updateSelectedDate,
                  ),
                  const SizedBox(height: 100),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            }

            return Column(
              children: [
                HeaderCard(
                  selectedDate: dailyIntakeProvider.selectedDate,
                ),
                DateSelector(
                  selectedDate: dailyIntakeProvider.selectedDate,
                  onDateSelected: dailyIntakeProvider.updateSelectedDate,
                ),
                MacronutrientSummaryCard(
                    totalNutrients: dailyIntakeProvider.totalNutrients!),
                FoodHistoryCard(selectedDate: dailyIntakeProvider.selectedDate),
                DetailedNutrientsCard(
                    totalNutrients: dailyIntakeProvider.totalNutrients!),
              ],
            );
          }),
        ),
      ],
    );
  }
}
