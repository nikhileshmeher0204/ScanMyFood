import 'package:read_the_label/models/food_analysis_response.dart';

class SaveScannedFoodInput {
  final String userId;
  final FoodAnalysisResponse foodAnalysisResponse;

  SaveScannedFoodInput({
    required this.userId,
    required this.foodAnalysisResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'foodAnalysisResponse': foodAnalysisResponse.toJson(),
    };
  }
}
