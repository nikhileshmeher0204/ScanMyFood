class FoodItem {
  final String name;
  Quantity quantity;
  final Map<String, Quantity> nutrientsPer100g;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.nutrientsPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Handle quantity
    Quantity quantity =
        Quantity.fromJson(json['quantity'] ?? {'value': 0.0, 'unit': 'g'});

    // Handle nutrients
    Map<String, Quantity> nutrients = {};
    if (json['nutrients_per100g'] != null) {
      Map<String, dynamic> nutrientsJson = json['nutrients_per100g'];
      nutrientsJson.forEach((key, value) {
        nutrients[key] = Quantity.fromJson(value);
      });
    }

    return FoodItem(
      name: json['name'] ?? 'Unknown',
      quantity: quantity,
      nutrientsPer100g: nutrients,
    );
  }

  Map<String, double> calculateTotalNutrients() {
    final factor = quantity.value / 100;
    return {
      'calories': (nutrientsPer100g['calories']?.value ?? 0.0) * factor,
      'protein': (nutrientsPer100g['protein']?.value ?? 0.0) * factor,
      'carbohydrates':
          (nutrientsPer100g['carbohydrates']?.value ?? 0.0) * factor,
      'fat': (nutrientsPer100g['fat']?.value ?? 0.0) * factor,
      'fiber': (nutrientsPer100g['fiber']?.value ?? 0.0) * factor,
      'sugar': (nutrientsPer100g['sugar']?.value ?? 0.0) * factor,
      'sodium': (nutrientsPer100g['sodium']?.value ?? 0.0) * factor,
    };
  }

  void updateQuantity(double newQuantity) {
    quantity = Quantity(value: newQuantity, unit: quantity.unit);
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
