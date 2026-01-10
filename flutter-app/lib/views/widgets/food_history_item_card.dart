import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:read_the_label/models/daily_intake_record.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class FoodHistoryItemCard extends StatelessWidget {
  const FoodHistoryItemCard(
      {super.key,
      required this.item,
      required this.borderRadius,
      required this.isLast});

  final DailyIntakeRecord item;
  final BorderRadius? borderRadius;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final itemName = item.mealName ??
        item.mealDescriptionName ??
        item.productName ??
        'Unknown Item';

    final bool isNetworkImage = item.imageUrl != null &&
        (item.imageUrl!.startsWith('http://') ||
            item.imageUrl!.startsWith('https://'));
    final bool isLocalFile = item.imageUrl != null &&
        item.imageUrl!.isNotEmpty &&
        !isNetworkImage &&
        File(item.imageUrl!).existsSync();

    return ClipRRect(
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
                tintColor: Colors.black.withValues(alpha: 0.3),
                controlPoints: [
                  ControlPoint(
                    position: 0.4,
                    type: ControlPointType.visible,
                  ),
                  ControlPoint(
                    position: 1,
                    type: ControlPointType.transparent,
                  )
                ],
              )
            ],
            child: isNetworkImage
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    height: 100,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey,
                        child:
                            const Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey.shade800,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : isLocalFile
                    ? Image.file(
                        File(item.imageUrl!),
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white),
                      ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    spacing: 4,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      Text(
                        DateFormat('h:mm a').format(item.createdAt!),
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          fontSize: 10,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryWhite.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Text(
                      '${item.caloriesValue == 0 ? item.energyValue : item.caloriesValue} ${item.caloriesUnit ?? item.energyUnit}',
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
    );
  }
}
