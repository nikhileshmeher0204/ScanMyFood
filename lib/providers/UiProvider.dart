import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  // Current main navigation index
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
