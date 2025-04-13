import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

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
    String statusIcon;

    switch (widget.healthSign) {
      case "Good":
        backgroundColor = AppColors.green.withOpacity(0.1);
        statusIcon = Assets.icons.icGood.path;
        break;
      case "Bad":
        backgroundColor = AppColors.red.withOpacity(0.1);
        statusIcon = Assets.icons.icBad.path;
        break;
      default: // "Moderate"
        backgroundColor = backgroundColor = AppColors.yellow.withOpacity(0.1);
        statusIcon = Assets.icons.icWarning.path;
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          width: _isExpanded ? MediaQuery.of(context).size.width - 32 : null,
          constraints: BoxConstraints(
            maxWidth: _isExpanded ? double.infinity : 170,
            minWidth: 140,
            minHeight: 80, // Add minimum height
            maxHeight: _isExpanded ? 300 : 80,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: SingleChildScrollView(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 0.5)
                                  .animate(_animationController),
                              child: PrimarySvgPicture(
                                Assets.icons.icArrowDown.path,
                                width: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PrimarySvgPicture(statusIcon, width: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        widget.nutrient,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Poppins',
                                          ),
                                          children: [
                                            TextSpan(
                                              text: widget.quantity,
                                              style: const TextStyle(
                                                color: AppColors.grey,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' | ${widget.dailyValue} DV',
                                              style: TextStyle(
                                                color: widget.healthSign ==
                                                        "Good"
                                                    ? AppColors.green
                                                    : widget.healthSign == "Bad"
                                                        ? AppColors.red
                                                        : AppColors.yellow,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
