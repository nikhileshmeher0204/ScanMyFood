import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/models/food_nutrient.dart';

class FoodAnalysisResponse {
  final String mealName;
  double portion;
  final List<FoodItem> analyzedFoodItems;
  List<FoodNutrient> totalPlateNutrients;

  FoodAnalysisResponse({
    required this.mealName,
    this.portion = 1.0,
    required this.analyzedFoodItems,
    required this.totalPlateNutrients,
  });

  factory FoodAnalysisResponse.fromJson(Map<String, dynamic> json) {
    String mealName = json['meal_name'] ?? 'Unknown Meal';
    double portion = (json['portion'] as num?)?.toDouble() ?? 1.0;
    List<FoodItem> foodItems = [];
    List<FoodNutrient> totalNutrients = [];

    final items = json['analyzed_food_items'] ?? [];
    if (items is List) {
      foodItems = items.map((item) => FoodItem.fromJson(item)).toList();
    }

    final nutrientItems = json['total_plate_nutrients'] ?? [];
    if (nutrientItems is List) {
      totalNutrients =
          nutrientItems.map((item) => FoodNutrient.fromJson(item)).toList();
    }

    return FoodAnalysisResponse(
      mealName: mealName,
      portion: portion,
      analyzedFoodItems: foodItems,
      totalPlateNutrients: totalNutrients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_name': mealName,
      'portion': portion,
      'analyzed_food_items':
          analyzedFoodItems.map((item) => item.toJson()).toList(),
      'total_plate_nutrients':
          totalPlateNutrients.map((nutrient) => nutrient.toJson()).toList(),
    };
  }
}
