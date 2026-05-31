import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/views/screens/meal_analysis/meal_description_analysis_view.dart';
import 'package:read_the_label/views/widgets/daily_intake/food_input_form.dart';

class AddIntakeDescButton extends StatefulWidget {
  const AddIntakeDescButton({super.key});

  @override
  State<AddIntakeDescButton> createState() => _AddIntakeDescButtonState();
}

class _AddIntakeDescButtonState extends State<AddIntakeDescButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  static const Duration _animationDuration = Duration(seconds: 4);
  static const Duration _pauseDuration = Duration(seconds: 2);

  final List<String> _suggestions = const [
    'Add intake via text description',
    'e.g., "1 cup of black coffee"',
    'e.g., "Oatmeal with banana and honey"',
    'e.g., "2 scrambled eggs and toast"',
    'e.g., "150g grilled chicken with salad"',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(_pauseDuration, () {
            if (mounted) {
              setState(() {
                _currentIndex = (_currentIndex + 1) % _suggestions.length;
              });
              _animationController.reset();
              _animationController.forward();
            }
          });
        }
      });

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return GestureDetector(
          onTap: () {
            Navigator.of(innerContext, rootNavigator: true).push(
              CupertinoSheetRoute(
                builder: (sheetContext) => Material(
                  child: FoodInputForm(
                    onSubmit: () {
                      Navigator.of(sheetContext).push(
                        CupertinoPageRoute(
                          builder: (context) =>
                              const MealDescriptionAnalysisView(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              spacing: 12,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color.fromARGB(255, 0, 21, 255),
                  size: 20,
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _suggestions[_currentIndex],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: <Color>[
                                  Color.fromARGB(255, 0, 21, 255),
                                  Color.fromARGB(255, 255, 0, 85),
                                  Color.fromARGB(255, 255, 119, 0),
                                  Color.fromARGB(255, 250, 220, 194),
                                ],
                                stops: [
                                  0.1,
                                  0.5,
                                  0.7,
                                  1.0,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 300.0, 16.0),
                              ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
