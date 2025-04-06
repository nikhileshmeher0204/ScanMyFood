import 'package:read_the_label/models/food_consumption.dart';

abstract class StorageRepositoryInterface {
  /// Get all keys from storage
  Future<List<String>> getAllKeys();

  /// Get daily intake for specified date
  Future<Map<String, double>?> getDailyIntake(DateTime date);

  /// Save daily intake for specified date
  Future<void> saveDailyIntake(DateTime date, Map<String, double> intake);

  /// Get food consumption history
  Future<List<FoodConsumption>> getFoodHistory();

  /// Save food consumption history
  Future<void> saveFoodHistory(List<FoodConsumption> history);

  /// Remove specific food item from history
  Future<void> removeFoodItemFromHistory(FoodConsumption item);

  /// Clear all stored data
  Future<void> clearAllData();
}
