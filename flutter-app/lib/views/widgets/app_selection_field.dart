import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';

class AppSelectionField extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconPath;
  final bool showLabelAbove;

  const AppSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.iconPath,
    this.showLabelAbove = false,
  });

  @override
  State<AppSelectionField> createState() => _AppSelectionFieldState();
}

class _AppSelectionFieldState extends State<AppSelectionField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabelAbove && widget.label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                Colors.white70,
              ),
            ),
          ),
        ],
        GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: AppColors.secondaryBlackTextColor,
                      size: 20, // QuantitySelector uses size 20
                    ),
                    const SizedBox(width: 16),
                  ] else if (widget.iconPath != null) ...[
                    Image.asset(
                      widget.iconPath!,
                      width: 20,
                      height: 20,
                      color: AppColors.secondaryBlackTextColor,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    widget.label,
                    style: AppTextStyles.withColor(
                      AppTextStyles.heading4,
                      AppColors.primaryWhite,
                    ).copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.secondaryBlackTextColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
