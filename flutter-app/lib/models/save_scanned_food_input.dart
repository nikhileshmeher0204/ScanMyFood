import 'package:read_the_label/models/food_analysis_response.dart';

class SaveScannedFoodInput {
  final String userId;
  final String sourceOfIntake;
  final FoodAnalysisResponse foodAnalysisResponse;
  final DateTime? createdAt;

  SaveScannedFoodInput({
    required this.userId,
    required this.sourceOfIntake,
    required this.foodAnalysisResponse,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'source_of_intake': sourceOfIntake,
      'food_analysis_response': foodAnalysisResponse.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
