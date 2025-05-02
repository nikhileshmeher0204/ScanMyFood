import 'dart:io';

import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/product_analysis_response.dart';

abstract class AiRepositoryInterface {
  Future<ProductAnalysisResponse> analyzeProductImages(
      File frontImage, File labelImage);
  Future<FoodAnalysisResponse> analyzeFoodImage(File imageFile);
  Future<FoodAnalysisResponse> analyzeFoodDescription(String description);
}
