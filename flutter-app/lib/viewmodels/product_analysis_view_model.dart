import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/repositories/spring_backend_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';

class ProductAnalysisViewModel extends BaseViewModel {
  // Properties for product scanning and analysis
  bool _isLoading = false;
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
  List<Nutrient> limitNutrients = [];
  List<Nutrient> insufficientNutrients = [];
  List<PrimaryConcern> _primaryConcerns = [];
  Map<String, dynamic> totalPlateNutrients = {};

  // Dependencies
  SpringBackendRepository aiRepository;

  ProductAnalysisViewModel({
    required this.aiRepository,
  });

  // Getters
  bool get loading => _isLoading;
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
  List<Nutrient> getLimitNutrients() => limitNutrients;
  List<Nutrient> getInsufficientNutrients() => insufficientNutrients;
  List<PrimaryConcern> get primaryConcerns => _primaryConcerns;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

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

  Future<void> handleImageCapture(BuildContext context, ImageSource source) async {
    // First, capture front image
    await captureImage(
      source: source,
      isFrontImage: true,
    );

    if (_frontImage != null) {
      // Show dialog for nutrition label
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Now capture nutrition label',
              style: AppTextStyles.heading2,
            ),
            content: Text(
              'Please capture or select the nutrition facts label of the product',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await captureImage(
                    source: source,
                    isFrontImage: false,
                  );
                  if (canAnalyze()) {
                    await analyzeImages();
                  }
                },
                child: Text('Continue', style: AppTextStyles.buttonTextWhite),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> analyzeImages() async {
    setLoading(true);

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
      limitNutrients = [];
      insufficientNutrients = [];
      _primaryConcerns = [];

      for (Nutrient nutrient in productAnalysis!.nutritionAnalysis.nutrients) {
        if (nutrient.quantity.value != 0.0) {
          allNutrients.add(nutrient);
          _nutrients.add(
              FoodNutrient(name: nutrient.name, quantity: nutrient.quantity));

          final category = NutrientUtils.getNutrientCategory(
              nutrient.dvStatus, nutrient.goal);

          if (category == "Good") {
            optimalNutrients.add(nutrient);
          } else if (category == "Moderate") {
            moderateNutrients.add(nutrient);
          } else if (category == "Limit") {
            limitNutrients.add(nutrient);
          } else if (category == "Insufficient") {
            insufficientNutrients.add(nutrient);
          }
        }
      }

      _primaryConcerns
          .addAll(productAnalysis!.nutritionAnalysis.primaryConcerns);

      print("📝 Product: $_productName");
      print("📊 Good nutrients: ${optimalNutrients.length}");
      print("⚠️ Moderate nutrients: ${moderateNutrients.length}");
      print("⚠️ Limit nutrients: ${limitNutrients.length}");
      print("⚠️ Insufficient nutrients: ${insufficientNutrients.length}");

      notifyListeners();
    } catch (e) {
      print("❌ Error analyzing images: $e");
    } finally {
      setLoading(false);
    }
  }
}
