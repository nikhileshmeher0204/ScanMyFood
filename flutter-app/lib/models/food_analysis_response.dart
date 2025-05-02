import 'package:read_the_label/models/food_item.dart';

class FoodAnalysisResponse {
  final String mealName;
  final List<FoodItem> analyzedFoodItems;
  final Map<String, dynamic> totalPlateNutrients;

  FoodAnalysisResponse({
    required this.mealName,
    required this.analyzedFoodItems,
    required this.totalPlateNutrients,
  });

  factory FoodAnalysisResponse.fromJson(Map<String, dynamic> json) {
    // Process analyzed food items
    List<FoodItem> foodItems = [];

    // Get food items from either format
    final items =
        json['analyzedFoodItems'] ?? json['analyzed_food_items'] ?? [];
    if (items is List) {
      foodItems = items.map((item) => FoodItem.fromJson(item)).toList();
    }

    // Get total nutrients - handle both formats
    Map<String, dynamic> totalNutrients = {};
    if (json['totalPlateNutrients'] != null) {
      totalNutrients = Map<String, dynamic>.from(json['totalPlateNutrients']);
    } else if (json['total_plate_nutrients'] != null) {
      totalNutrients = Map<String, dynamic>.from(json['total_plate_nutrients']);
    }

    return FoodAnalysisResponse(
      mealName: json['mealName'] ?? json['meal_name'] ?? 'Unknown Meal',
      analyzedFoodItems: foodItems,
      totalPlateNutrients: totalNutrients,
    );
  }

  // Add helper method to extract nutrient values
  double extractNutrientValue(String nutrient) {
    // If nutrient is directly a number
    if (totalPlateNutrients[nutrient] is num) {
      return (totalPlateNutrients[nutrient] as num).toDouble();
    }

    // If nutrient is a map with a 'value' key
    if (totalPlateNutrients[nutrient] is Map &&
        totalPlateNutrients[nutrient]['value'] != null) {
      var value = totalPlateNutrients[nutrient]['value'];
      return value is num ? value.toDouble() : 0.0;
    }

    // If we can't extract a value, return 0
    return 0.0;
  }

  // Get simple map of nutrient values
  Map<String, double> getSimpleTotalNutrients() {
    return {
      'calories': extractNutrientValue('calories'),
      'protein': extractNutrientValue('protein'),
      'carbohydrates': extractNutrientValue('carbohydrates'),
      'fat': extractNutrientValue('fat'),
      'fiber': extractNutrientValue('fiber'),
    };
  }
}
