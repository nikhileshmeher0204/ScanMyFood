import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/models/quantity.dart';

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
