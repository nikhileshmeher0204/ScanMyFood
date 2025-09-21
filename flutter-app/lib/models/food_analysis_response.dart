import 'package:read_the_label/models/food_item.dart';

class FoodAnalysisResponse {
  final String mealName;
  final List<FoodItem> analyzedFoodItems;
  final Map<String, Quantity> totalPlateNutrients;

  FoodAnalysisResponse({
    required this.mealName,
    required this.analyzedFoodItems,
    required this.totalPlateNutrients,
  });

  factory FoodAnalysisResponse.fromJson(Map<String, dynamic> json) {
    String mealName = json['meal_name'] ?? 'Unknown Meal';
    List<FoodItem> foodItems = [];
    Map<String, Quantity> totalNutrients = {};

    final items = json['analyzed_food_items'] ?? [];
    if (items is List) {
      foodItems = items.map((item) => FoodItem.fromJson(item)).toList();
    }

    final plateNutrientsJson = json['total_plate_nutrients'];
    if (plateNutrientsJson != null &&
        plateNutrientsJson is Map<String, dynamic>) {
      plateNutrientsJson.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          totalNutrients[key] = Quantity.fromJson(value);
        }
      });
    }

    return FoodAnalysisResponse(
      mealName: mealName,
      analyzedFoodItems: foodItems,
      totalPlateNutrients: totalNutrients,
    );
  }
}

class Quantity {
  final double value;
  final String unit;

  Quantity({required this.value, required this.unit});

  factory Quantity.fromJson(Map<String, dynamic> json) {
    return Quantity(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'g',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}
