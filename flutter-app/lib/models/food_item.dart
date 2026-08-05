import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/quantity.dart';

class FoodItem {
  final String name;
  double portion;
  final String? canonicalName;
  final Quantity quantity;
  final List<FoodNutrient> nutrients;

  FoodItem({
    required this.name,
    this.portion = 1.0,
    this.canonicalName,
    required this.quantity,
    required this.nutrients,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    double portion = (json['portion'] as num?)?.toDouble() ?? 1.0;
    Quantity quantity =
        Quantity.fromJson(json['quantity'] ?? {'value': 0.0, 'unit': 'g'});

    List<FoodNutrient> nutrients = [];
    final nutrientItems = json['nutrients'] ?? [];
    if (nutrientItems is List) {
      nutrients =
          nutrientItems.map((item) => FoodNutrient.fromJson(item)).toList();
    }

    return FoodItem(
      name: json['name'] ?? 'Unknown',
      portion: portion,
      canonicalName: json['canonical_name'],
      quantity: quantity,
      nutrients: nutrients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion': portion,
      'canonical_name': canonicalName,
      'quantity': quantity.toJson(),
      'nutrients': nutrients.map((nutrient) => nutrient.toJson()).toList(),
    };
  }
}
