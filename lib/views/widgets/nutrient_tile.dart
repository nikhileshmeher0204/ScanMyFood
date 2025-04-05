import 'dart:ui';

import 'package:flutter/material.dart';

class NutrientGrid extends StatefulWidget {
  final List<NutrientData> nutrients;

  const NutrientGrid({
    super.key,
    required this.nutrients,
  });

  @override
  State<NutrientGrid> createState() => _NutrientGridState();
}

class _NutrientGridState extends State<NutrientGrid> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 20.0,
      children: widget.nutrients
          .map((nutrient) => NutrientTile(
                nutrient: nutrient.name,
                healthSign: nutrient.healthSign,
                quantity: nutrient.quantity,
                dailyValue: nutrient.dailyValue,
                insight: nutrient.insight,
              ))
          .toList(),
    );
  }
}

class NutrientTile extends StatefulWidget {
  final String nutrient;
  final String healthSign;
  final String quantity;
  final String dailyValue;
  final String? insight;

  const NutrientTile({
    super.key,
    required this.nutrient,
    required this.healthSign,
    required this.quantity,
    required this.dailyValue,
    this.insight,
  });

  @override
  State<NutrientTile> createState() => _NutrientTileState();
}

class _NutrientTileState extends State<NutrientTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData statusIcon;

    switch (widget.healthSign) {
      case "Good":
        backgroundColor =
            Theme.of(context).colorScheme.secondary.withOpacity(0.15);
        statusIcon = Icons.check_circle_outline;
        break;
      case "Bad":
        backgroundColor = Theme.of(context).colorScheme.error.withOpacity(0.15);
        statusIcon = Icons.warning_outlined;
        break;
      default: // "Moderate"
        backgroundColor =
            Theme.of(context).colorScheme.primary.withOpacity(0.15);
        statusIcon = Icons.info_outline;
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (_isExpanded) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          });
        },
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              width:
                  _isExpanded ? MediaQuery.of(context).size.width - 32 : null,
              constraints: BoxConstraints(
                maxWidth: _isExpanded ? double.infinity : 170,
                minWidth: 140,
                minHeight: 70, // Add minimum height
                maxHeight: _isExpanded ? 300 : 70,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: widget.healthSign == "Good"
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                      : widget.healthSign == "Bad"
                          ? const Color(0xFFFF5252).withValues(alpha: 0.3)
                          : const Color(0xFFFFC107).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: SingleChildScrollView(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 20,
                                    color: widget.healthSign == "Good"
                                        ? const Color(0xFF4CAF50)
                                        : widget.healthSign == "Bad"
                                            ? const Color(0xFFFF5252)
                                            : const Color(0xFFFFC107),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              widget.nutrient,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            RotationTransition(
                                              turns: Tween(begin: 0.0, end: 0.5)
                                                  .animate(
                                                      _animationController),
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              widget.quantity,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                fontSize: 11,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "| ${widget.dailyValue} DV",
                                              style: TextStyle(
                                                color: widget.healthSign ==
                                                        "Good"
                                                    ? const Color(0xFF4CAF50)
                                                    : widget.healthSign == "Bad"
                                                        ? const Color(
                                                            0xFFFF5252)
                                                        : const Color(
                                                            0xFFFFC107),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_isExpanded && widget.insight != null)
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _isExpanded ? 1.0 : 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      widget.insight!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        height: 1.5,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data model for nutrient information
class NutrientData {
  final String name;
  final String healthSign;
  final String quantity;
  final String dailyValue;
  final String? insight;

  NutrientData({
    required this.name,
    required this.healthSign,
    required this.quantity,
    required this.dailyValue,
    this.insight,
  });
}
