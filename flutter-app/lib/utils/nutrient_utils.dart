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
}
