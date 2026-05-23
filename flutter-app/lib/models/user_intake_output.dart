import 'package:read_the_label/models/daily_intake_record.dart';
import 'package:read_the_label/models/food_nutrient.dart';

class UserIntakeOutput {
  final String userId;
  final DateTime date;
  final List<FoodNutrient> totalNutrients;
  final List<DailyIntakeRecord> dailyIntake;

  UserIntakeOutput({
    required this.userId,
    required this.date,
    required this.totalNutrients,
    required this.dailyIntake,
  });

  factory UserIntakeOutput.fromJson(Map<String, dynamic> json) {
    return UserIntakeOutput(
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalNutrients: (json['total_nutrients'] as List<dynamic>)
          .map((e) => FoodNutrient.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyIntake: (json['daily_intake'] as List<dynamic>)
          .map((e) => DailyIntakeRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String(),
      'total_nutrients': totalNutrients.map((e) => e.toJson()).toList(),
      'daily_intake': dailyIntake.map((e) => e.toJson()).toList(),
    };
  }
}
