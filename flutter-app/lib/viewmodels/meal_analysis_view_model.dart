import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class MealAnalysisViewModel extends BaseViewModel {
  // Dependencies
  SpringBackendRepository aiRepository;
  UiViewModel uiProvider;

  // Properties
  File? _foodImage;
  List<FoodItem> _analyzedFoodItems = [];
  Map<String, dynamic> _totalPlateNutrients = {};
  String _mealName = "Unknown Meal";

  // Getters
  File? get foodImage => _foodImage;
  List<FoodItem> get analyzedFoodItems => _analyzedFoodItems;
  Map<String, dynamic> get totalPlateNutrients => _totalPlateNutrients;
  String get mealName => _mealName;

  // Constructor with dependency injection
  MealAnalysisViewModel({
    required this.aiRepository,
    required this.uiProvider,
  });

  void setFoodImage(File imageFile) {
    _foodImage = imageFile;
    notifyListeners();
  }

  // Image capture method
  Future<void> captureImage({
    required ImageSource source,
  }) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      _foodImage = File(image.path);
      notifyListeners();
    }
  }

  // Analyze food image method
  Future<String> analyzeFoodImage({
    required File imageFile,
  }) async {
    uiProvider.setLoading(true);

    try {
      // Store the food image
      _foodImage = imageFile;

      // Use repository for AI analysis
      final response = await aiRepository.analyzeFoodImage(imageFile);

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
      debugPrint("Error analyzing food image: $e");
      setError("Error analyzing food image: $e");
      return "Error analyzing image";
    } finally {
      uiProvider.setLoading(false);
    }
  }

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

  // Update total nutrients when food items are modified
  void updateTotalNutrients() {
    _totalPlateNutrients = {
      'calories': 0.0,
      'protein': 0.0,
      'carbohydrates': 0.0,
      'fat': 0.0,
      'fiber': 0.0,
    };

    for (var item in _analyzedFoodItems) {
      var itemNutrients = item.calculateTotalNutrients();
      _totalPlateNutrients['calories'] =
          (_totalPlateNutrients['calories'] ?? 0.0) +
              (itemNutrients['calories'] ?? 0.0);
      _totalPlateNutrients['protein'] =
          (_totalPlateNutrients['protein'] ?? 0.0) +
              (itemNutrients['protein'] ?? 0.0);
      _totalPlateNutrients['carbohydrates'] =
          (_totalPlateNutrients['carbohydrates'] ?? 0.0) +
              (itemNutrients['carbohydrates'] ?? 0.0);
      _totalPlateNutrients['fat'] =
          (_totalPlateNutrients['fat'] ?? 0.0) + (itemNutrients['fat'] ?? 0.0);
      _totalPlateNutrients['fiber'] = (_totalPlateNutrients['fiber'] ?? 0.0) +
          (itemNutrients['fiber'] ?? 0.0);
    }

    notifyListeners();
  }

  // Clear the analyzed data
  void clearAnalysis() {
    _analyzedFoodItems.clear();
    _totalPlateNutrients = {};
    _mealName = "Unknown Meal";
    notifyListeners();
  }
}
