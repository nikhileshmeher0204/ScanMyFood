import 'package:flutter/material.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/image_generation_response.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';

class DescriptionAnalysisViewModel extends BaseViewModel {
  // Dependencies
  SpringBackendRepository aiRepository;

  DescriptionAnalysisViewModel({
    required this.aiRepository,
  });

  bool loading = false;
  String? _descriptionText;
  FoodAnalysisResponse? _foodAnalysisResponse;
  ImageGenerationResponse? _imageGenerationResponse;
  List<FoodItem> _analyzedFoodItems = [];
  List<FoodNutrient> _totalPlateNutrients = [];
  String _mealName = "Unknown Meal";

  bool get isLoading => loading;
  String? get descriptionText => _descriptionText;
  FoodAnalysisResponse? get foodAnalysis => _foodAnalysisResponse;
  ImageGenerationResponse? get generatedImage => _imageGenerationResponse;
  List<FoodItem> get analyzedFoodItems => _analyzedFoodItems;
  List<FoodNutrient> get totalPlateNutrients => _totalPlateNutrients;
  String get mealName => _mealName;
  List<Map<String, dynamic>> _nutrientInfo = [];
  List<Map<String, dynamic>> get nutrientInfo => _nutrientInfo;

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  // Text-based meal analysis
  Future<void> logMealViaText({
    required String foodItemsText,
  }) async {
    setLoading(true);

    try {
      debugPrint("Processing food items via text: \n$foodItemsText");

      // Use repository for text-based analysis
      _foodAnalysisResponse =
          await aiRepository.analyzeFoodDescription(foodItemsText);
      // Clear previous analysis
      _analyzedFoodItems.clear();
      _totalPlateNutrients.clear();

      _descriptionText = foodItemsText;
      _mealName = _foodAnalysisResponse!.mealName;
      _analyzedFoodItems = _foodAnalysisResponse!.analyzedFoodItems;
      _totalPlateNutrients = _foodAnalysisResponse!.totalPlateNutrients;
      calculateNutrientInfo(_totalPlateNutrients);
      notifyListeners();
    } catch (e) {
      debugPrint("Error analyzing food description: $e");
      setError("Error analyzing food description: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> generateIntakeImage({
    required String foodItemsText,
    required int dailyIntakeId,
  }) async {
    setLoading(true);

    try {
      debugPrint("Generating image for food description: \n$foodItemsText");

      _imageGenerationResponse =
          await aiRepository.generateIntakeImage(foodItemsText, dailyIntakeId);

      notifyListeners();
    } catch (e) {
      debugPrint("Error generating image: $e");
      setError("Error generating image: $e");
    } finally {
      setLoading(false);
    }
  }

  void calculateNutrientInfo(List<FoodNutrient> totalScannedPlateNutrients) {
    logger.i("=== Starting calculateNutrientInfo ===");
    logger.i("Input nutrients: $totalScannedPlateNutrients");

    // Clear previous data
    _nutrientInfo.clear();

    // Map from nutrient keys to display names
    Map<String, String> keyMapping = {
      'calories': 'Energy',
      'protein': 'Protein',
      'total_carbohydrate': 'Carbohydrate',
      'total_fat': 'Fat',
      'dietary_fiber': 'Fiber',
      'sodium': 'Sodium',
      'total_sugars': 'Total Sugars',
      'saturated_fat': 'Saturated Fat',
    };

    // Perform calculations on the totalPlateNutrients
    totalScannedPlateNutrients.forEach((nutrient) {
      logger.i(
          "Processing nutrient: ${nutrient.name} with value: ${nutrient.quantity}");

      double value = nutrient.quantity.value;
      String dvStatus = '';
      String goal = '';
      String healthImpact = '';

      // Get the proper nutrient name for insights lookup
      String nutrientName =
          keyMapping[nutrient.name.toLowerCase()] ?? nutrient.name;
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
        double dailyValuePercent = (nutrient.quantity.value / currentDV) * 100;
        dailyValuePercent = double.parse(dailyValuePercent.toStringAsFixed(2));
        logger.i("Calculated DV%: $dailyValuePercent");

        // Determine DV status
        if (nutrient.quantity.value < fivePercentDV) {
          dvStatus = 'Low';
        } else if (nutrient.quantity.value > twentyPercentDV) {
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
          'quantity': value.toDouble(),
          'unit': matchingNutrient['Unit'] ?? '',
          'dv_status': dvStatus,
          'insight': nutrientInsights[nutrientName],
          'goal': goal,
          'daily_value': dailyValuePercent.toDouble(),
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
