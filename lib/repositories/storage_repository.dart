import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_consumption.dart';
import 'package:read_the_label/models/user_info.dart';
import 'package:read_the_label/repositories/storage_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository implements StorageRepositoryInterface {
  late final SharedPreferences _prefs;

  Future<void> initStorageRepository() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  List<String> getAllKeys() {
    return _prefs.getKeys().toList();
  }

  @override
  Map<String, double>? getDailyIntake(DateTime date) {
    final String storageKey = getStorageKey(date);
    final String? storedData = _prefs.getString(storageKey);

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

  @override
  Future<void> saveDailyIntake(
      DateTime date, Map<String, double> intake) async {
    final String storageKey = getStorageKey(date);
    await _prefs.setString(storageKey, jsonEncode(intake));
    final savedData = _prefs.getString(storageKey);
    debugPrint(
        "Verification - Saved daily intake data length: ${savedData?.length ?? 0}");
  }

  @override
  List<FoodConsumption> getFoodHistory() {
    final String? storedHistory = _prefs.getString('food_history');
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

  @override
  void saveFoodHistory(List<FoodConsumption> history) {
    final historyJson = history.map((item) => item.toJson()).toList();
    _prefs.setString('food_history', jsonEncode(historyJson));
    final savedData = _prefs.getString('food_history');
    final decodedSave = savedData != null ? jsonDecode(savedData) as List : [];
    debugPrint(
        "Verification - Saved food history items: ${decodedSave.length}");
  }

  @override
  void removeFoodItemFromHistory(FoodConsumption item) {
    final history = getFoodHistory();
    history.removeWhere((element) =>
        element.foodName == item.foodName &&
        element.dateTime.millisecondsSinceEpoch ==
            item.dateTime.millisecondsSinceEpoch);
    saveFoodHistory(history);
  }

  String getStorageKey(DateTime date) {
    return 'dailyIntake_${date.year}-${date.month}-${date.day}';
  }

  UserInfo? getUserInfo() {
    final userInfoJson = _prefs.getString('user_info');
    if (userInfoJson != null) {
      try {
        return UserInfo.fromJson(jsonDecode(userInfoJson));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void saveUserInfo(UserInfo userInfo) {
    _prefs.setString('user_info', jsonEncode(userInfo.toJson()));
  }

  bool isShowOnboarding() {
    return _prefs.getBool('show_onboarding') ?? false;
  }

  void setShowOnboarding() {
    _prefs.setBool('show_onboarding', true);
  }

  bool isSRated() {
    return _prefs.getBool('rate') ?? false;
  }

  void setRate() {
    _prefs.setBool('rate', true);
  }

  @override
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
