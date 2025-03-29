import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  // Current main navigation index
  int _currentIndex = 0;
  double _sliderValue = 0.0;
  double _servingSize = 0.0;

  int get currentIndex => _currentIndex;
  double get sliderValue => _sliderValue;
  double get servingSize => _servingSize;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateSliderValue(double value) {
    _sliderValue = value;
    notifyListeners();
  }

  void updateServingSize(double size) {
    _servingSize = size;
    // Update slider value to match full serving by default
    _sliderValue = 0.0;
    notifyListeners();
  }

  void applyPortion(double portion) {
    _sliderValue = _servingSize * portion;
    notifyListeners();
  }
}
