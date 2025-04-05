import 'package:flutter/material.dart';

abstract class BaseViewModel extends ChangeNotifier {
  // Common error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
