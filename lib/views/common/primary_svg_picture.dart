import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrimarySvgPicture extends StatelessWidget {
  final String assets;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit? fit;
  const PrimarySvgPicture(this.assets,
      {super.key, this.color, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(assets,
        width: width,
        height: height,
        fit: fit ?? BoxFit.scaleDown,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null);
  }
}
