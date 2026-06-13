import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/daily_intake/date_section_widget.dart';
import 'package:read_the_label/views/widgets/daily_intake/food_history_card.dart';
import 'package:read_the_label/views/widgets/daily_intake/calorie_card.dart';
import 'package:read_the_label/views/widgets/daily_intake/macronutrient_indicator_card.dart';
import 'package:read_the_label/views/widgets/daily_intake/user_switch_card.dart';

import 'package:read_the_label/theme/app_colors.dart';

class DailyIntakeView extends StatefulWidget {
  const DailyIntakeView({super.key});

  @override
  State<DailyIntakeView> createState() => _DailyIntakeViewState();
}

class _DailyIntakeViewState extends State<DailyIntakeView> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    // Initialize data only once when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled =
        _scrollController.hasClients && _scrollController.offset != 0.0;
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    if (isScrolled != _isScrolled || scrollOffset != _scrollOffset) {
      setState(() {
        _isScrolled = isScrolled;
        _scrollOffset = scrollOffset;
      });
    }
  }

  void _initializeData() {
    print("Initializing DailyIntakePage data...");
    final dailyIntakeProvider =
        Provider.of<DailyIntakeViewModel>(context, listen: false);
    dailyIntakeProvider.updateSelectedDate(dailyIntakeProvider.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double baseExpandedHeight = 105.0;
    const double baseCollapsedHeight = 60.0;

    final double currentAppBarHeight = _scrollOffset < 0
        ? statusBarHeight + baseExpandedHeight - _scrollOffset
        : (statusBarHeight + baseExpandedHeight - _scrollOffset).clamp(
            statusBarHeight + baseCollapsedHeight,
            statusBarHeight + baseExpandedHeight);

    final double collapseProgress =
        _scrollOffset < 0 ? 0.0 : (_scrollOffset / 20.0).clamp(0.0, 1.0);

    final double fontSize = lerpDouble(37.0, 28.0, collapseProgress)!;
    final double letterSpacing = lerpDouble(-3.0, -1.8, collapseProgress)!;

    return Stack(
      children: [
        // Background Parallax Gradient
        Positioned(
          top: _scrollOffset < 0
              ? 0.0
              : -_scrollOffset * 0.7, // Pin to top when overscrolling
          left: 0,
          right: 0,
          height: _scrollOffset < 0
              ? 320.0 - _scrollOffset
              : 320.0, // Stretch dynamically
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.2, -1.0), // Very slight incline
                end: Alignment(0.2, 1.0),
                colors: [
                  AppColors.sunsetOrange, // Saturated sunset orange at the top
                  AppColors
                      .darkTeal, // Darker, rich green-teal that diffuses sooner
                  AppColors.midnightTeal, // Transition bridge almost pure black
                  Colors.black, // Pure black at the bottom for a seamless merge
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),
        ),
        // Scroll view content overlay wrapped in fixed-screen ShaderMask
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              if (height <= 0) return const SizedBox.shrink();
              final double stop1 =
                  (statusBarHeight + baseCollapsedHeight) / height;
              final double stop2 =
                  (statusBarHeight + baseExpandedHeight) / height;

              return ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Colors.transparent,
                      Colors.black,
                    ],
                    stops: [stop1, stop2],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: statusBarHeight + baseExpandedHeight,
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 90),
                      sliver: SliverToBoxAdapter(
                        child: _DailyIntakeContent(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Floating Apple-style Frosted Navigation Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: currentAppBarHeight,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 15 * collapseProgress,
                sigmaY: 15 * collapseProgress,
              ),
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.35 * collapseProgress,
                ),
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Intake',
                      style: AppTextStyles.heading1BoldClose.copyWith(
                        fontSize: fontSize,
                        letterSpacing: letterSpacing,
                        color: AppColors.getTitleColor(AppColors.sunsetOrange),
                      ),
                    ),
                    SizedBox(height: lerpDouble(12.0, 6.0, collapseProgress)!),
                  ],
                ),
              ),
            ),
          ),
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
    debugPrint('REBUILD: _DailyIntakeContent');
    // Select only whether totalNutrients is initialized - only rebuilds once
    final isInitialized = context.select(
      (DailyIntakeViewModel vm) => vm.totalNutrients != null,
    );

    if (!isInitialized) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 8),
            DateSectionWidget(),
            SizedBox(height: 100),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          UserSwitchCard(),
          DateSectionWidget(),
          CalorieCard(),
          MacronutrientsIndicatorCard(),
          FoodHistoryCard(),
        ],
      ),
    );
  }
}
