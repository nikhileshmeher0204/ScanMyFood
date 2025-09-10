import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class FoodHistoryItemCard extends StatelessWidget {
  const FoodHistoryItemCard(
      {super.key,
      required this.tintColor,
      required this.item,
      required this.borderRadius,
      required this.isLast});

  final Color tintColor;
  final item;
  final BorderRadius? borderRadius;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SoftEdgeBlur(
              edges: [
                EdgeBlur(
                  type: EdgeType.bottomEdge,
                  size: 100,
                  sigma: 100,
                  tintColor: tintColor,
                  controlPoints: [
                    ControlPoint(
                      position: 0.5,
                      type: ControlPointType.visible,
                    ),
                    ControlPoint(
                      position: 1,
                      type: ControlPointType.transparent,
                    )
                  ],
                )
              ],
              child: Image.file(
                File(item.imagePath),
                fit: BoxFit.cover,
                height: 100,
                width: double.infinity,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.foodName,
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            fontWeight: FontWeight.w800,
                            color:
                                AppColors.primaryWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      Text(
                        '${item.nutrients['Energy']?.toStringAsFixed(0) ?? 0} kcal',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: AppColors.primaryWhite.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 1,
                    width: double.infinity,
                    color: AppColors.primaryWhite.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
