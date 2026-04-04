import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';

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
                dvStatus: nutrient.dvStatus,
                goal: nutrient.goal,
                healthSign: nutrient.healthSign,
                quantity: nutrient.quantity,
                unit: nutrient.unit,
                dailyValue: nutrient.dailyValue,
                insight: nutrient.insight,
              ))
          .toList(),
    );
  }
}

class NutrientTile extends StatefulWidget {
  final String nutrient;
  final String dvStatus;
  final String goal;
  final String healthSign;
  final double quantity;
  final String unit;
  final double dailyValue;
  final String? insight;

  const NutrientTile({
    super.key,
    required this.nutrient,
    required this.dvStatus,
    required this.goal,
    required this.healthSign,
    required this.quantity,
    required this.unit,
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
    Color backgroundColor = AppColors.cardBackground;

    // Debug print to see actual values
    print('Nutrient: ${widget.nutrient}');
    print('DV Status: ${widget.dvStatus}');
    print('Goal: ${widget.goal}');
    print('Health Sign: ${widget.healthSign}');
    print('---');

    // Calculate the display text based on your logic
    String displayText;
    if ((widget.dvStatus == "High" && widget.goal == "At least") ||
        (widget.dvStatus == "Low" && widget.goal == "Less than")) {
      displayText = "Good";
    } else if (widget.dvStatus == "Low" && widget.goal == "At least") {
      displayText = "Insufficient";
    } else if (widget.dvStatus == "High" ||
        widget.dvStatus == "High" && widget.goal == "Less than") {
      displayText = "Limit";
    } else {
      displayText = "Moderate";
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
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 8,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: NutrientUtils.getNutrientIcon(
                                                    widget.nutrient) !=
                                                null
                                            ? Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Image.asset(
                                                  NutrientUtils.getNutrientIcon(
                                                      widget.nutrient)!,
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                            : null,
                                      ),
                                      Text(
                                        NutrientUtils.toTitleCase(
                                            widget.nutrient),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Text(
                                        "${widget.dailyValue} DV%",
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: displayText == "Good"
                                              ? AppColors.secondaryGreen
                                              : displayText == "Limit" ||
                                                      displayText ==
                                                          "Insufficient"
                                                  ? AppColors.secondaryRed
                                                  : AppColors.secondaryOrange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        _isExpanded
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        color: AppColors.primaryWhite
                                            .withValues(alpha: 0.7),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 28,
                                      ),
                                      Text(
                                        "${widget.quantity} ${widget.unit}",
                                        style: AppTextStyles.bodyLarge.copyWith(
                                            color: AppColors.primaryWhite
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w500),
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
                                  fontFamily: 'Inter',
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
    );
  }
}

// Data model for nutrient information
class NutrientData {
  final String name;
  final String healthSign;
  final String dvStatus;
  final String goal;
  final double quantity;
  final String unit;
  final double dailyValue;
  final String? insight;

  NutrientData({
    required this.name,
    required this.healthSign,
    required this.dvStatus,
    required this.goal,
    required this.quantity,
    required this.unit,
    required this.dailyValue,
    this.insight,
  });
}
