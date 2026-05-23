import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_the_label/models/health_condition.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';

class HealthConditionCard extends StatelessWidget {
  final HealthCondition condition;
  final bool isSelected;
  final VoidCallback onTap;

  const HealthConditionCard({
    super.key,
    required this.condition,
    required this.isSelected,
    required this.onTap,
  });

  String get _iconPath {
    final snake = NutrientUtils.toSnakeCase(condition.name)
        .replaceAll('(', '')
        .replaceAll(')', '');
    return 'assets/icons/${snake}_icon.png';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSubtitle =
        condition.description != null && condition.description!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: Colors.transparent,
        highlightColor: AppColors.appleHighlight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: hasSubtitle ? 12 : 13,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Leading icon — desaturated → full colour ──────────────────
              Image.asset(
                _iconPath,
                width: 28,
                height: 28,
                color: isSelected ? null : AppColors.appleIconUnselected,
                colorBlendMode: isSelected ? null : BlendMode.modulate,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.health_and_safety_outlined,
                  size: 28,
                  color: isSelected
                      ? AppColors.secondaryGreen
                      : AppColors.appleIconUnselected,
                ),
              ),
              const SizedBox(width: 14),

              // ── Label + subtitle ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title weight nudge: w400 → w500 on selection
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: AppColors.appleLabel,
                        letterSpacing: -0.4,
                        height: 1.3,
                      ),
                      child: Text(condition.name),
                    ),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 3),
                      Text(
                        condition.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.appleSecondaryLabel,
                          letterSpacing: 0,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Trailing checkmark — spring animated ─────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        key: ValueKey('checked'),
                        color: AppColors.secondaryGreen,
                        size: 22,
                      )
                    : const Icon(
                        Icons.circle_outlined,
                        key: ValueKey('unchecked'),
                        color: AppColors.appleCheckmarkUnselected,
                        size: 22,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
