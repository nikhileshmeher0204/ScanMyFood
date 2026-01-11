import 'dart:io';
import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
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
  UserIntakeOutput? userIntakeOutput;
  Map<String, FoodNutrient>? _totalNutrientsMap;
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<Map<String, double>> dailyIntakeNotifier =
      ValueNotifier<Map<String, double>>({});
  final Map<String, Color> _colorCache = {};
  String _descriptionText = "";

  // Getters
  UserIntakeOutput? get userIntake => userIntakeOutput;
  Map<String, FoodNutrient>? get totalNutrients => _totalNutrientsMap;
  DateTime get selectedDate => _selectedDate;
  String get descriptionText => _descriptionText;

  // Constructor with dependency injection
  DailyIntakeViewModel({
    required this.intakeRepository,
    required this.aiRepository,
    required this.uiProvider,
    required this.authService,
  });

  setDescriptionText(String text) {
    _descriptionText = text;
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

  Future<void> saveScannedFood(String userId, File? foodImage, String source,
      FoodAnalysisResponse? foodAnalysis) async {
    SaveIntakeOutput output =
        await intakeRepository.saveScannedFood(userId, foodImage, foodAnalysis);
    if (source == AppConstants.scanDescription) {
      await aiRepository.generateIntakeImage(
          _descriptionText, output.dailyIntakeId);
    }
    await getDailyIntake(userId, _selectedDate);
  }

  Future<void> getDailyIntake(String userId, DateTime date) async {
    userIntakeOutput = await intakeRepository.getDailyIntake(
      userId,
      date,
    );
    _mapTotalNutrients();
    notifyListeners();
  }

  Future<void> saveScannedLabel(String userId, File? foodImage, String source,
      ProductAnalysisResponse? productAnalysis) async {
    await intakeRepository.saveScannedLabel(userId, foodImage, productAnalysis);
    await getDailyIntake(userId, _selectedDate);
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
}
