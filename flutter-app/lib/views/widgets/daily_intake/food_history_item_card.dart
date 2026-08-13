import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/models/daily_intake_record.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/widgets/daily_intake/food_intake_detail_sheet_view.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class FoodHistoryItemCard extends StatefulWidget {
  const FoodHistoryItemCard({
    super.key,
    required this.item,
    required this.borderRadius,
    required this.isLast,
  });

  final DailyIntakeRecord item;
  final BorderRadius? borderRadius;
  final bool isLast;

  @override
  State<FoodHistoryItemCard> createState() => _FoodHistoryItemCardState();
}

class _FoodHistoryItemCardState extends State<FoodHistoryItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
    _loadDominantColor();
  }

  void _loadDominantColor() async {
    final imageUrl = widget.item.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return;

    final vm = context.read<UiViewModel>();
    final color = await vm.extractDominantColor(imageUrl);

    if (mounted) {
      setState(() {
        _dominantColor = color;
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemName = widget.item.intakeName ?? 'Unknown Item';

    // Only listen to isImageGenerating - minimal rebuilds
    final isImageGenerating = context.select(
      (DailyIntakeViewModel vm) => vm.isImageGenerating,
    );

    return GestureDetector(
      onTap: () {
        showCupertinoSheet<void>(
          context: context,
          builder: (context) => FoodIntakeDetailSheetView(itemCard: widget),
        );
        final userId = context
            .read<DailyIntakeViewModel>()
            .authService
            .currentUser
            ?.uid;
        if (userId != null) {
          context.read<DailyIntakeViewModel>().getIntakeDetailsByDailyIntakeId(
            userId,
            widget.item.id!,
          );
        }
      },
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SoftEdgeBlur(
              edges: [
                EdgeBlur(
                  type: EdgeType.bottomEdge,
                  size: 70,
                  sigma: 5,
                  tintColor: Colors.black.withValues(alpha: 0.3),
                  controlPoints: [
                    ControlPoint(position: 0.5, type: ControlPointType.visible),
                    ControlPoint(
                      position: 1,
                      type: ControlPointType.transparent,
                    ),
                  ],
                ),
              ],
              child: (widget.item.imageUrl == 'GENERATING')
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Container(
                              height: 125,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: const [
                                    Color.fromARGB(255, 237, 202, 149),
                                    Color.fromARGB(255, 253, 142, 81),
                                    Color.fromARGB(255, 255, 0, 85),
                                    Color.fromARGB(255, 0, 21, 255),
                                  ],
                                  stops: const [0.2, 0.4, 0.6, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  transform: GradientRotation(
                                    _shimmerController.value * 6.28,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : (widget.item.imageUrl == null ||
                        widget.item.imageUrl!.isEmpty)
                  ? Container(
                      height: 125,
                      width: double.infinity,
                      color: Colors.grey.shade900,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white24,
                        size: 40,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.item.imageUrl!,
                      fit: BoxFit.cover,
                      height: 125,
                      width: double.infinity,
                      memCacheWidth: 600,
                      errorWidget: (context, url, error) {
                        return Container(
                          height: 125,
                          width: double.infinity,
                          color: Colors.grey,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                          ),
                        );
                      },
                      placeholder: (context, url) {
                        return Container(
                          height: 125,
                          width: double.infinity,
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
                          DateFormat('h:mm a').format(widget.item.createdAt!),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          itemName,
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.label,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Text(
                        '${(widget.item.caloriesValue == 0 ? widget.item.energyValue : widget.item.caloriesValue).round()} ${widget.item.caloriesUnit ?? widget.item.energyUnit}',
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: AppColors.secondaryLabel,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isLast)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 0.5,
                    width: double.infinity,
                    color: AppColors.secondaryLabel.withOpacity(0.15),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
