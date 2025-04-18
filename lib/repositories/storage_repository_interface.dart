import 'package:read_the_label/models/food_consumption.dart';

abstract class StorageRepositoryInterface {
  /// Get all keys from storage
  List<String> getAllKeys();

  /// Get daily intake for specified date
  Map<String, double>? getDailyIntake(DateTime date);

  /// Save daily intake for specified date
  void saveDailyIntake(DateTime date, Map<String, double> intake);

  /// Get food consumption history
  List<FoodConsumption> getFoodHistory();

  /// Save food consumption history
  void saveFoodHistory(List<FoodConsumption> history);

  /// Remove specific food item from history
  void removeFoodItemFromHistory(FoodConsumption item);

  /// Clear all stored data
  void clearAllData();
}
