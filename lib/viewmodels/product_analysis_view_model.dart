import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/repositories/ai_repository.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class ProductAnalysisViewModel extends BaseViewModel {
  // Properties for product scanning and analysis
  File? _frontImage;
  File? _nutritionLabelImage;
  String _productName = "";
  Map<String, dynamic> _nutritionAnalysis = {};
  List<Map<String, dynamic>> parsedNutrients = [];
  List<Map<String, dynamic>> goodNutrients = [];
  List<Map<String, dynamic>> badNutrients = [];

// Dependencies
  AiRepository aiRepository;
  UiViewModel uiProvider;

  ProductAnalysisViewModel({
    required this.aiRepository,
    required this.uiProvider,
  });

  // Getters
  File? get frontImage => _frontImage;
  File? get nutritionLabelImage => _nutritionLabelImage;
  String get productName => _productName;
  Map<String, dynamic> get nutritionAnalysis => _nutritionAnalysis;
  bool canAnalyze() => _frontImage != null && _nutritionLabelImage != null;
  List<Map<String, dynamic>> getGoodNutrients() => goodNutrients;
  List<Map<String, dynamic>> getBadNutrients() => badNutrients;

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

  String? getApiKey() {
    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key == null || key.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }
      return key;
    } catch (e) {
      print('Error loading API key: $e');
      return null;
    }
  }

  double getCalories() {
    var energyNutrient = parsedNutrients.firstWhere(
      (nutrient) => nutrient['name'] == 'Energy',
      orElse: () => {'quantity': '0.0'},
    );
    // Parse the quantity string to remove any non-numeric characters except decimal points
    var quantity = energyNutrient['quantity']
        .toString()
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(quantity) ?? 0.0;
  }

  Future<String> analyzeImages() async {
    uiProvider.setLoading(true);

    try {
      // Use the repository instead of direct API calls
      final response = await aiRepository.analyzeProductImages(
          _frontImage!, _nutritionLabelImage!);

      // Process response
      _productName = response['product']['name'] ?? "Unknown Product";
      _nutritionAnalysis = response['nutrition_analysis'];

      print("📝 Product: $_productName");
      print("📊 Good nutrients: ${goodNutrients.length}");
      print("⚠️ Bad nutrients: ${badNutrients.length}");

      // Safe parsing for serving size
      if (_nutritionAnalysis.containsKey("serving_size") &&
          _nutritionAnalysis["serving_size"] != null) {
        final servingSizeStr = _nutritionAnalysis["serving_size"].toString();
        final servingSizeNum = double.tryParse(
                servingSizeStr.replaceAll(RegExp(r'[^0-9\.]'), '')) ??
            0.0;

        if (servingSizeNum > 0) {
          print("Setting serving size to: $servingSizeNum");
          uiProvider.updateServingSize(servingSizeNum);
        }
      }

      // Safe parsing for nutrients with more defensive code
      if (_nutritionAnalysis.containsKey('nutrients') &&
          _nutritionAnalysis['nutrients'] is List) {
        // Create a clean copy - don't assign directly
        parsedNutrients = [];

        for (var nutrient in _nutritionAnalysis['nutrients']) {
          // Skip null entries
          if (nutrient == null) continue;

          // Create safe entry with defaults for all fields
          parsedNutrients.add({
            'name': nutrient['name'] ?? 'Unknown',
            'quantity': nutrient['quantity'] ?? '0',
            'daily_value': nutrient['daily_value'] ?? '0%',
            'status': nutrient['status'] ?? 'Moderate',
            'health_impact': nutrient['health_impact'] ?? 'Moderate',
          });
        }

        // Clear and update good/bad nutrients
        goodNutrients.clear();
        badNutrients.clear();

        for (var nutrient in parsedNutrients) {
          if (nutrient["health_impact"] == "Good" ||
              nutrient["health_impact"] == "Moderate") {
            goodNutrients.add(nutrient);
          } else {
            badNutrients.add(nutrient);
          }
        }
      }
      return "✅Product Analysis complete";
    } catch (e) {
      print("❌ Error analyzing images: $e");
      return "Error: $e";
    } finally {
      uiProvider.setLoading(false);
    }
  }
}
