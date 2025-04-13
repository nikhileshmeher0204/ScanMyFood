import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:read_the_label/gen/assets.gen.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool useDefaultLeading;
  final Color? backgroundColor;
  final TextStyle? style;
  final bool? centerTitle;
  const PrimaryAppBar(
      {super.key,
      this.title,
      this.actions,
      this.backgroundColor,
      this.leading,
      this.useDefaultLeading = true,
      this.style,
      this.centerTitle = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Text(
        title ?? '',
        style: style ??
            const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
      ),
      leading: buildLeading(context),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  Widget? buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    } else {
      if (useDefaultLeading) {
        return IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(Assets.icons.icBack.path));
      } else {
        return null;
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
