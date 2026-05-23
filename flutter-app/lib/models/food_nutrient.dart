import 'package:read_the_label/models/quantity.dart';

class FoodNutrient {
  String name;
  Quantity quantity;

  FoodNutrient({
    required this.name,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity.toJson(),
    };
  }

  factory FoodNutrient.fromJson(Map<String, dynamic> json) {
    return FoodNutrient(
      name: json['name'] ?? '',
      quantity:
          Quantity.fromJson(json['quantity'] ?? {'value': 0.0, 'unit': ''}),
    );
  }
}
