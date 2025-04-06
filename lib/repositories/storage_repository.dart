import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_consumption.dart';
import 'package:read_the_label/repositories/storage_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository implements StorageRepositoryInterface {
  // Get all keys from SharedPreferences
  @override
  Future<List<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().toList();
  }

  // Get daily intake for specified date
  @override
  Future<Map<String, double>?> getDailyIntake(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String storageKey = getStorageKey(date);
    final String? storedData = prefs.getString(storageKey);

    if (storedData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(storedData);
        final Map<String, double> dailyIntake = {};

        decoded.forEach((key, value) {
          dailyIntake[key] = (value as num).toDouble();
        });

        return dailyIntake;
      } catch (e) {
        debugPrint("Error parsing daily intake data: $e");
        return null;
      }
    }
    return null;
  }

  // Save daily intake for specified date
  @override
  Future<void> saveDailyIntake(
      DateTime date, Map<String, double> intake) async {
    final prefs = await SharedPreferences.getInstance();
    final String storageKey = getStorageKey(date);

    await prefs.setString(storageKey, jsonEncode(intake));

    // Verify the save
    final savedData = prefs.getString(storageKey);
    debugPrint(
        "Verification - Saved daily intake data length: ${savedData?.length ?? 0}");
  }

  // Get food history
  @override
  Future<List<FoodConsumption>> getFoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedHistory = prefs.getString('food_history');

    if (storedHistory != null) {
      try {
        final List<dynamic> decoded = jsonDecode(storedHistory);
        return decoded.map((item) => FoodConsumption.fromJson(item)).toList();
      } catch (e) {
        debugPrint("Error loading food history: $e");
        return [];
      }
    }
    return [];
  }

  // Save food history
  @override
  Future<void> saveFoodHistory(List<FoodConsumption> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history.map((item) => item.toJson()).toList();

    await prefs.setString('food_history', jsonEncode(historyJson));

    // Verify the save
    final savedData = prefs.getString('food_history');
    final decodedSave = savedData != null ? jsonDecode(savedData) as List : [];
    debugPrint(
        "Verification - Saved food history items: ${decodedSave.length}");
  }

  // Remove food item from history
  @override
  Future<void> removeFoodItemFromHistory(FoodConsumption item) async {
    final history = await getFoodHistory();
    history.removeWhere((element) =>
        element.foodName == item.foodName &&
        element.dateTime.millisecondsSinceEpoch ==
            item.dateTime.millisecondsSinceEpoch);
    await saveFoodHistory(history);
  }

  // Helper method to get storage key for a specific date
  String getStorageKey(DateTime date) {
    return 'dailyIntake_${date.year}-${date.month}-${date.day}';
  }

  // Clear all data (for testing/debugging)
  @override
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
