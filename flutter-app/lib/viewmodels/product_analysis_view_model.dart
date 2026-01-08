import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class ProductAnalysisViewModel extends BaseViewModel {
  // Properties for product scanning and analysis
  ProductAnalysisResponse? productAnalysis;
  File? _frontImage;
  File? _nutritionLabelImage;
  String _productName = "";
  Quantity _totalQuantity = Quantity(value: 0, unit: 'g');
  Quantity _servingSize = Quantity(value: 0, unit: 'g');
  NutritionAnalysis? _nutritionAnalysis;
  List<Nutrient> allNutrients = [];
  List<FoodNutrient> _nutrients = [];
  List<Nutrient> optimalNutrients = [];
  List<Nutrient> moderateNutrients = [];
  List<Nutrient> watchOutNutrients = [];
  List<PrimaryConcern> _primaryConcerns = [];
  Map<String, dynamic> totalPlateNutrients = {};

  // Dependencies
  SpringBackendRepository aiRepository;
  UiViewModel uiProvider;

  ProductAnalysisViewModel({
    required this.aiRepository,
    required this.uiProvider,
  });

  // Getters
  ProductAnalysisResponse? get getProductAnalysis => productAnalysis;
  File? get frontImage => _frontImage;
  File? get nutritionLabelImage => _nutritionLabelImage;
  String get productName => _productName;
  Quantity get totalQuantity => _totalQuantity;
  Quantity get servingSize => _servingSize;
  NutritionAnalysis? get nutritionAnalysis => _nutritionAnalysis;
  bool canAnalyze() => _frontImage != null && _nutritionLabelImage != null;
  List<FoodNutrient> get nutrients => _nutrients;
  List<Nutrient> getOptimalNutrients() => optimalNutrients;
  List<Nutrient> getModerateNutrients() => moderateNutrients;
  List<Nutrient> getWatchOutNutrients() => watchOutNutrients;
  List<PrimaryConcern> get primaryConcerns => _primaryConcerns;

  // Methods for product analysis
  Future<void> captureImage({
    required ImageSource source,
    required bool isFrontImage,
  }) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      if (isFrontImage) {
        _frontImage = File(image.path);
      } else {
        _nutritionLabelImage = File(image.path);
      }
      notifyListeners();
    }
  }

  Future<void> analyzeImages() async {
    uiProvider.setLoading(true);

    try {
      productAnalysis = await aiRepository.analyzeProductImages(
          _frontImage!, _nutritionLabelImage!);

      _productName = productAnalysis!.product.name;
      _totalQuantity = productAnalysis!.nutritionAnalysis.totalQuantity;
      _servingSize = productAnalysis!.nutritionAnalysis.servingSize;

      _nutritionAnalysis = null;
      // Clear previous data
      allNutrients = [];
      optimalNutrients = [];
      moderateNutrients = [];
      watchOutNutrients = [];
      _primaryConcerns = [];

      for (Nutrient nutrient in productAnalysis!.nutritionAnalysis.nutrients) {
        if (nutrient.quantity.value != 0.0) {
          allNutrients.add(nutrient);
          _nutrients.add(
              FoodNutrient(name: nutrient.name, quantity: nutrient.quantity));
          if (nutrient.healthImpact == AppConstants.goodHealthImpact) {
            optimalNutrients.add(nutrient);
          } else if (nutrient.healthImpact ==
              AppConstants.moderateHealthImpact) {
            moderateNutrients.add(nutrient);
          } else {
            watchOutNutrients.add(nutrient);
          }
        }
      }

      _primaryConcerns
          .addAll(productAnalysis!.nutritionAnalysis.primaryConcerns);

      if (_servingSize.value > 0) {
        print(
            "Setting serving size to: ${_servingSize.value} ${_servingSize.unit}");
        uiProvider.updateServingSize(_servingSize.value);
      }

      print("📝 Product: $_productName");
      print("📊 Good nutrients: ${optimalNutrients.length}");
      print("⚠️ Moderate nutrients: ${moderateNutrients.length}");
      print("⚠️ Bad nutrients: ${watchOutNutrients.length}");

      notifyListeners();
    } catch (e) {
      print("❌ Error analyzing images: $e");
    } finally {
      uiProvider.setLoading(false);
    }
  }
}
