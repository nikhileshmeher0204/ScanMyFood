import 'dart:io';
import 'package:image_picker/image_picker.dart';
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

      _analyzedScannedFoodItems.clear();
      _totalScannedPlateNutrients.clear();

      _scannedMealName = response.mealName;
      _analyzedScannedFoodItems = response.analyzedFoodItems;
      _totalScannedPlateNutrients = response.getSimpleTotalNutrients();

      logger.d("Total Plate Nutrients:");
      logger.d("Calories: ${_totalScannedPlateNutrients['calories']}");
      logger.d("Protein: ${_totalScannedPlateNutrients['protein']}");
      logger
          .d("Carbohydrates: ${_totalScannedPlateNutrients['carbohydrates']}");
      logger.d("Fat: ${_totalScannedPlateNutrients['fat']}");
      logger.d("Fiber: ${_totalScannedPlateNutrients['fiber']}");

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
    }

    notifyListeners();
  }
}
