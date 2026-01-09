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
    return getNutrient(item, nutrientName)?.quantity.value ?? 0.0;
  }

  static String getNutrientUnit(FoodItem item, String nutrientName) {
    return getNutrient(item, nutrientName)?.quantity.unit ?? '';
  }

  static String toTitleCase(String nutrientName) {
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
}
