import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  // UI state
  double _servingSize = 0.0;
  double _sliderValue = 0.0;
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  double get servingSize => _servingSize;
  double get sliderValue => _sliderValue;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateServingSize(double size) {
    _servingSize = size;
    notifyListeners();
  }

  void updateSliderValue(double value) {
    _sliderValue = value;
    notifyListeners();
  }

  Color getColorForPercent(double percent) {
    if (percent > 1.0) return Colors.red; // Exceeded daily value
    if (percent > 0.8) return Colors.green; // High but not exceeded
    if (percent > 0.6) return Colors.yellow; // Moderate
    if (percent > 0.4) return Colors.yellow; // Low to moderate
    return Colors.green; // Low
  }
}
