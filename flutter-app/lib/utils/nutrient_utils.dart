import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/models/food_nutrient.dart';

class NutrientUtils {
  static FoodNutrient? getNutrient(FoodItem item, String nutrientName) {
    try {
      return item.nutrients.firstWhere((nutrient) =>
          nutrient.name.toLowerCase() == nutrientName.toLowerCase());
    } catch (e) {
      return null; // Return null if the nutrient is not found
    }
  }

  static double getNutrientValue(FoodItem item, String nutrientName) {
    final value = getNutrient(item, nutrientName)?.quantity.value ?? 0.0;
    return double.parse(value.toStringAsFixed(2));
  }

  static String getNutrientUnit(FoodItem item, String nutrientName) {
    return getNutrient(item, nutrientName)?.quantity.unit ?? '';
  }

  static String toTitleCase(String nutrientName) {
    final name = nutrientName.toLowerCase();
    if (name == 'calories' || name == 'energy') return 'Energy';

    return nutrientName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String toSnakeCase(String nutrientName) {
    return nutrientName
        .trim()
        .split(' ')
        .map((word) => word.toLowerCase())
        .join('_');
  }

  static String? getNutrientIcon(String nutrientName) {
    final name = nutrientName.toLowerCase();
    if (name.contains('protein')) return 'assets/icons/protein_icon.png';
    if (name.contains('carbohydrate')) return 'assets/icons/carbs_icon.png';
    if (name.contains('fat')) return 'assets/icons/fat_icon.png';
    if (name.contains('fiber')) return 'assets/icons/fibre_icon.png';
    if (name.contains('sugar')) return 'assets/icons/sugar_icon.png';
    if (name.contains('sodium')) return 'assets/icons/sodium_icon.png';
    if (name.contains('iron')) return 'assets/icons/iron_icon.png';
    if (name.contains('energy') || name.contains("calories")) {
      return 'assets/icons/energy_icon.png';
    }
    return null;
  }

  static String getNutrientCategory(String dvStatus, String goal) {
    if ((dvStatus == "High" && goal == "At least") ||
        (dvStatus == "Low" && goal == "Less than")) {
      return "Good";
    } else if (dvStatus == "Low" && goal == "At least") {
      return "Insufficient";
    } else if (dvStatus == "High") {
      return "Limit";
    } else {
      return "Moderate";
    }
  }
}
