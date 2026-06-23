import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/viewmodels/user_view_model.dart';
import 'package:read_the_label/views/screens/product_analysis/product_analysis_view.dart';
import 'package:read_the_label/views/screens/food_analysis/food_analysis_view.dart';
import 'package:read_the_label/views/screens/daily_intake/daily_intake_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  late double _initialPage;

  @override
  void initState() {
    super.initState();
    final initialIndex = context.read<UiViewModel>().currentIndex;
    _initialPage = initialIndex.toDouble();
    _pageController = PageController(initialPage: initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<UserViewModel>()
          .fetchUserProfile(context.read<UserRepository>());
      context.read<DailyIntakeViewModel>().updateSelectedDate(DateTime.now());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _pageController,
        builder: (context, _) {
          final double page = _pageController.hasClients
              ? (_pageController.page ?? 0.0)
              : _initialPage;

          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              context.read<UiViewModel>().updateCurrentIndex(index);
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              final double offset = index - page;

              // Apple Music Style: Adjacent pages scale down and fade out gently
              final double scale =
                  (1.0 - (offset.abs() * 0.12)).clamp(0.88, 1.0);
              final double opacity =
                  (1.0 - (offset.abs() * 0.70)).clamp(0.0, 1.0);

              // Subtle parallax offset shift (slides slower/delayed relative to index stack)
              final double translationX = offset * 45.0;

              final Widget child = const [
                ProductAnalysisView(),
                FoodAnalysisView(),
                DailyIntakeView(),
              ][index];

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(translationX, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<UiViewModel>(
        builder: (context, uiProvider, _) {
          return Container(
            margin: const EdgeInsets.only(left: 48, right: 48, bottom: 28),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // Layer 1: Frosted glass blurring the content behind extending all the way
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  // Layer 2: Clean pill-capsule nav row
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCustomNavItem(
                          index: 0,
                          icon: Icons.document_scanner_outlined,
                          activeIcon: Icons.document_scanner,
                          label: 'Scan Label',
                          uiProvider: uiProvider,
                        ),
                        _buildCustomNavItem(
                          index: 1,
                          icon: Icons.restaurant_outlined,
                          activeIcon: Icons.restaurant,
                          label: 'Scan Food',
                          uiProvider: uiProvider,
                        ),
                        _buildCustomNavItem(
                          index: 2,
                          icon: Icons.pie_chart_outline_rounded,
                          activeIcon: Icons.pie_chart_rounded,
                          label: 'Intake',
                          uiProvider: uiProvider,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required UiViewModel uiProvider,
  }) {
    final bool isActive = uiProvider.currentIndex == index;
    return GestureDetector(
      onTap: () {
        uiProvider.updateCurrentIndex(index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isActive
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.primaryWhite
                  : AppColors.primaryWhite.withValues(alpha: 0.45),
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
