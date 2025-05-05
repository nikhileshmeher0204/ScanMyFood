import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class DescriptionAnalysisViewModel extends BaseViewModel {
  // Dependencies
  SpringBackendRepository aiRepository;
  UiViewModel uiProvider;

  DescriptionAnalysisViewModel({
    required this.aiRepository,
    required this.uiProvider,
  });

  List<FoodItem> _analyzedFoodItems = [];
  Map<String, dynamic> _totalPlateNutrients = {};
  String _mealName = "Unknown Meal";

  List<FoodItem> get analyzedFoodItems => _analyzedFoodItems;
  Map<String, dynamic> get totalPlateNutrients => _totalPlateNutrients;
  String get mealName => _mealName;

  // Text-based meal analysis
  Future<String> logMealViaText({
    required String foodItemsText,
  }) async {
    uiProvider.setLoading(true);

    try {
      debugPrint("Processing food items via text: \n$foodItemsText");

      // Use repository for text-based analysis
      final FoodAnalysisResponse response =
          await aiRepository.analyzeFoodDescription(foodItemsText);
      // Clear previous analysis
      _analyzedFoodItems.clear();
      _totalPlateNutrients.clear();

      _mealName = response.mealName;
      _analyzedFoodItems = response.analyzedFoodItems;
      _totalPlateNutrients = response.getSimpleTotalNutrients();

      debugPrint("Total Plate Nutrients:");
      debugPrint("Calories: ${_totalPlateNutrients['calories']}");
      debugPrint("Protein: ${_totalPlateNutrients['protein']}");
      debugPrint("Carbohydrates: ${_totalPlateNutrients['carbohydrates']}");
      debugPrint("Fat: ${_totalPlateNutrients['fat']}");
      debugPrint("Fiber: ${_totalPlateNutrients['fiber']}");

      notifyListeners();
      return "Analysis complete";
    } catch (e) {
      debugPrint("Error analyzing food description: $e");
      setError("Error analyzing food description: $e");
      return "Error";
    } finally {
      uiProvider.setLoading(false);
    }
  }
}
