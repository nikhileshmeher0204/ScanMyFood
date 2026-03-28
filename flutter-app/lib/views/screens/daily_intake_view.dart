import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/date_section_widget.dart';
import 'package:read_the_label/views/widgets/detailed_nutrients_card.dart';
import 'package:read_the_label/views/widgets/food_history_card.dart';
import 'package:read_the_label/views/widgets/calorie_card.dart';
import 'package:read_the_label/views/widgets/macronutrient_indicator_card.dart';
import 'package:read_the_label/views/widgets/user_switch_card.dart';

class DailyIntakeView extends StatefulWidget {
  const DailyIntakeView({super.key});

  @override
  State<DailyIntakeView> createState() => _DailyIntakeViewState();
}

class _DailyIntakeViewState extends State<DailyIntakeView> {
  @override
  void initState() {
    super.initState();
    // Initialize data only once when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    print("Initializing DailyIntakePage data...");
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);
    dailyIntakeProvider.updateSelectedDate(dailyIntakeProvider.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          pinned: true,
          expandedHeight: 90,
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.3,
            titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
            title: Text(
              'Daily Intake',
              style: AppTextStyles.heading2BoldClose,
            ),
            collapseMode: CollapseMode.pin,
          ),
        ),
        const SliverToBoxAdapter(
          child: _DailyIntakeContent(),
        ),
      ],
    );
  }
}

// Separate widget with granular selectors for optimal rebuilds
class _DailyIntakeContent extends StatelessWidget {
  const _DailyIntakeContent();

  @override
  Widget build(BuildContext context) {
    // Select only totalNutrients - only rebuilds when this changes
    final totalNutrients = context.select(
      (DailyIntakeViewModel vm) => vm.totalNutrients,
    );

    // Select only selectedDate - only rebuilds when this changes
    final selectedDate = context.select(
      (DailyIntakeViewModel vm) => vm.selectedDate,
    );

    // Get updateSelectedDate method without listening (no rebuilds)
    final updateSelectedDate =
        context.read<DailyIntakeViewModel>().updateSelectedDate;

    if (totalNutrients == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            DateSectionWidget(
              selectedDate: selectedDate,
              onDateSelected: updateSelectedDate,
            ),
            const SizedBox(height: 100),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const UserSwitchCard(),
          const SizedBox(height: 16),
          DateSectionWidget(
            selectedDate: selectedDate,
            onDateSelected: updateSelectedDate,
          ),
          const SizedBox(height: 24),
          CalorieCard(calories: totalNutrients[AppConstants.calories]),
          const SizedBox(height: 16),
          MacronutrientsIndicatorCard(totalNutrients: totalNutrients),
          const SizedBox(height: 24),
          const FoodHistoryCard(),
          const SizedBox(height: 16),
          DetailedNutrientsCard(totalNutrients: totalNutrients),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
