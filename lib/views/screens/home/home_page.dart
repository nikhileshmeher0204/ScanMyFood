import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/common/logo_appbar.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/scan_lable/product_scan_page.dart';
import 'package:read_the_label/views/screens/food_scan/food_scan_page.dart';
import 'package:read_the_label/views/screens/daily_intake/daily_intake_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const LogoAppbar(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Consumer<UiViewModel>(
              builder: (context, uiProvider, _) {
                return IndexedStack(
                  key: ValueKey<int>(uiProvider.currentIndex),
                  index: uiProvider.currentIndex,
                  children: [
                    AnimatedOpacity(
                      opacity: uiProvider.currentIndex == 0 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const ProductScanPage(),
                    ),
                    AnimatedOpacity(
                      opacity: uiProvider.currentIndex == 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const FoodScanPage(),
                    ),
                    AnimatedOpacity(
                      opacity: uiProvider.currentIndex == 2 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const DailyIntakePage(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<UiViewModel>(
      builder: (context, uiProvider, _) {
        return Container(
          color: Theme.of(context).colorScheme.cardBackground,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BottomNavigationBar(
            elevation: 0,
            selectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 10,
              height: 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 10,
              height: 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            backgroundColor: Colors.transparent,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: const Color(0xff6B6B6B),
            currentIndex: uiProvider.currentIndex,
            onTap: (index) {
              uiProvider.updateCurrentIndex(index);
            },
            items: [
              _buildNavItem(
                'Scan Label',
                Assets.icons.icScanLable.path,
                0,
                uiProvider.currentIndex,
                context,
              ),
              _buildNavItem(
                'Scan Food',
                Assets.icons.icScanFood.path,
                1,
                uiProvider.currentIndex,
                context,
              ),
              _buildNavItem(
                'Daily Intake',
                Assets.icons.icDailyIntake.path,
                2,
                uiProvider.currentIndex,
                context,
              ),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String label,
    String iconPath,
    int index,
    int currentIndex,
    BuildContext context,
  ) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 2,
            width: 10,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: PrimarySvgPicture(
              iconPath,
              width: 32,
              height: 32,
              color: index == currentIndex
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
