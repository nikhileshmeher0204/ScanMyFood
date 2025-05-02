class FoodItem {
  final String name;
  double quantity;
  final String unit;
  final Map<String, dynamic> nutrientsPer100g;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrientsPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Debug the incoming JSON
    print("Parsing FoodItem from: $json");

    // Handle different property names
    String name = json['name'] ?? json['food_name'] ?? 'Unknown';

    // Handle quantity - might be nested or direct
    double quantity = 0.0;
    if (json['quantity'] != null) {
      quantity = (json['quantity'] is int)
          ? (json['quantity'] as int).toDouble()
          : (json['quantity'] as num).toDouble();
    } else if (json['estimated_quantity'] != null &&
        json['estimated_quantity'] is Map) {
      var amount = json['estimated_quantity']['amount'];
      quantity = amount is num ? amount.toDouble() : 0.0;
    }

    // Handle unit - might be nested or direct
    String unit = 'g';
    if (json['unit'] != null) {
      unit = json['unit'];
    } else if (json['estimated_quantity'] != null &&
        json['estimated_quantity'] is Map) {
      unit = json['estimated_quantity']['unit'] ?? 'g';
    }

    // Handle nutrients - different possible formats
    Map<String, dynamic> nutrients = {};
    if (json['nutrientsPer100g'] != null) {
      nutrients = Map<String, dynamic>.from(json['nutrientsPer100g']);
    } else if (json['nutrients_per_100g'] != null) {
      nutrients = Map<String, dynamic>.from(json['nutrients_per_100g']);
    }

    return FoodItem(
      name: name,
      quantity: quantity,
      unit: unit,
      nutrientsPer100g: nutrients,
    );
  }

  Map<String, double> calculateTotalNutrients() {
    final factor = quantity / 100; // Convert to 100g basis
    return {
      'calories': _extractNutrientValue('calories') * factor,
      'protein': _extractNutrientValue('protein') * factor,
      'carbohydrates': _extractNutrientValue('carbohydrates') * factor,
      'fat': _extractNutrientValue('fat') * factor,
      'fiber': _extractNutrientValue('fiber') * factor,
    };
  }

  // Helper method to extract numeric values from potentially nested nutrient data
  double _extractNutrientValue(String nutrient) {
    // If nutrient is directly a number
    if (nutrientsPer100g[nutrient] is num) {
      return (nutrientsPer100g[nutrient] as num).toDouble();
    }

    // If nutrient is a map with a 'value' key
    if (nutrientsPer100g[nutrient] is Map &&
        nutrientsPer100g[nutrient]['value'] != null) {
      var value = nutrientsPer100g[nutrient]['value'];
      return value is num ? value.toDouble() : 0.0;
    }

    // If we can't extract a value, return 0
    return 0.0;
  }

  void updateQuantity(double newQuantity) {
    quantity = newQuantity;
  }
}
