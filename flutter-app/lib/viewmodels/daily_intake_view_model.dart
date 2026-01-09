import 'dart:io';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
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
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<Map<String, double>> dailyIntakeNotifier =
      ValueNotifier<Map<String, double>>({});
  final Map<String, Color> _colorCache = {};

  // Getters
  UserIntakeOutput? get userIntake => userIntakeOutput;
  Map<String, FoodNutrient>? get totalNutrients => _totalNutrientsMap;
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
    await intakeRepository.saveScannedFood(userId, foodImage, foodAnalysis);
  }

  Future<void> getDailyIntake(String userId, DateTime date) async {
    userIntakeOutput = await intakeRepository.getDailyIntake(
      userId,
      date,
    );
    _mapTotalNutrients();
    notifyListeners();
  }

  Future<void> saveScannedLabel(String userId, File? foodImage,
      ProductAnalysisResponse? productAnalysis) async {
    await intakeRepository.saveScannedLabel(userId, foodImage, productAnalysis);
  }

  void _mapTotalNutrients() {
    _totalNutrientsMap = {
      for (var nutrient in userIntakeOutput?.totalNutrients ?? [])
        nutrient.name: nutrient
    };
  }
}
