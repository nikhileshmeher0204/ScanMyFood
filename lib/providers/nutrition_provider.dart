import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_item.dart';

class NutritionProvider extends ChangeNotifier {
  List<FoodItem> _analyzedFoodItems = [];
  Map<String, double> _totalPlateNutrients = {};

  // ... other properties and methods

  void updateFoodItemQuantity(int index, double newQuantity) {
    if (index >= 0 && index < _analyzedFoodItems.length) {
      _analyzedFoodItems[index].quantity = newQuantity;
      updateTotalNutrients();
      notifyListeners();
    }
  }

  void updateTotalNutrients() {
    // Calculate total nutrients from all food items
    _totalPlateNutrients = {
      'calories': 0.0,
      'protein': 0.0,
      'carbohydrates': 0.0,
      'fat': 0.0,
      'fiber': 0.0,
    };

    for (var item in _analyzedFoodItems) {
      final nutrients = item.calculateTotalNutrients();
      nutrients.forEach((key, value) {
        _totalPlateNutrients[key] = (_totalPlateNutrients[key] ?? 0.0) + value;
      });
    }

    notifyListeners();
  }
}
