import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/views/common/primary_button.dart';
import 'package:read_the_label/views/screens/food_scan/food_scan_result.dart';

class FoodScanPage extends StatelessWidget {
  const FoodScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 32,
        right: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            Assets.images.imScanFood.path,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),
          Text(
            "Snap a picture of your meal or pick one from your gallery",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Take Photo',
            onPressed: () =>
                _handleFoodImageCapture(context, ImageSource.camera),
            iconPath: Assets.icons.icCamera.path,
            backgroundColor: Theme.of(context).colorScheme.primary,
            borderRadius: 30,
            margin: const EdgeInsets.symmetric(horizontal: 30),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            width: 240,
            text: 'Gallery',
            onPressed: () =>
                _handleFoodImageCapture(context, ImageSource.gallery),
            iconPath: Assets.icons.icGallery.path,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 30,
            margin: const EdgeInsets.symmetric(horizontal: 30),
          ),
        ],
      ),
    );
  }

  void _handleFoodImageCapture(BuildContext context, ImageSource source) async {
    final mealAnalysisProvider =
        Provider.of<MealAnalysisViewModel>(context, listen: false);
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      mealAnalysisProvider.setFoodImage(File(image.path));
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FoodScanResultPage(),
          ),
        );
      }
    }
  }
}
