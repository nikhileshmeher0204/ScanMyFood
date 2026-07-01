import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/viewmodels/user_view_model.dart';
import 'package:read_the_label/views/screens/product_analysis/product_analysis_view.dart';
import 'package:read_the_label/views/screens/food_analysis/food_analysis_view.dart';
import 'package:read_the_label/views/screens/daily_intake/daily_intake_view.dart';
import 'package:read_the_label/views/screens/ask_ai/ask_ai_view.dart';

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
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
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
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    closedColor: Colors.transparent,
                    openColor: Colors.transparent,
                    closedShape: const CircleBorder(),
                    transitionDuration: const Duration(milliseconds: 550),
                    closedBuilder: (context, action) =>
                        _buildAskAiCircularButton(uiProvider, action),
                    openBuilder: (context, action) => const AskAiView(),
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

  Widget _buildAskAiCircularButton(UiViewModel uiProvider, VoidCallback openContainer) {
    return GestureDetector(
      onTap: openContainer,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Low intensity blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ),
              ),
              // Siri-like 3D animated orb
              const SiriWaveformOrb(size: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class SiriWaveformOrb extends StatefulWidget {
  final double size;

  const SiriWaveformOrb({super.key, this.size = 40});

  @override
  State<SiriWaveformOrb> createState() => _SiriWaveformOrbState();
}

class _SiriWaveformOrbState extends State<SiriWaveformOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SiriOrbPainter(_controller.value),
          );
        },
      ),
    );
  }
}

class _SiriOrbPainter extends CustomPainter {
  final double progress;

  _SiriOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.45;
    final t = progress * 2 * math.pi;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Blob 1: Violet/Indigo
    final offset1 = Offset(
      math.sin(t) * 3,
      math.cos(t) * 3,
    );
    final radius1 = baseRadius * (1.0 + 0.12 * math.sin(t * 2));
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6B4EFF).withOpacity(0.85),
          const Color(0xFF6B4EFF).withOpacity(0.0),
        ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center + offset1, radius: radius1));

    // Blob 2: Magenta/Pink
    final offset2 = Offset(
      math.cos(t + 1.5) * 4,
      math.sin(t + 1.5) * 4,
    );
    final radius2 = baseRadius * (0.95 + 0.15 * math.sin(t * 2 + 1.0));
    final paint2 = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF007F).withOpacity(0.85),
          const Color(0xFFFF007F).withOpacity(0.0),
        ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center + offset2, radius: radius2));

    // Blob 3: Cyan/Teal
    final offset3 = Offset(
      math.sin(t + 3.0) * 3.5,
      math.cos(t + 3.0) * 3.5,
    );
    final radius3 = baseRadius * (1.05 + 0.1 * math.sin(t * 2 + 2.0));
    final paint3 = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F2FE).withOpacity(0.85),
          const Color(0xFF00F2FE).withOpacity(0.0),
        ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center + offset3, radius: radius3));

    // Blob 4: Gold/Amber
    final offset4 = Offset(
      math.cos(t + 4.5) * 3,
      math.sin(t + 4.5) * 3,
    );
    final radius4 = baseRadius * (0.9 + 0.12 * math.cos(t * 2 + 3.0));
    final paint4 = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB300).withOpacity(0.75),
          const Color(0xFFFFB300).withOpacity(0.0),
        ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center + offset4, radius: radius4));

    canvas.drawCircle(center + offset1, radius1, paint1);
    canvas.drawCircle(center + offset2, radius2, paint2);
    canvas.drawCircle(center + offset3, radius3, paint3);
    canvas.drawCircle(center + offset4, radius4, paint4);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SiriOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

