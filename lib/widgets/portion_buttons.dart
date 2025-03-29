import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/logic.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/providers/UiProvider.dart';

class PortionButton extends StatelessWidget {
  final double portion;
  final String label;

  const PortionButton({
    super.key,
    required this.portion,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final uiProvider = context.watch<UiProvider>();
    bool isSelected =
        (uiProvider.sliderValue / uiProvider.servingSize) == portion;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        context.read<UiProvider>().applyPortion(portion);
        print("✅Portion selected: $portion");
      },
      child: Text(label,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontFamily: 'Poppins')),
    );
  }
}

class CustomPortionButton extends StatelessWidget {
  final Logic logic;

  const CustomPortionButton({
    super.key,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    final uiProvider = context.watch<UiProvider>();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text('Enter Custom Amount',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontFamily: 'Poppins')),
            content: TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: 'Enter amount in grams',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              onChanged: (value) {
                context
                    .read<UiProvider>()
                    .updateSliderValue(double.tryParse(value) ?? 0.0);
              },
            ),
            actions: [
              TextButton(
                child: Text('OK',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontFamily: 'Poppins')),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      child: Text("Custom",
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontFamily: 'Poppins')),
    );
  }
}
