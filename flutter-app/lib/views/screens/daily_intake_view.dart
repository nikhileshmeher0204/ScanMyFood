import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/date_selector.dart';
import 'package:read_the_label/views/widgets/detailed_nutrients_card.dart';
import 'package:read_the_label/views/widgets/food_history_card.dart';
import 'package:read_the_label/views/widgets/header_widget.dart';
import 'package:read_the_label/views/widgets/macronutrien_summary_card.dart';

class DailyIntakeView extends StatefulWidget {
  const DailyIntakeView({super.key});

  @override
  State<DailyIntakeView> createState() => _DailyIntakeViewState();
}

class _DailyIntakeViewState extends State<DailyIntakeView> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding.instance.addPostFrameCallback to defer initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    print("Initializing DailyIntakePage data...");
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);
    dailyIntakeProvider.getDailyIntake(user!.uid, _selectedDate);

    if (mounted) {
      setState(() {
        _selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            return Column(
              children: [
                HeaderCard(
                  selectedDate: _selectedDate,
                ),
                DateSelector(
                  context,
                  _selectedDate,
                  (DateTime newDate) {
                    setState(() {
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      final user = authService.currentUser;
                      _selectedDate = newDate;
                      dailyIntakeProvider.getDailyIntake(user!.uid, newDate);
                    });
                  },
                ),
                const MacronutrientSummaryCard(),
                FoodHistoryCard(
                    context: context,
                    currentIndex: 2,
                    selectedDate: _selectedDate),
                DetailedNutrientsCard(
                    totalNutrients: dailyIntakeProvider.totalNutrients),
              ],
            );
          }),
        ),
      ],
    );
  }
}
