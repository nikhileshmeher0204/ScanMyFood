import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class PortionButton extends StatelessWidget {
  final double portion;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const PortionButton({
    super.key,
    required this.portion,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.cardBackground,
        foregroundColor: isSelected
            ? Colors.white
            : Theme.of(context).textTheme.bodyMedium!.color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium!.color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class CustomPortionButton extends StatelessWidget {
  final Function(double) onPortionChanged;

  const CustomPortionButton({
    super.key,
    required this.onPortionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

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
            backgroundColor: Theme.of(context).colorScheme.cardBackground,
            title: Text(
              'Enter Custom Portion',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontFamily: 'Inter',
              ),
            ),
            content: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                hintText: 'Enter multiplier (e.g., 2.5)',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color
                      ?.withOpacity(0.5),
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Inter',
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'Apply',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  final double? value = double.tryParse(_controller.text);
                  if (value != null && value > 0) {
                    onPortionChanged(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: Text(
        "Custom",
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
