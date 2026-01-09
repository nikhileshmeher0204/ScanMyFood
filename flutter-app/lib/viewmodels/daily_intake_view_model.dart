import 'dart:io';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_consumption.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/user_intake_output.dart';
import 'package:read_the_label/repositories/intake_repository_interface.dart';
import 'package:read_the_label/repositories/storage_repository_interface.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'base_view_model.dart';

class DailyIntakeViewModel extends BaseViewModel {
  // Dependencies
  StorageRepositoryInterface storageRepository;
  IntakeRepositoryInterface intakeRepository;
  UiViewModel uiProvider;

  // State
  UserIntakeOutput? userIntakeOutput;
  Map<String, FoodNutrient>? _totalNutrientsMap;
  Map<String, double> _dailyIntake = {};
  List<FoodConsumption> _foodHistory = [];
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<Map<String, double>> dailyIntakeNotifier =
      ValueNotifier<Map<String, double>>({});
  final Map<String, Color> _colorCache = {};

  // Getters
  UserIntakeOutput? get userIntake => userIntakeOutput;
  Map<String, FoodNutrient>? get totalNutrients => _totalNutrientsMap;
  Map<String, double> get dailyIntake => _dailyIntake;
  List<FoodConsumption> get foodHistory => _foodHistory;
  DateTime get selectedDate => _selectedDate;

  // Constructor with dependency injection
  DailyIntakeViewModel({
    required this.storageRepository,
    required this.intakeRepository,
    required this.uiProvider,
  });

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

  Future<void> saveScannedFood(String userId, File? foodImage,
      FoodAnalysisResponse? foodAnalysis) async {
    uiProvider.setLoading(true);
    await intakeRepository.saveScannedFood(userId, foodImage, foodAnalysis);
  }

  Future<UserIntakeOutput?> getDailyIntake(String userId, DateTime date) async {
    uiProvider.setLoading(true);
    userIntakeOutput = await intakeRepository.getDailyIntake(
      userId,
      date,
    );
    _mapTotalNutrients();
    uiProvider.setLoading(false);
    return userIntakeOutput;
  }

  Future<void> saveScannedLabel(String userId, File? foodImage,
      ProductAnalysisResponse? productAnalysis) async {
    uiProvider.setLoading(true);
    await intakeRepository.saveScannedLabel(userId, foodImage, productAnalysis);
  }

  void _mapTotalNutrients() {
    _totalNutrientsMap = {
      for (var nutrient in userIntakeOutput?.totalNutrients ?? [])
        nutrient.name: nutrient
    };
  }
}
