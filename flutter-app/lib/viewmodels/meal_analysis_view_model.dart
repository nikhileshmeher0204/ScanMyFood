import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';

class MealAnalysisViewModel extends BaseViewModel {
  // Dependencies
  SpringBackendRepository aiRepository;

  // Constructor with dependency injection
  MealAnalysisViewModel({required this.aiRepository});

  // Properties
  bool _isLoading = false;
  FoodAnalysisResponse? foodAnalysisResponse;
  File? _foodImage;
  List<FoodItem> _analyzedScannedFoodItems = [];
  List<FoodNutrient> _totalScannedPlateNutrients = [];
  String _scannedMealName = "Unknown Meal";
  List<Map<String, dynamic>> _nutrientInfo = [];

  // Getters
  bool get loading => _isLoading;
  FoodAnalysisResponse? get foodAnalysis => foodAnalysisResponse;
  File? get foodImage => _foodImage;
  List<FoodItem> get analyzedScannedFoodItems => _analyzedScannedFoodItems;
  String get scannedMealName => _scannedMealName;
  List<FoodNutrient> get totalScannedPlateNutrients =>
      _totalScannedPlateNutrients;
  List<Map<String, dynamic>> get nutrientInfo => _nutrientInfo;

  setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

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

  Future<void> handleFoodImageCapture(ImageSource source) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      setFoodImage(File(image.path));
      await analyzeFoodImage(imageFile: _foodImage!);
    }
  }

  void calculateNutrientInfo(List<FoodNutrient> totalScannedPlateNutrients) {
    logger.i("=== Starting calculateNutrientInfo ===");
    logger.i("Input nutrients: $totalScannedPlateNutrients");

    // Clear previous data
    _nutrientInfo.clear();

    // Perform calculations on the totalPlateNutrients
    for (FoodNutrient nutrient in totalScannedPlateNutrients) {
      logger.i(
          "Processing nutrient: ${nutrient.name} with value: ${nutrient.quantity.value} ${nutrient.quantity.unit}");

      double value = nutrient.quantity.value;
      String dvStatus = '';
      String goal = '';
      String healthImpact = '';

      // Get the proper nutrient name for insights lookup
      String nutrientName = NutrientUtils.toTitleCase(nutrient.name);
      logger.i("Nutrient name for lookup: $nutrientName");

      // Find the matching nutrient data
      var matchingNutrient = nutrientDataMap[nutrientName];

      if (matchingNutrient != null) {
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
        dailyValuePercent = double.parse(dailyValuePercent.toStringAsFixed(2));
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
      } else {
        // Handle case where nutrient is not found in nutrientData
        logger.w("Nutrient '$nutrientName' not found in nutrient data");
      }
    }

    logger.i("Final _nutrientInfo length: ${_nutrientInfo.length}");
    logger.i("Final _nutrientInfo: $_nutrientInfo");
    logger.i("=== End calculateNutrientInfo ===");
  }

  // Analyze food image method
  Future<void> analyzeFoodImage({
    required File imageFile,
  }) async {
    setLoading(true);

    try {
      // Store the food image
      _foodImage = imageFile;

      // Use repository for AI analysis
      foodAnalysisResponse = await aiRepository.analyzeFoodImage(imageFile);

      _analyzedScannedFoodItems.clear();
      _totalScannedPlateNutrients.clear();

      _scannedMealName = foodAnalysisResponse!.mealName;
      _analyzedScannedFoodItems = foodAnalysisResponse!.analyzedFoodItems;
      _totalScannedPlateNutrients = foodAnalysisResponse!.totalPlateNutrients;

      calculateNutrientInfo(_totalScannedPlateNutrients);

      notifyListeners();
    } catch (e) {
      logger.d("Error analyzing food image: $e");
      setError("Error analyzing food image: $e");
    } finally {
      setLoading(false);
    }
  }
}
