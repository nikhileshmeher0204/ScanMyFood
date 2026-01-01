import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/quantity.dart';

class FoodItem {
  final String name;
  final Quantity quantity;
  final List<FoodNutrient> nutrients;
  final List<FoodNutrient> nutrientsPer100g;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.nutrients,
    required this.nutrientsPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    Quantity quantity =
        Quantity.fromJson(json['quantity'] ?? {'value': 0.0, 'unit': 'g'});

    List<FoodNutrient> nutrients = [];
    final nutrientItems = json['nutrients'] ?? [];
    if (nutrientItems is List) {
      nutrients =
          nutrientItems.map((item) => FoodNutrient.fromJson(item)).toList();
    }

    List<FoodNutrient> nutrientsPer100g = [];
    final nutrientPer100gItems = json['nutrients_per100g'] ?? [];
    if (nutrientPer100gItems is List) {
      nutrientsPer100g = nutrientPer100gItems
          .map((item) => FoodNutrient.fromJson(item))
          .toList();
    }

    return FoodItem(
      name: json['name'] ?? 'Unknown',
      quantity: quantity,
      nutrients: nutrients,
      nutrientsPer100g: nutrientsPer100g,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity.toJson(),
      'nutrients': nutrients.map((nutrient) => nutrient.toJson()).toList(),
      'nutrients_per100g':
          nutrientsPer100g.map((nutrient) => nutrient.toJson()).toList(),
    };
  }
}
