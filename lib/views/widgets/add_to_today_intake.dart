import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';

class AddToTodayIntakeButton extends StatelessWidget {
  const AddToTodayIntakeButton({
    super.key,
    required this.uiProvider,
    required this.productAnalysisProvider,
    required this.dailyIntakeProvider,
  });

  final UiViewModel uiProvider;
  final ProductAnalysisViewModel productAnalysisProvider;
  final DailyIntakeViewModel dailyIntakeProvider;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: uiProvider.sliderValue == 0
            ? Colors.grey
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 2,
        minimumSize: const Size(200, 50), // Set minimum width and height
      ),
      onPressed: () {
        if (uiProvider.sliderValue == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Please select your consumption to continue'), // Updated message
            ),
          );
        } else {
          dailyIntakeProvider.addToDailyIntake(
            source: 'label',
            productName: productAnalysisProvider.productName,
            nutrients: productAnalysisProvider.parsedNutrients,
            servingSize: uiProvider.servingSize,
            consumedAmount: uiProvider.sliderValue,
            imageFile: productAnalysisProvider.frontImage,
          );
          uiProvider.updateCurrentIndex(2);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Added to today\'s intake!'), // Updated message
              action: SnackBarAction(
                label: 'VIEW', // Changed from 'SHOW' to 'VIEW'
                onPressed: () {
                  Provider.of<UiViewModel>(context, listen: false)
                      .updateCurrentIndex(2);
                },
              ),
            ),
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrimarySvgPicture(
            Assets.icons.icAdd.path,
            width: 20,
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            children: [
              Text(
                "Add to today's intake",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Text(
                "${uiProvider.sliderValue.toStringAsFixed(0)} grams, ${(productAnalysisProvider.getCalories() * (uiProvider.sliderValue / uiProvider.servingSize)).toStringAsFixed(0)} calories",
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
