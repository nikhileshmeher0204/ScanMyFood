import 'package:flutter/material.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class TitleSectionWidget extends StatelessWidget {
  const TitleSectionWidget(
      {super.key,
      required this.title,
      this.onTapInfoButton,
      this.padding,
      this.color});
  final String title;
  final Function()? onTapInfoButton;
  final EdgeInsets? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFF1CAE54),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge!.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (onTapInfoButton != null)
            InkWell(
              onTap: onTapInfoButton,
              child: PrimarySvgPicture(Assets.icons.icInfo.path),
            )
        ],
      ),
    );
  }
}
