import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class ProductAnalysisViewModel extends BaseViewModel {
  // Properties for product scanning and analysis
  File? _frontImage;
  File? _nutritionLabelImage;
  String _productName = "";
  Quantity _totalQuantity = Quantity(value: 0, unit: 'g');
  Quantity _servingSize = Quantity(value: 0, unit: 'g');
  NutritionAnalysis? _nutritionAnalysis;
  List<Nutrient> allNutrients = [];
  Map<String, Quantity> _nutrients = {};
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
  File? get frontImage => _frontImage;
  File? get nutritionLabelImage => _nutritionLabelImage;
  String get productName => _productName;
  Quantity get totalQuantity => _totalQuantity;
  Quantity get servingSize => _servingSize;
  NutritionAnalysis? get nutritionAnalysis => _nutritionAnalysis;
  bool canAnalyze() => _frontImage != null && _nutritionLabelImage != null;
  Map<String, Quantity> get nutrients => _nutrients;
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
      // Use the repository to get structured response
      final ProductAnalysisResponse response = await aiRepository
          .analyzeProductImages(_frontImage!, _nutritionLabelImage!);

      _productName = response.product.name;
      _totalQuantity = response.nutritionAnalysis.totalQuantity;
      _servingSize = response.nutritionAnalysis.servingSize;

      _nutritionAnalysis = null;
      // Process nutrients
      allNutrients = [];
      optimalNutrients = [];
      moderateNutrients = [];
      watchOutNutrients = [];
      _primaryConcerns = []; // Clear primary concerns

      for (Nutrient nutrient in response.nutritionAnalysis.nutrients) {
        allNutrients.add(nutrient);
        _nutrients[nutrient.name] = nutrient.quantity;
        if (nutrient.healthImpact == "Good") {
          optimalNutrients.add(nutrient);
        } else if (nutrient.healthImpact == "Moderate") {
          moderateNutrients.add(nutrient);
        } else {
          watchOutNutrients.add(nutrient);
        }
      }

      _primaryConcerns.addAll(response.nutritionAnalysis.primaryConcerns);

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
