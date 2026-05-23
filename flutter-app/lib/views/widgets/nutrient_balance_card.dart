import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class NutrientBalanceCard extends StatefulWidget {
  final PrimaryConcern concern;

  const NutrientBalanceCard({
    super.key,
    required this.concern,
  });

  @override
  State<NutrientBalanceCard> createState() => _NutrientBalanceCardState();
}

class _NutrientBalanceCardState extends State<NutrientBalanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
          ),
          clipBehavior: Clip.antiAlias,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.secondaryRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.concern.issue,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.chevron_down,
                        color: AppColors.primaryWhite.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.concern.explanation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'RECOMMENDATIONS',
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: AppColors.secondaryGreen,
                            letterSpacing: -1.0,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.secondaryGreen,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...widget.concern.recommendations
                        .map((rec) => _RecommendationItem(
                              food: rec.food,
                              quantity: rec.quantity,
                              reasoning: rec.reasoning,
                            )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String food;
  final String quantity;
  final String reasoning;

  const _RecommendationItem({
    required this.food,
    required this.quantity,
    required this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: AppColors.secondaryGreen,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(text: food),
                      TextSpan(
                        text: ' • $quantity',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reasoning,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
