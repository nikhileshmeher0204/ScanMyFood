import 'package:flutter/material.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? iconPath;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin; // Added margin property

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconPath,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.textStyle,
    this.iconColor,
    this.padding,
    this.margin, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor:
              foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          minimumSize: Size(width ?? double.infinity, height),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              PrimarySvgPicture(
                iconPath!,
                height: 24,
                width: 24,
                color: iconColor ??
                    foregroundColor ??
                    Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: textStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: foregroundColor ??
                        Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
