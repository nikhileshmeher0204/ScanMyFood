import 'package:read_the_label/models/food_analysis_record.dart';
import 'package:read_the_label/models/food_nutrient.dart';

class UserIntakeOutput {
  final String userId;
  final DateTime date;
  final List<FoodNutrient> totalNutrients;
  final List<FoodAnalysisRecord> foodAnalysisResponse;

  UserIntakeOutput({
    required this.userId,
    required this.date,
    required this.totalNutrients,
    required this.foodAnalysisResponse,
  });

  factory UserIntakeOutput.fromJson(Map<String, dynamic> json) {
    return UserIntakeOutput(
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalNutrients: (json['total_nutrients'] as List<dynamic>)
          .map((e) => FoodNutrient.fromJson(e as Map<String, dynamic>))
          .toList(),
      foodAnalysisResponse: (json['food_analysis_response'] as List<dynamic>)
          .map((e) => FoodAnalysisRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String(),
      'total_nutrients': totalNutrients.map((e) => e.toJson()).toList(),
      'food_analysis_response':
          foodAnalysisResponse.map((e) => e.toJson()).toList(),
    };
  }
}
