class FoodAnalysisRecord {
  final int id;
  final String userId;
  final String mealName;
  final String imageUrl;
  final double caloriesValue;
  final String caloriesUnit;
  final double proteinValue;
  final String proteinUnit;
  final double carbohydratesValue;
  final String carbohydratesUnit;
  final double fatValue;
  final String fatUnit;
  final double fiberValue;
  final String fiberUnit;
  final double sugarValue;
  final String sugarUnit;
  final double sodiumValue;
  final String sodiumUnit;
  final DateTime createdAt;

  FoodAnalysisRecord({
    required this.id,
    required this.userId,
    required this.mealName,
    required this.imageUrl,
    required this.caloriesValue,
    required this.caloriesUnit,
    required this.proteinValue,
    required this.proteinUnit,
    required this.carbohydratesValue,
    required this.carbohydratesUnit,
    required this.fatValue,
    required this.fatUnit,
    required this.fiberValue,
    required this.fiberUnit,
    required this.sugarValue,
    required this.sugarUnit,
    required this.sodiumValue,
    required this.sodiumUnit,
    required this.createdAt,
  });

  factory FoodAnalysisRecord.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisRecord(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      mealName: json['meal_name'] as String,
      imageUrl: json['image_url'] as String,
      caloriesValue: (json['calories_value'] as num).toDouble(),
      caloriesUnit: json['calories_unit'] as String,
      proteinValue: (json['protein_value'] as num).toDouble(),
      proteinUnit: json['protein_unit'] as String,
      carbohydratesValue: (json['carbohydrates_value'] as num).toDouble(),
      carbohydratesUnit: json['carbohydrates_unit'] as String,
      fatValue: (json['fat_value'] as num).toDouble(),
      fatUnit: json['fat_unit'] as String,
      fiberValue: (json['fiber_value'] as num).toDouble(),
      fiberUnit: json['fiber_unit'] as String,
      sugarValue: (json['sugar_value'] as num).toDouble(),
      sugarUnit: json['sugar_unit'] as String,
      sodiumValue: (json['sodium_value'] as num).toDouble(),
      sodiumUnit: json['sodium_unit'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_name': mealName,
      'image_url': imageUrl,
      'calories_value': caloriesValue,
      'calories_unit': caloriesUnit,
      'protein_value': proteinValue,
      'protein_unit': proteinUnit,
      'carbohydrates_value': carbohydratesValue,
      'carbohydrates_unit': carbohydratesUnit,
      'fat_value': fatValue,
      'fat_unit': fatUnit,
      'fiber_value': fiberValue,
      'fiber_unit': fiberUnit,
      'sugar_value': sugarValue,
      'sugar_unit': sugarUnit,
      'sodium_value': sodiumValue,
      'sodium_unit': sodiumUnit,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
