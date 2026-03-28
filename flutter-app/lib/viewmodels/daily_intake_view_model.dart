import 'dart:io';
import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/save_intake_output.dart';
import 'package:read_the_label/models/user_intake_output.dart';
import 'package:read_the_label/repositories/ai_repository_interface.dart';
import 'package:read_the_label/repositories/intake_repository_interface.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'base_view_model.dart';

class DailyIntakeViewModel extends BaseViewModel {
  // Dependencies
  IntakeRepositoryInterface intakeRepository;
  AiRepositoryInterface aiRepository;
  UiViewModel uiProvider;
  AuthService authService;

  // State
  bool _isLoading = false;
  UserIntakeOutput? userIntakeOutput;
  SaveIntakeOutput? saveIntakeOutput;
  FoodAnalysisResponse? _intakeDetails;
  List<FoodItem> _analyzedScannedFoodItems = [];
  List<FoodNutrient> _totalScannedPlateNutrients = [];
  List<Map<String, dynamic>> _nutrientInfo = [];
  String _scannedMealName = "Unknown Meal";
  Map<String, FoodNutrient>? _totalNutrientsMap;
  DateTime _selectedDate = DateTime.now();
  final Map<String, Color> _colorCache = {};
  String _descriptionText = "";
  bool _isImageGenerating = false;

  // Getters
  bool get loading => _isLoading;
  UserIntakeOutput? get userIntake => userIntakeOutput;
  SaveIntakeOutput? get saveIntake => saveIntakeOutput;
  FoodAnalysisResponse? get intakeDetails => _intakeDetails;
  List<FoodItem> get analyzedScannedFoodItems => _analyzedScannedFoodItems;
  List<FoodNutrient> get totalScannedPlateNutrients =>
      _totalScannedPlateNutrients;
  List<Map<String, dynamic>> get nutrientInfo => _nutrientInfo;
  String get scannedMealName => _scannedMealName;
  Map<String, FoodNutrient>? get totalNutrients => _totalNutrientsMap;
  DateTime get selectedDate => _selectedDate;
  String get descriptionText => _descriptionText;
  bool get isImageGenerating => _isImageGenerating;

  // Constructor with dependency injection
  DailyIntakeViewModel({
    required this.intakeRepository,
    required this.aiRepository,
    required this.uiProvider,
    required this.authService,
  });
  setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  setDescriptionText(String text) {
    _descriptionText = text;
  }

  setIsImageGenerating(bool value) {
    _isImageGenerating = value;
    notifyListeners();
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    final user = authService.currentUser;
    if (user == null) return;

    _selectedDate = newDate;
    await getDailyIntake(user.uid, newDate);
  }

  Future<Color> extractDominantColor(String? imagePath) async {
    // Check cache first
    if (_colorCache.containsKey(imagePath)) {
      return _colorCache[imagePath]!;
    }

    try {
      final imageProvider = FileImage(File(imagePath!));
      final colorScheme = await ColorScheme.fromImageProvider(
        provider: imageProvider,
        brightness:
            Brightness.dark, // Use dark for better contrast with white text
      );

      // Get the primary color and apply some opacity for the tint effect
      final extractedColor = colorScheme.primary;

      // Cache the result
      _colorCache[imagePath] = extractedColor;

      return extractedColor;
    } catch (e) {
      debugPrint("Error extracting color from image: $e");
      // Return fallback color
      final fallbackColor = Colors.black.withOpacity(0.3);
      _colorCache[imagePath!] = fallbackColor;
      return fallbackColor;
    }
  }

  Future<SaveIntakeOutput> saveScannedFood(String userId, File? foodImage,
      String source, FoodAnalysisResponse? foodAnalysis) async {
    try {
      debugPrint(
          "Starting saveScannedFood for userId: $userId, source: $source");
      saveIntakeOutput = await intakeRepository.saveScannedFood(
          userId, foodImage, source, foodAnalysis);
      debugPrint(
          "SaveIntakeOutput received: ${saveIntakeOutput?.dailyIntakeId}");
      return saveIntakeOutput!;
    } catch (e, stackTrace) {
      debugPrint("Error in saveScannedFood: $e");
      debugPrint("StackTrace: $stackTrace");
      setError("Failed to save intake: $e");
      rethrow;
    }
  }

  Future<void> getDailyIntake(String userId, DateTime date) async {
    userIntakeOutput = await intakeRepository.getDailyIntake(
      userId,
      date,
    );
    _mapTotalNutrients();
    notifyListeners();
  }

  Future<void> getIntakeDetailsByDailyIntakeId(
      String userId, int dailyIntakeId) async {
    setLoading(true);
    try {
      _intakeDetails = await intakeRepository.getIntakeDetails(
        userId,
        dailyIntakeId,
      );

      _analyzedScannedFoodItems.clear();
      _totalScannedPlateNutrients.clear();

      _scannedMealName = _intakeDetails!.mealName;
      _analyzedScannedFoodItems = _intakeDetails!.analyzedFoodItems;
      _totalScannedPlateNutrients = _intakeDetails!.totalPlateNutrients;
      calculateNutrientInfo(_totalScannedPlateNutrients);
      notifyListeners();
    } catch (e) {
      setError("Error analyzing food image: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveScannedLabel(String userId, File? foodImage, String source,
      ProductAnalysisResponse? productAnalysis) async {
    await intakeRepository.saveScannedLabel(
        userId, foodImage, source, productAnalysis);
  }

  void _mapTotalNutrients() {
    _totalNutrientsMap = {
      for (var nutrient in userIntakeOutput?.totalNutrients ?? [])
        nutrient.name: nutrient
    };
  }

  bool isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
    for (FoodNutrient nutrient in totalScannedPlateNutrients) {
      double value = nutrient.quantity.value;
      String unit = nutrient.quantity.unit;
      String dvStatus = '';
      String goal = '';
      String healthImpact = '';

      logger.i(
          "Processing nutrient: ${nutrient.name} with value: ${nutrient.quantity.value} ${nutrient.quantity.unit}");

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
          'quantity': value,
          'unit': unit,
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
    }

    logger.i("Final _nutrientInfo length: ${_nutrientInfo.length}");
    logger.i("Final _nutrientInfo: $_nutrientInfo");
    logger.i("=== End calculateNutrientInfo ===");
  }
}
