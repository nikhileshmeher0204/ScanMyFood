import 'package:flutter/cupertino.dart';
import 'package:read_the_label/theme/app_colors.dart';

class AppCupertinoPicker extends StatelessWidget {
  final FixedExtentScrollController scrollController;
  final ValueChanged<int> onSelectedItemChanged;
  final List<Widget> children;
  final double itemExtent;
  final bool useMagnifier;
  final double magnification;
  final double squeeze;

  const AppCupertinoPicker({
    super.key,
    required this.scrollController,
    required this.onSelectedItemChanged,
    required this.children,
    this.itemExtent = 40.0,
    this.useMagnifier = true,
    this.magnification = 1.22,
    this.squeeze = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      magnification: magnification,
      squeeze: squeeze,
      useMagnifier: useMagnifier,
      backgroundColor: AppColors.cardBackground,
      itemExtent: itemExtent,
      scrollController: scrollController,
      onSelectedItemChanged: onSelectedItemChanged,
      children: children,
    );
  }
}
