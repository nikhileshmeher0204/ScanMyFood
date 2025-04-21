import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/repositories/storage_repository.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/primary_button.dart';

void showRatingBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const RateAppBottomSheet(),
  );
}

class RateAppBottomSheet extends StatefulWidget {
  const RateAppBottomSheet({super.key});

  @override
  State<RateAppBottomSheet> createState() => _RateAppBottomSheetState();
}

class _RateAppBottomSheetState extends State<RateAppBottomSheet> {
  int number = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Rate our app',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'How would you rate our app experience?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            height: 80,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                              onTap: () {
                                if (number != index) {
                                  setState(() {
                                    number = index;
                                  });
                                }
                              },
                              child: SizedBox(
                                width: 38,
                                child: SvgPicture.asset(index <= number
                                    ? Assets.icons.icStar.path
                                    : Assets.icons.icStarNon.path),
                              )),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: number > 2 ? 'Rate on Google' : 'Rate',
            textStyle: TextStyle(
                color: number == -1 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
            backgroundColor: number == -1 ? AppColors.grey : AppColors.green,
            onPressed: () {
              if (number != -1) {
                if (number < 3) {
                  Navigator.pop(context);
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const FeedbackScreen(),
                  //     ));
                } else {
                  Navigator.pop(context);
                  openStoreListing();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void openStoreListing() async {
    if (await InAppReview.instance.isAvailable()) {
      try {
        context.read<StorageRepository>().setRate();
      } catch (_) {}
      await InAppReview.instance.openStoreListing();
    }
  }
}
