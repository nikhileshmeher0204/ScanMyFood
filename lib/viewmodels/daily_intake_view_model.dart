import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/models/food_consumption.dart';
import 'package:read_the_label/repositories/storage_repository.dart';
import 'package:read_the_label/repositories/storage_repository_interface.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_view_model.dart';

class DailyIntakeViewModel extends BaseViewModel {
  // Dependencies
  StorageRepositoryInterface storageRepository;
  UiViewModel uiProvider;

  // State
  Map<String, double> _dailyIntake = {};
  List<FoodConsumption> _foodHistory = [];
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<Map<String, double>> dailyIntakeNotifier =
      ValueNotifier<Map<String, double>>({});

  // Getters
  Map<String, double> get dailyIntake => _dailyIntake;
  List<FoodConsumption> get foodHistory => _foodHistory;
  DateTime get selectedDate => _selectedDate;

  // Constructor with dependency injection
  DailyIntakeViewModel({
    required this.storageRepository,
    required this.uiProvider,
  }) {
    // Initialize if needed
    _initViewModel();
  }

  void _initViewModel() {
    // Any initial setup
  }

  // Methods for daily intake tracking
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadDailyIntake(date);
    notifyListeners();
  }

  String getStorageKey(DateTime date) {
    // Standardize the storage key format
    return 'dailyIntake_${date.year}-${date.month}-${date.day}';
  }

  Future<void> debugCheckStorage() async {
    uiProvider.setLoading(true);

    try {
      // Get all keys
      final keys = await storageRepository.getAllKeys();
      debugPrint("All SharedPreferences keys: $keys");

      // Print food history
      final foodHistoryData = await storageRepository.getFoodHistory();
      debugPrint("Stored food history: ${foodHistoryData.length} items");

      // Print daily intakes for last 7 days
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final key = getStorageKey(date);
        final data = await storageRepository.getDailyIntake(date);
        debugPrint("Daily intake for ${date.toString().split(' ')[0]}: $data");
      }
    } catch (e) {
      debugPrint("Error checking storage: $e");
      setError("Error checking storage: $e");
    } finally {
      uiProvider.setLoading(false);
    }
  }

  Future<void> loadDailyIntake(DateTime date) async {
    uiProvider.setLoading(true);

    try {
      debugPrint("Loading daily intake for date: ${date.toString()}");

      final data = await storageRepository.getDailyIntake(date);

      if (data != null && data.isNotEmpty) {
        debugPrint("Found stored data for $date");
        _dailyIntake = Map.from(data);
        dailyIntakeNotifier.value = Map.from(data);
      } else {
        debugPrint("No data found for $date, setting empty map");
        _dailyIntake = {};
        dailyIntakeNotifier.value = {};
      }

      _selectedDate = date;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading daily intake: $e");
      setError("Error loading daily intake: $e");

      // Set empty values on error
      _dailyIntake = {};
      dailyIntakeNotifier.value = {};
    } finally {
      uiProvider.setLoading(false);
    }
  }

  Future<void> loadFoodHistory() async {
    uiProvider.setLoading(true);

    try {
      debugPrint("Loading food history from storage...");
      _foodHistory = await storageRepository.getFoodHistory();
      debugPrint("Successfully loaded ${_foodHistory.length} food items");

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading food history: $e");
      setError("Error loading food history: $e");
      _foodHistory = [];
    } finally {
      uiProvider.setLoading(false);
    }
  }

  Future<void> saveDailyIntake(Map<String, double> newIntake) async {
    uiProvider.setLoading(true);

    try {
      debugPrint("Saving daily intake for ${_selectedDate}");
      debugPrint("Current daily intake: $_dailyIntake");
      debugPrint("New intake to add: $newIntake");

      // Merge existing with new data
      Map<String, double> updatedIntake = Map.from(_dailyIntake);

      newIntake.forEach((key, value) {
        updatedIntake[key] = (updatedIntake[key] ?? 0.0) + value;
      });

      // Save to repository
      await storageRepository.saveDailyIntake(_selectedDate, updatedIntake);

      // Update local state
      _dailyIntake = updatedIntake;
      dailyIntakeNotifier.value = updatedIntake;

      debugPrint("Successfully saved daily intake: $_dailyIntake");
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving daily intake: $e");
      setError("Error saving daily intake: $e");
    } finally {
      uiProvider.setLoading(false);
    }
  }

  Future<void> addToDailyIntake({
    required String source,
    required String productName,
    required List<Map<String, dynamic>> nutrients,
    required double servingSize,
    required double consumedAmount,
    required File? imageFile,
  }) async {
    _dailyIntake = {};
    print("Adding to daily intake. Source: $source");
    print("Current daily intake before: $dailyIntake");
    print("✅Start of addToDailyIntake()");
    print("⚡Daily intake at start of addToDailyIntake(): $dailyIntake");

    try {
      // Calculate adjustment for portion size
      final ratio = consumedAmount / servingSize;

      // Convert nutrients to the format needed for daily intake
      Map<String, double> newNutrients = {};
      for (var nutrient in nutrients) {
        final name = nutrient['name'];
        final quantity = double.tryParse(nutrient['quantity']
                .toString()
                .replaceAll(RegExp(r'[^0-9\.]'), '')) ??
            0;
        double adjustedQuantity = quantity * ratio;
        newNutrients[name] = adjustedQuantity;
      }

      // Process and save the image
      String imagePath = '';
      if (imageFile != null) {
        imagePath = await _saveImageToStorage(imageFile);
      }

      // Add to food history
      await addToFoodHistory(
        foodName: productName,
        nutrients: newNutrients,
        source: source,
        imagePath: imagePath,
      );

      // Update and save the daily intake
      await saveDailyIntake(newNutrients);
    } catch (e) {
      debugPrint("Error adding to daily intake: $e");
      setError("Error adding to daily intake: $e");
    }
  }

// Add this new method
  Future<void> addMealToDailyIntake({
    required String mealName,
    required Map<String, dynamic> totalPlateNutrients,
    required File? foodImage,
  }) async {
    try {
      // Convert meal nutrients to the format needed for daily intake
      Map<String, double> newNutrients = {
        'Energy': (totalPlateNutrients['calories'] ?? 0).toDouble(),
        'Protein': (totalPlateNutrients['protein'] ?? 0).toDouble(),
        'Carbohydrate': (totalPlateNutrients['carbohydrates'] ?? 0).toDouble(),
        'Fat': (totalPlateNutrients['fat'] ?? 0).toDouble(),
        'Fiber': (totalPlateNutrients['fiber'] ?? 0).toDouble(),
      };

      // Process and save the image
      String imagePath = '';
      if (foodImage != null) {
        imagePath = await _saveImageToStorage(foodImage);
      }

      // Add to food history
      await addToFoodHistory(
        foodName: mealName,
        nutrients: newNutrients,
        source: 'food',
        imagePath: imagePath,
      );

      // Update and save the daily intake
      await saveDailyIntake(newNutrients);
    } catch (e) {
      debugPrint("Error adding meal to daily intake: $e");
      setError("Error adding meal to daily intake: $e");
    }
  }

  Future<void> addToFoodHistory({
    required String foodName,
    required Map<String, double> nutrients,
    required String source,
    required String imagePath,
  }) async {
    try {
      debugPrint("Adding to food history: $foodName");

      await loadFoodHistory();

      // Create consumption object
      final consumption = FoodConsumption(
        foodName: foodName,
        dateTime: _selectedDate,
        nutrients: nutrients,
        source: source,
        imagePath: imagePath,
      );

      // Add to list
      _foodHistory.add(consumption);

      // Save to repository
      await storageRepository.saveFoodHistory(_foodHistory);

      debugPrint("Successfully added to food history");
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding to food history: $e");
      setError("Error adding to food history: $e");
    }
  }

  Future<String> _saveImageToStorage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await imageFile.copy('${directory.path}/$imageName');
      return savedImage.path;
    } catch (e) {
      debugPrint("Error saving image: $e");
      return '';
    }
  }

  String? getInsights(Map<String, double> dailyIntake) {
    for (var nutrient in nutrientData) {
      String nutrientName = nutrient['Nutrient'];
      if (dailyIntake.containsKey(nutrientName)) {
        try {
          double dvValue = double.parse(nutrient['Current Daily Value']
              .replaceAll(RegExp(r'[^0-9\.]'), ''));
          double percent = dailyIntake[nutrientName]! / dvValue;
          if (percent > 1.0) {
            return "You have exceeded the recommended daily intake of $nutrientName";
          }
        } catch (e) {
          debugPrint("Error parsing to double: $e");
        }
      }
    }
    return null;
  }

  // Clear the daily intake for testing
  Future<void> clearDailyIntake() async {
    try {
      await storageRepository.saveDailyIntake(_selectedDate, {});
      _dailyIntake = {};
      dailyIntakeNotifier.value = {};
      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing daily intake: $e");
      setError("Error clearing daily intake: $e");
    }
  }

  // Get food history for a specific date
  List<FoodConsumption> getFoodHistoryForDate(DateTime date) {
    return _foodHistory
        .where((item) =>
            item.dateTime.year == date.year &&
            item.dateTime.month == date.month &&
            item.dateTime.day == date.day)
        .toList();
  }
}
