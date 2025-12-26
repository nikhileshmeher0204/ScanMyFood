import 'package:flutter/material.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/models/quantity.dart';
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
  Map<String, Quantity> _totalPlateNutrients = {};
  String _mealName = "Unknown Meal";

  List<FoodItem> get analyzedFoodItems => _analyzedFoodItems;
  Map<String, Quantity> get totalPlateNutrients => _totalPlateNutrients;
  String get mealName => _mealName;
  List<Map<String, dynamic>> _nutrientInfo = [];
  List<Map<String, dynamic>> get nutrientInfo => _nutrientInfo;

  // Text-based meal analysis
  Future<void> logMealViaText({
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
      _totalPlateNutrients = response.totalPlateNutrients;
      calculateNutrientInfo(_totalPlateNutrients);

      debugPrint("Total Plate Nutrients:");
      debugPrint("Calories: ${_totalPlateNutrients['calories']}");
      debugPrint("Protein: ${_totalPlateNutrients['protein']}");
      debugPrint("Carbohydrates: ${_totalPlateNutrients['carbohydrates']}");
      debugPrint("Fat: ${_totalPlateNutrients['fat']}");
      debugPrint("Fiber: ${_totalPlateNutrients['fiber']}");

      notifyListeners();
    } catch (e) {
      debugPrint("Error analyzing food description: $e");
      setError("Error analyzing food description: $e");
    } finally {
      uiProvider.setLoading(false);
    }
  }

  void calculateNutrientInfo(Map<String, dynamic> _totalScannedPlateNutrients) {
    logger.i("=== Starting calculateNutrientInfo ===");
    logger.i("Input nutrients: $_totalScannedPlateNutrients");

    // Clear previous data
    _nutrientInfo.clear();

    // Map from nutrient keys to display names
    Map<String, String> keyMapping = {
      'calories': 'Energy',
      'protein': 'Protein',
      'carbohydrates': 'Carbohydrate',
      'fat': 'Fat',
      'fiber': 'Fiber',
      'sodium': 'Sodium',
      'sugar': 'Total Sugars',
      'saturated_fat': 'Saturated Fat',
    };

    // Perform calculations on the totalPlateNutrients
    _totalScannedPlateNutrients.forEach((key, value) {
      logger.i("Processing nutrient: $key with value: $value");

      String dvStatus = '';
      String goal = '';
      String healthImpact = '';

      // Get the proper nutrient name for insights lookup
      String nutrientName = keyMapping[key.toLowerCase()] ?? key;
      logger.i("Mapped nutrient name: $nutrientName");

      // Find the matching nutrient data
      try {
        var matchingNutrient = nutrientData.firstWhere(
          (nutrient) =>
              nutrient['Nutrient'].toString().toLowerCase() ==
              nutrientName.toLowerCase(),
        );

        logger.i("Found matching nutrient: ${matchingNutrient['Nutrient']}");

        // Convert string values to numbers
        double currentDV =
            double.parse(matchingNutrient['Current Daily Value'].toString());
        double fivePercentDV =
            double.parse(matchingNutrient['5%DV'].toString());
        double twentyPercentDV =
            double.parse(matchingNutrient['20%DV'].toString());

        logger.i(
            "Current DV: $currentDV, 5%DV: $fivePercentDV, 20%DV: $twentyPercentDV");

        // Calculate daily value percentage
        double dailyValuePercent = (value / currentDV) * 100;
        logger.i("Calculated DV%: $dailyValuePercent");

        // Determine DV status
        if (value < fivePercentDV) {
          dvStatus = 'Low';
        } else if (value > twentyPercentDV) {
          dvStatus = 'High';
        } else {
          dvStatus = 'Moderate';
        }

        goal = matchingNutrient['Goal'].toString();
        logger.i("DV Status: $dvStatus, Goal: $goal");

        // Calculate health impact based on goal and dv status
        if ((dvStatus == "High" && goal == "At least") ||
            (dvStatus == "Low" && goal == "Less than")) {
          healthImpact = "Good";
        } else if (dvStatus == "Moderate" ||
            (dvStatus == "Low" && goal == "At least")) {
          healthImpact = "Bad";
        } else {
          healthImpact = "Bad"; // High + Less than
        }

        var nutrientInfoItem = {
          'name': nutrientName,
          'quantity':
              '${value.toStringAsFixed(1)}${matchingNutrient['Unit'] ?? ''}',
          'dv_status': dvStatus,
          'insight': nutrientInsights[nutrientName],
          'goal': goal,
          'daily_value': dailyValuePercent.toStringAsFixed(1),
          'health_impact': healthImpact,
        };

        _nutrientInfo.add(nutrientInfoItem);
        logger.i("Added nutrient info: $nutrientInfoItem");
      } catch (e) {
        // Handle case where nutrient is not found in nutrientData
        logger.w("Nutrient '$nutrientName' not found in nutrient data: $e");
      }
    });

    logger.i("Final _nutrientInfo length: ${_nutrientInfo.length}");
    logger.i("Final _nutrientInfo: $_nutrientInfo");
    logger.i("=== End calculateNutrientInfo ===");
  }
}
