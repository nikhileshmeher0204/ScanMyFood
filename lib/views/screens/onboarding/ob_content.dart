import 'package:flutter/material.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_colors.dart';

class OBContent extends StatelessWidget {
  const OBContent(
      {super.key,
      required this.onPressContinue,
      required this.image,
      required this.index});
  final Function() onPressContinue;
  final String image;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(image, fit: BoxFit.fitWidth),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "onboarding_title_$index",
                        textAlign: TextAlign.center,
                        // style: AppTextTheme.blackS24
                        //     .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                    onTap: onPressContinue,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        index == 4 ? "get_started" : "next",
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: index == 1
                            ? AppColors.red
                            : const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: index == 2
                            ? AppColors.red
                            : const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: index == 3
                            ? AppColors.red
                            : const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: index == 4
                            ? AppColors.red
                            : const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
