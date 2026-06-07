import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/models/food_nutrient.dart';

class MacronutrientHistorySheetView extends StatefulWidget {
  final String label;
  final String nutrientName;
  final double goal;
  final Color color;
  final String unit;

  const MacronutrientHistorySheetView({
    super.key,
    required this.label,
    required this.nutrientName,
    required this.goal,
    required this.color,
    this.unit = 'g',
  });

  @override
  State<MacronutrientHistorySheetView> createState() => _MacronutrientHistorySheetViewState();
}

class _MacronutrientHistorySheetViewState extends State<MacronutrientHistorySheetView> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DailyIntakeViewModel>();
    final history = viewModel.getNutrientHistory(widget.nutrientName);

    if (history.isEmpty) {
      return Container(
        color: AppColors.background,
        height: 500,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Determine current index to highlight
    final activeIndex = _selectedIndex ?? (history.length - 1);
    final activeData = history[activeIndex];
    final activeValue = activeData['value'] as double;
    final activeDate = activeData['date'] as DateTime;

    // Calculate overall stats
    final totalSum = history.map((e) => e['value'] as double).reduce((a, b) => a + b);
    final avgValue = totalSum / history.length;
    final maxValue = history.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    final goalsMet = history.where((e) => (e['value'] as double) >= widget.goal).length;

    final isTodaySelected = activeIndex == history.length - 1;
    final dateString = isTodaySelected
        ? 'Today'
        : DateFormat('EEEE, MMM d').format(activeDate);

    final percentOfGoal = widget.goal > 0 ? (activeValue / widget.goal) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.label.toUpperCase()} HISTORY',
                    style: AppTextStyles.caption.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: Colors.white.withOpacity(0.18),
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Active day details / stats display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateString,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryLabel,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${activeValue.toStringAsFixed(0)}${widget.unit}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'of ${widget.goal.toStringAsFixed(0)}${widget.unit} goal',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Interactive Custom Painter Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AspectRatio(
                aspectRatio: 1.7,
                child: MacronutrientHistoryChart(
                  history: history,
                  goal: widget.goal,
                  color: widget.color,
                  selectedIndex: _selectedIndex,
                  onIndexSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Weekly Summary section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Weekly Summary',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Stats grid layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Daily Average',
                      value: '${avgValue.toStringAsFixed(1)}${widget.unit}',
                      color: widget.color,
                    ),
                  ),
                  Expanded(
                    child: _StatCard(
                      label: 'Goal Achievements',
                      value: '$goalsMet / 7 days',
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Weekly High',
                      value: '${maxValue.toStringAsFixed(0)}${widget.unit}',
                      color: widget.color,
                    ),
                  ),
                  Expanded(
                    child: _StatCard(
                      label: 'Remaining Today',
                      value: '${(widget.goal - (history.last['value'] as double)).clamp(0, double.infinity).toStringAsFixed(0)}${widget.unit}',
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.02),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryLabel,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
            ),
          ),
        ],
      ),
    );
  }
}

class MacronutrientHistoryChart extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  final double goal;
  final Color color;
  final int? selectedIndex;
  final ValueChanged<int?> onIndexSelected;

  const MacronutrientHistoryChart({
    super.key,
    required this.history,
    required this.goal,
    required this.color,
    required this.selectedIndex,
    required this.onIndexSelected,
  });

  @override
  State<MacronutrientHistoryChart> createState() => _MacronutrientHistoryChartState();
}

class _MacronutrientHistoryChartState extends State<MacronutrientHistoryChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTouch(Offset localPos, double width) {
    const double paddingLeft = 28.0;
    const double paddingRight = 28.0;
    final double drawWidth = width - paddingLeft - paddingRight;
    if (drawWidth <= 0) return;

    int index = ((localPos.dx - paddingLeft) / (drawWidth / 6)).round();
    index = index.clamp(0, 6);
    widget.onIndexSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
          onPanUpdate: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
          onTapDown: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
          onPanEnd: (_) => widget.onIndexSelected(null),
          onTapUp: (_) => widget.onIndexSelected(null),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: MacronutrientHistoryChartPainter(
                  history: widget.history,
                  goal: widget.goal,
                  color: widget.color,
                  animationValue: _animation.value,
                  selectedIndex: widget.selectedIndex,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MacronutrientHistoryChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;
  final double goal;
  final Color color;
  final double animationValue;
  final int? selectedIndex;

  MacronutrientHistoryChartPainter({
    required this.history,
    required this.goal,
    required this.color,
    required this.animationValue,
    required this.selectedIndex,
  });

  static const double paddingTop = 24.0;
  static const double paddingBottom = 28.0;
  static const double paddingLeft = 36.0;
  static const double paddingRight = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double drawWidth = size.width - paddingLeft - paddingRight;
    final double drawHeight = size.height - paddingTop - paddingBottom;
    if (drawWidth <= 0 || drawHeight <= 0) return;

    final double maxVal = history
        .map((e) => e['value'] as double)
        .reduce((a, b) => a > b ? a : b);
    final double maxY = (maxVal == 0.0 && goal == 0.0)
        ? 100.0
        : (maxVal > goal ? maxVal : goal) * 1.25;

    // Draw horizontal grid lines (Y-axis grid lines)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final double fraction = i / 4.0;
      final double y = paddingTop + drawHeight - fraction * drawHeight;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      final double val = fraction * maxY;
      final yLabelPainter = TextPainter(
        text: TextSpan(
          text: '${val.toStringAsFixed(0)}g',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      yLabelPainter.layout();
      yLabelPainter.paint(
        canvas,
        Offset(paddingLeft - yLabelPainter.width - 6, y - yLabelPainter.height / 2),
      );
    }

    // Map history to screen points
    final List<Offset> points = [];
    for (int i = 0; i < 7; i++) {
      final double x = paddingLeft + i * (drawWidth / 6);
      final double val = history[i]['value'] as double;
      // Interpolate value using the animation progress
      final double y = paddingTop + drawHeight - ((val * animationValue) / maxY) * drawHeight;
      points.add(Offset(x, y));
    }

    // Target dotted goal line
    final double targetY = paddingTop + drawHeight - (goal / maxY) * drawHeight;
    final targetPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    double startX = paddingLeft;
    while (startX < size.width - paddingRight) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(startX + dashWidth, targetY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Goal Label
    final targetTextPainter = TextPainter(
      text: TextSpan(
        text: 'GOAL: ${goal.toStringAsFixed(0)}g',
        style: TextStyle(
          color: color.withOpacity(0.6),
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    targetTextPainter.layout();
    targetTextPainter.paint(
      canvas,
      Offset(size.width - paddingRight - targetTextPainter.width, targetY - 14),
    );

    // Vertical guide line moved below primary line drawing layer for cleaner overlay

    // Build cubic bezier curve path for smooth rendering
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final double x0 = points[i].dx;
      final double y0 = points[i].dy;
      final double x1 = points[i + 1].dx;
      final double y1 = points[i + 1].dy;

      final double controlX1 = x0 + (x1 - x0) / 2;
      final double controlY1 = y0;
      final double controlX2 = x0 + (x1 - x0) / 2;
      final double controlY2 = y1;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x1, y1);
    }

    // Draw area gradient under the curve
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, paddingTop + drawHeight);
    fillPath.lineTo(points.first.dx, paddingTop + drawHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, paddingTop, size.width, paddingTop + drawHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw primary curve line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // Draw vertical guide line and glowing active cursor dot (Apple Stocks style)
    if (selectedIndex != null && selectedIndex! >= 0 && selectedIndex! < points.length) {
      final double selectX = points[selectedIndex!].dx;
      final selectLinePaint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..strokeWidth = 1.0;
      
      canvas.drawLine(
        Offset(selectX, paddingTop),
        Offset(selectX, paddingTop + drawHeight),
        selectLinePaint,
      );

      final Offset activePoint = points[selectedIndex!];
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // Outer glow ring
      final glowPaint = Paint()
        ..color = color.withOpacity(0.24)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 10.0, glowPaint);
      
      // Active center with white border
      final activePointBorder = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
        
      canvas.drawCircle(activePoint, 5.5, pointPaint);
      canvas.drawCircle(activePoint, 5.5, activePointBorder);
    }

    // X-Axis day labels
    final dateFormat = DateFormat('E');
    for (int i = 0; i < points.length; i++) {
      final date = history[i]['date'] as DateTime;
      final String label = dateFormat.format(date).substring(0, 1);
      final bool isActive = selectedIndex == i;

      final labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isActive ? color : Colors.white.withOpacity(0.35),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(points[i].dx - labelPainter.width / 2, paddingTop + drawHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MacronutrientHistoryChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.history != history ||
        oldDelegate.goal != goal ||
        oldDelegate.color != color;
  }
}
