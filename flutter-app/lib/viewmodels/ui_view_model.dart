import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';

class UiViewModel extends BaseViewModel {
  // UI state
  double _servingSize = 0.0;
  double _sliderValue = 0.0;
  int _currentIndex = 0;
  bool _isLoading = false;
  DateTime _selectedTime = DateTime.now();
  double _portionMultiplier = 1.0; // Add portion state

  int get currentIndex => _currentIndex;
  double get servingSize => _servingSize;
  double get sliderValue => _sliderValue;
  bool get loading => _isLoading;
  DateTime get selectedTime => _selectedTime;
  double get portionMultiplier => _portionMultiplier; // Add getter

  void setLoading(bool loading) {
    print("UiProvider: Setting loading to $loading");
    _isLoading = loading;
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateServingSize(double size) {
    _servingSize = size;
    print(_servingSize);
    notifyListeners();
  }

  void updateSliderValue(double value) {
    _sliderValue = value;
    notifyListeners();
  }

  void updateSelectedTime(DateTime time) {
    _selectedTime = time;
    notifyListeners();
  }

  void updatePortionMultiplier(double multiplier) {
    _portionMultiplier = multiplier;
    notifyListeners();
  }

  // Helper method to calculate adjusted nutrients
  Map<String, Quantity> calculateAdjustedNutrients(
      Map<String, Quantity> originalNutrients) {
    final Map<String, Quantity> result = {};
    originalNutrients.forEach((key, quantity) {
      // Create new Quantity with adjusted value but same unit
      result[key] = Quantity(
        value: quantity.value * _portionMultiplier,
        unit: quantity.unit,
      );
    });
    return result;
  }

  Color getColorForPercent(double percent) {
    if (percent > 1.0) return Colors.red; // Exceeded daily value
    if (percent > 0.8) return Colors.green; // High but not exceeded
    if (percent > 0.6) return Colors.yellow; // Moderate
    if (percent > 0.4) return Colors.yellow; // Low to moderate
    return Colors.green; // Low
  }

  IconData getNutrientIcon(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'energy':
        return Icons.bolt;
      case 'protein':
        return Icons.fitness_center;
      case 'carbohydrate':
        return Icons.grain;
      case 'fat':
        return Icons.opacity;
      case 'fiber':
        return Icons.grass;
      case 'sodium':
        return Icons.water_drop;
      case 'calcium':
        return Icons.shield;
      case 'iron':
        return Icons.architecture;
      case 'vitamin':
        return Icons.brightness_high;
      default:
        return Icons.science;
    }
  }

  String getUnit(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'energy':
        return ' kcal';
      case 'protein':
      case 'carbohydrate':
      case 'fat':
      case 'fiber':
      case 'sugar':
        return 'g';
      case 'sodium':
      case 'potassium':
      case 'calcium':
      case 'iron':
        return 'mg';
      default:
        return '';
    }
  }

  String getFormattedTime() {
    final hour = _selectedTime.hour == 0
        ? 12
        : (_selectedTime.hour > 12
            ? _selectedTime.hour - 12
            : _selectedTime.hour);
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  List<TextSpan> buildTimeTextSpans() {
    final timeString = getFormattedTime();
    final parts = timeString.split(' ');
    List<TextSpan> spans = [];

    if (parts.length >= 2) {
      // Time part (HH:MM)
      spans.add(TextSpan(
        text: "${parts[0]} ",
        style: const TextStyle(
          color: AppColors.primaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.fontFamily,
        ),
      ));

      // AM/PM part
      spans.add(TextSpan(
        text: parts[1],
        style: const TextStyle(
          color: AppColors.secondaryBlackTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.fontFamily,
        ),
      ));
    }

    return spans;
  }
}
