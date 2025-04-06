import 'package:flutter/material.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/theme/app_theme.dart';

class AskAiWidget extends StatefulWidget {
  const AskAiWidget({super.key});

  @override
  State<AskAiWidget> createState() => _AskAiWidgetState();
}

class _AskAiWidgetState extends State<AskAiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  static const Duration _animationDuration = Duration(seconds: 4);
  static const Duration _pauseDuration = Duration(seconds: 2);

  final List<String> _suggestions = const [
    'What nutrients does this food contain?',
    'Is this food healthy for me?',
    'How many calories in this serving?',
    'What are the health benefits?',
    'Any allergens I should know about?',
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
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.cardBackground,
          border: Border.all(
            color: const Color.fromARGB(255, 255, 119, 0),
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color.fromARGB(255, 0, 21, 255),
                ),
                const SizedBox(width: 12),
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
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
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
                                ], // Four stops for four colors
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 250.0, 16.0),
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
        ),
      ),
    );
  }
}
