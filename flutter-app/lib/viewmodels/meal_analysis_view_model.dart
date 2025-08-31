import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class MealAnalysisViewModel extends BaseViewModel {
  // Dependencies
  SpringBackendRepository aiRepository;
  UiViewModel uiProvider;

  // Constructor with dependency injection
  MealAnalysisViewModel({
    required this.aiRepository,
    required this.uiProvider,
  });

  // Properties
  File? _foodImage;
  List<FoodItem> _analyzedScannedFoodItems = [];
  Map<String, dynamic> _totalScannedPlateNutrients = {};
  String _scannedMealName = "Unknown Meal";

  // Getters
  File? get foodImage => _foodImage;
  List<FoodItem> get analyzedScannedFoodItems => _analyzedScannedFoodItems;
  String get scannedMealName => _scannedMealName;
  Map<String, dynamic> get totalScannedPlateNutrients =>
      _totalScannedPlateNutrients;
  List<Map<String, dynamic>> _nutrientInfo = [];
  List<Map<String, dynamic>> get nutrientInfo => _nutrientInfo;

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

      _analyzedScannedFoodItems.clear();
      _totalScannedPlateNutrients.clear();

      _scannedMealName = response.mealName;
      _analyzedScannedFoodItems = response.analyzedFoodItems;
      _totalScannedPlateNutrients = response.getSimpleTotalNutrients();
      calculateNutrientInfo(_totalScannedPlateNutrients);
      logger.d("Total Plate Nutrients:");
      logger.d("Calories: ${_totalScannedPlateNutrients['calories']}");
      logger.d("Protein: ${_totalScannedPlateNutrients['protein']}");
      logger
          .d("Carbohydrates: ${_totalScannedPlateNutrients['carbohydrates']}");
      logger.d("Fat: ${_totalScannedPlateNutrients['fat']}");
      logger.d("Fiber: ${_totalScannedPlateNutrients['fiber']}");
      logger.d("Sugar: ${_totalScannedPlateNutrients['sugar']}");
      logger.d("Sodium: ${_totalScannedPlateNutrients['sodium']}");

      notifyListeners();
      return "Analysis complete";
    } catch (e) {
      logger.d("Error analyzing food image: $e");
      setError("Error analyzing food image: $e");
      return "Error analyzing image";
    } finally {
      uiProvider.setLoading(false);
    }
  }

  // Update total nutrients when food items are modified
  void updateTotalNutrients() {
    _totalScannedPlateNutrients = {
      'calories': 0.0,
      'protein': 0.0,
      'carbohydrates': 0.0,
      'fat': 0.0,
      'fiber': 0.0,
      'sugar': 0.0,
      'sodium': 0.0,
    };

    for (var item in _analyzedScannedFoodItems) {
      var itemNutrients = item.calculateTotalNutrients();
      _totalScannedPlateNutrients['calories'] =
          (_totalScannedPlateNutrients['calories'] ?? 0.0) +
              (itemNutrients['calories'] ?? 0.0);
      _totalScannedPlateNutrients['protein'] =
          (_totalScannedPlateNutrients['protein'] ?? 0.0) +
              (itemNutrients['protein'] ?? 0.0);
      _totalScannedPlateNutrients['carbohydrates'] =
          (_totalScannedPlateNutrients['carbohydrates'] ?? 0.0) +
              (itemNutrients['carbohydrates'] ?? 0.0);
      _totalScannedPlateNutrients['fat'] =
          (_totalScannedPlateNutrients['fat'] ?? 0.0) +
              (itemNutrients['fat'] ?? 0.0);
      _totalScannedPlateNutrients['fiber'] =
          (_totalScannedPlateNutrients['fiber'] ?? 0.0) +
              (itemNutrients['fiber'] ?? 0.0);
      _totalScannedPlateNutrients['sugar'] =
          (_totalScannedPlateNutrients['sugar'] ?? 0.0) +
              (itemNutrients['sugar'] ?? 0.0);
      _totalScannedPlateNutrients['sodium'] =
          (_totalScannedPlateNutrients['sodium'] ?? 0.0) +
              (itemNutrients['sodium'] ?? 0.0);
    }

    notifyListeners();
  }
}
