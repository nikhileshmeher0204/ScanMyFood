import 'package:flutter/material.dart';
import 'package:read_the_label/logic.dart';
import 'package:read_the_label/main.dart';

class PortionButton extends StatelessWidget {
  final BuildContext context;
  final double portion;
  final String label;
  final Logic logic;
  final Function(void Function()) setState;

  const PortionButton({
    super.key,
    required this.context,
    required this.portion,
    required this.label,
    required this.logic,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = (logic.sliderValue / logic.getServingSize()) == portion;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        setState(() {
          logic.updateSliderValue(logic.getServingSize() * portion, setState);
        });
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
  final Function(void Function()) setState;

  const CustomPortionButton({
    super.key,
    required this.logic,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
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
                logic.updateSliderValue(
                    double.tryParse(value) ?? 0.0, setState);
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
