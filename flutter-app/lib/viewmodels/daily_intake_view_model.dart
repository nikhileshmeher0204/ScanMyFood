import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/core/constants/nutrient_insights.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/daily_intake_record.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/food_item.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/save_intake_output.dart';
import 'package:read_the_label/models/user_intake_output.dart';
import 'package:read_the_label/repositories/ai_repository_interface.dart';
import 'package:read_the_label/repositories/intake_repository_interface.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/utils/nutrient_utils.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/services/local_database_service.dart';
import 'package:read_the_label/models/cached_daily_intake_record.dart';
import 'package:read_the_label/services/notification_service.dart';
import 'package:read_the_label/services/tools/tool_execution_client.dart';
import 'base_view_model.dart';

class DailyIntakeViewModel extends BaseViewModel {
  // Dependencies
  IntakeRepositoryInterface intakeRepository;
  AiRepositoryInterface aiRepository;
  UiViewModel uiProvider;
  AuthService authService;
  final NotificationService notificationService;
  final ToolExecutionClient toolClient;
  
  StreamSubscription? _sseSub;
  StreamSubscription? _toolSub;

  // State
  bool _isLoading = false;
  UserIntakeOutput? userIntakeOutput;
  SaveIntakeOutput? saveIntakeOutput;
  FoodAnalysisResponse? _intakeDetails;
  List<FoodItem> _analyzedScannedFoodItems = [];
  List<FoodNutrient> _totalScannedPlateNutrients = [];
  List<Map<String, dynamic>> _nutrientInfo = [];
  String _scannedMealName = "Unknown Meal";
  Map<String, FoodNutrient>? _totalNutrientsMap;
  DateTime _selectedDate = DateTime.now();
  String _descriptionText = "";
  bool _isImageGenerating = false;

  // Caching State
  final Map<String, DailyIntakeData> _dailyIntakeCache = {};
  List<DailyIntakeRecord>? _currentDailyIntake;
  bool _isCacheLoaded = false;
  Future<void>? _loadCacheFuture;

  List<DailyIntakeRecord>? get dailyIntake => _currentDailyIntake;

  // Getters
  bool get loading => _isLoading;
  UserIntakeOutput? get userIntake => userIntakeOutput;
  SaveIntakeOutput? get saveIntake => saveIntakeOutput;
  FoodAnalysisResponse? get intakeDetails => _intakeDetails;
  List<FoodItem> get analyzedScannedFoodItems => _analyzedScannedFoodItems;
  List<FoodNutrient> get totalScannedPlateNutrients =>
      _totalScannedPlateNutrients;
  List<Map<String, dynamic>> get nutrientInfo => _nutrientInfo;
  String get scannedMealName => _scannedMealName;
  Map<String, FoodNutrient>? get totalNutrients => _totalNutrientsMap;
  DateTime get selectedDate => _selectedDate;
  String get descriptionText => _descriptionText;
  bool get isImageGenerating => _isImageGenerating;

  bool hasDataForDate(DateTime date) {
    final String key = _formatDateKey(date);
    final data = _dailyIntakeCache[key];
    return data != null && data.dailyIntake.isNotEmpty;
  }

  // Constructor with dependency injection
  DailyIntakeViewModel({
    required this.intakeRepository,
    required this.aiRepository,
    required this.uiProvider,
    required this.authService,
    required this.notificationService,
    required this.toolClient,
  }) {
    loadCacheFromDevice();
    _subscribeToMealLogging();
  }

  void _subscribeToMealLogging() {
    _sseSub = notificationService.onMealLogged.listen((_) => _handleMealLoggedRefresh());
    _toolSub = toolClient.onMealLogged.listen((_) => _handleMealLoggedRefresh());
  }

  void _handleMealLoggedRefresh() {
    final uid = authService.currentUser?.uid;
    if (uid != null) {
      debugPrint("DailyIntakeViewModel: Meal logged event received, refreshing intake for $uid...");
      getDailyIntake(uid, selectedDate);
    }
  }

  void onUserChanged() {
    logger.d("User changed in DailyIntakeViewModel. Resetting state and loading device cache...");
    _dailyIntakeCache.clear();
    _currentDailyIntake = null;
    _totalNutrientsMap = null;
    _isCacheLoaded = false;
    _loadCacheFuture = null;
    loadCacheFromDevice();
  }

  Future<void> loadCacheFromDevice() {
    _loadCacheFuture ??= _loadCacheFromDeviceInternal();
    return _loadCacheFuture!;
  }

  Future<void> _loadCacheFromDeviceInternal() async {
    final uid = authService.currentUser?.uid;
    if (uid == null) {
      _isCacheLoaded = true;
      return;
    }

    try {
      logger.d("Loading cached daily intakes from SQLite database for $uid");
      final cachedRecords = await LocalDatabaseService.instance.getAllDailyIntakes(uid);
      _dailyIntakeCache.clear();
      
      for (var record in cachedRecords) {
        if (!record.isExpired) {
          _dailyIntakeCache[record.dateKey] = record.data;
        } else {
          logger.d("Cached daily intake for $uid on ${record.dateKey} is expired. Skipping load.");
        }
      }
      _setSelectedDateData();
      notifyListeners();
    } catch (e) {
      logger.w("Failed to load daily intake from SQLite database cache: $e");
    } finally {
      _isCacheLoaded = true;
    }
  }

  Future<void> saveCacheToDevice() async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;

    try {
      for (var entry in _dailyIntakeCache.entries) {
        final record = CachedDailyIntakeRecord(
          userId: uid,
          dateKey: entry.key,
          data: entry.value,
          cachedAt: DateTime.now(),
        );
        await LocalDatabaseService.instance.saveDailyIntake(record);
      }
      logger.d("Successfully saved daily intake map to SQLite database cache for $uid");
    } catch (e) {
      logger.w("Failed to save daily intake map to SQLite database: $e");
    }
  }
  setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  setDescriptionText(String text) {
    _descriptionText = text;
  }

  setIsImageGenerating(bool value) {
    _isImageGenerating = value;
    notifyListeners();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _setSelectedDateData() {
    final String key = _formatDateKey(_selectedDate);
    final data = _dailyIntakeCache[key];
    if (data != null) {
      _currentDailyIntake = data.dailyIntake;
      _totalNutrientsMap = {
        for (var nutrient in data.totalNutrients) nutrient.name: nutrient
      };
    } else {
      _currentDailyIntake = [];
      _totalNutrientsMap = {};
    }
  }

  Future<void> updateSelectedDate(DateTime newDate) async {
    final uid = authService.currentUser?.uid ?? "VzvYVBFUlxP0apdJmkGdO0XzDe82";

    _selectedDate = newDate;
    final String key = _formatDateKey(newDate);

    if (!_isCacheLoaded) {
      logger.d("Cache not loaded yet, awaiting loadCacheFromDevice()...");
      await loadCacheFromDevice();
    }

    if (_dailyIntakeCache.isEmpty) {
      _isLoading = true;
      notifyListeners();
      try {
        final now = DateTime.now();
        final fromDate = now.subtract(const Duration(days: 6));
        final toDate = now;
        final output = await intakeRepository.getDailyIntake(
          uid,
          fromDate,
          toDate,
        );
        
        final returnedMap = {
          for (var data in output.dailyIntakes) _formatDateKey(data.date): data
        };

        for (int i = 0; i <= toDate.difference(fromDate).inDays; i++) {
          final date = fromDate.add(Duration(days: i));
          final dateKey = _formatDateKey(date);
          _dailyIntakeCache[dateKey] = returnedMap[dateKey] ?? DailyIntakeData(
            date: date,
            totalNutrients: [],
            dailyIntake: [],
          );
        }
        
        await saveCacheToDevice();
      } catch (e) {
        debugPrint("Failed to fetch initial daily intake: $e");
      }
      _isLoading = false;
    }

    if (!_dailyIntakeCache.containsKey(key)) {
      _isLoading = true;
      notifyListeners();
      try {
        final toDate = DateTime.now();
        final fromDate = toDate.subtract(const Duration(days: 6));
        final output = await intakeRepository.getDailyIntake(
          uid,
          fromDate,
          toDate,
        );
        
        final returnedMap = {
          for (var data in output.dailyIntakes) _formatDateKey(data.date): data
        };

        for (int i = 0; i <= toDate.difference(fromDate).inDays; i++) {
          final date = fromDate.add(Duration(days: i));
          final dateKey = _formatDateKey(date);
          _dailyIntakeCache[dateKey] = returnedMap[dateKey] ?? DailyIntakeData(
            date: date,
            totalNutrients: [],
            dailyIntake: [],
          );
        }
        
        await saveCacheToDevice();
      } catch (e) {
        debugPrint("Failed to fetch daily intake for selected date: $e");
      }
      _isLoading = false;
    }

    _setSelectedDateData();
    notifyListeners();
  }

  List<Map<String, dynamic>> getNutrientHistory(String nutrientName) {
    final List<Map<String, dynamic>> history = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final String key = _formatDateKey(date);
      double val = 0.0;
      final data = _dailyIntakeCache[key];
      if (data != null) {
        final nutrient = data.totalNutrients.firstWhere(
          (n) => n.name.toLowerCase() == nutrientName.toLowerCase(),
          orElse: () => FoodNutrient(
            name: nutrientName,
            quantity: Quantity(value: 0.0, unit: ''),
          ),
        );
        val = nutrient.quantity.value;
      }
      history.add({
        'date': date,
        'value': val,
      });
    }
    return history;
  }

  Future<SaveIntakeOutput> saveScannedFood(String userId, File? foodImage,
      String source, FoodAnalysisResponse? foodAnalysis,
      {DateTime? createdAt}) async {
    try {
      debugPrint(
          "Starting saveScannedFood for userId: $userId, source: $source");
      saveIntakeOutput = await intakeRepository.saveScannedFood(
          userId, foodImage, source, foodAnalysis,
          createdAt: createdAt);
      debugPrint(
          "SaveIntakeOutput received: ${saveIntakeOutput?.dailyIntakeId}");
      return saveIntakeOutput!;
    } catch (e, stackTrace) {
      debugPrint("Error in saveScannedFood: $e");
      debugPrint("StackTrace: $stackTrace");
      setError("Failed to save intake: $e");
      rethrow;
    }
  }

  Future<void> refreshDailyIntake() async {
    final uid = authService.currentUser?.uid ?? "VzvYVBFUlxP0apdJmkGdO0XzDe82";
    final now = DateTime.now();
    final fromDate = now.subtract(const Duration(days: 6));
    final toDate = now;

    try {
      debugPrint("DailyIntakeViewModel: Pull-to-refresh requested for $uid");
      final output = await intakeRepository.getDailyIntake(
        uid,
        fromDate,
        toDate,
      );

      final returnedMap = {
        for (var data in output.dailyIntakes) _formatDateKey(data.date): data
      };

      for (int i = 0; i <= toDate.difference(fromDate).inDays; i++) {
        final date = fromDate.add(Duration(days: i));
        final dateKey = _formatDateKey(date);
        _dailyIntakeCache[dateKey] = returnedMap[dateKey] ?? DailyIntakeData(
          date: date,
          totalNutrients: [],
          dailyIntake: [],
        );
      }

      await saveCacheToDevice();
      _setSelectedDateData();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to refresh daily intake: $e");
    }
  }

  Future<void> getDailyIntake(String userId, DateTime date) async {
    try {
      final output = await intakeRepository.getDailyIntake(
        userId,
        date,
        date,
      );
      
      final key = _formatDateKey(date);
      if (output.dailyIntakes.isEmpty) {
        _dailyIntakeCache[key] = DailyIntakeData(
          date: date,
          totalNutrients: [],
          dailyIntake: [],
        );
      } else {
        for (var dayData in output.dailyIntakes) {
          _dailyIntakeCache[_formatDateKey(dayData.date)] = dayData;
        }
      }
      _setSelectedDateData();
      
      // Save specific date row to SQLite
      if (_dailyIntakeCache.containsKey(key)) {
        final record = CachedDailyIntakeRecord(
          userId: userId,
          dateKey: key,
          data: _dailyIntakeCache[key]!,
          cachedAt: DateTime.now(),
        );
        await LocalDatabaseService.instance.saveDailyIntake(record);
      }
      
      notifyListeners();
    } catch (e) {
      setError("Failed to refresh daily intake: $e");
    }
  }

  Future<void> getIntakeDetailsByDailyIntakeId(
      String userId, int dailyIntakeId) async {
    // Locate the record in our _dailyIntakeCache
    DailyIntakeRecord? record;
    for (var dayData in _dailyIntakeCache.values) {
      for (var r in dayData.dailyIntake) {
        if (r.id == dailyIntakeId) {
          record = r;
          break;
        }
      }
      if (record != null) break;
    }

    if (record == null) {
      // Fallback to fetch from repository just in case it's not in the cache range
      setLoading(true);
      try {
        _intakeDetails = await intakeRepository.getIntakeDetails(
          userId,
          dailyIntakeId,
        );
        _scannedMealName = _intakeDetails!.mealName;
        _analyzedScannedFoodItems = _intakeDetails!.analyzedFoodItems;
        _totalScannedPlateNutrients = _intakeDetails!.totalPlateNutrients;
      } catch (e) {
        setError("Error fetching food details: $e");
        setLoading(false);
        return;
      } finally {
        setLoading(false);
      }
    } else {
      _analyzedScannedFoodItems = record.foodItems;
      _scannedMealName = record.intakeName ?? "Unknown Meal";

      // Reconstruct total Plate Nutrients list from the record's columns
      _totalScannedPlateNutrients = [
        if (record.caloriesValue > 0)
          FoodNutrient(
            name: AppConstants.calories,
            quantity: Quantity(value: record.caloriesValue, unit: record.caloriesUnit),
          )
        else if (record.energyValue > 0)
          FoodNutrient(
            name: AppConstants.energy,
            quantity: Quantity(value: record.energyValue, unit: record.energyUnit),
          ),
        FoodNutrient(
          name: AppConstants.protein,
          quantity: Quantity(value: record.proteinValue, unit: record.proteinUnit),
        ),
        FoodNutrient(
          name: AppConstants.totalCarbohydrate,
          quantity: Quantity(value: record.totalCarbohydrateValue, unit: record.totalCarbohydrateUnit),
        ),
        FoodNutrient(
          name: AppConstants.totalFat,
          quantity: Quantity(value: record.totalFatValue, unit: record.totalFatUnit),
        ),
        FoodNutrient(
          name: AppConstants.dietaryFiber,
          quantity: Quantity(value: record.dietaryFiberValue, unit: record.dietaryFiberUnit),
        ),
        FoodNutrient(
          name: AppConstants.totalSugars,
          quantity: Quantity(value: record.totalSugarsValue, unit: record.totalSugarsUnit),
        ),
        FoodNutrient(
          name: AppConstants.sodium,
          quantity: Quantity(value: record.sodiumValue, unit: record.sodiumUnit),
        ),
        FoodNutrient(
          name: AppConstants.iron,
          quantity: Quantity(value: record.ironValue, unit: record.ironUnit),
        ),
        FoodNutrient(
          name: AppConstants.potassium,
          quantity: Quantity(value: record.potassiumValue, unit: record.potassiumUnit),
        ),
        FoodNutrient(
          name: AppConstants.calcium,
          quantity: Quantity(value: record.calciumValue, unit: record.calciumUnit),
        ),
      ];
      
      // Populate intakeDetails dummy response for TotalNutrientsCard widget parameter compatibility
      _intakeDetails = FoodAnalysisResponse(
        mealName: _scannedMealName,
        portion: record.portion,
        analyzedFoodItems: _analyzedScannedFoodItems,
        totalPlateNutrients: _totalScannedPlateNutrients,
      );
    }

    calculateNutrientInfo(_totalScannedPlateNutrients);
    notifyListeners();
  }

  Future<void> saveScannedLabel(String userId, File? foodImage, String source,
      ProductAnalysisResponse? productAnalysis,
      {DateTime? createdAt}) async {
    await intakeRepository.saveScannedLabel(
        userId, foodImage, source, productAnalysis,
        createdAt: createdAt);
  }

  bool isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void calculateNutrientInfo(List<FoodNutrient> totalScannedPlateNutrients) {
    logger.i("=== Starting calculateNutrientInfo ===");
    logger.i("Input nutrients: $totalScannedPlateNutrients");

    // Clear previous data
    _nutrientInfo.clear();

    // Perform calculations on the totalPlateNutrients
    for (FoodNutrient nutrient in totalScannedPlateNutrients) {
      double value = nutrient.quantity.value;
      String unit = nutrient.quantity.unit;
      String dvStatus = '';
      String goal = '';
      String healthImpact = '';

      logger.i(
          "Processing nutrient: ${nutrient.name} with value: ${nutrient.quantity.value} ${nutrient.quantity.unit}");

      // Get the proper nutrient name for insights lookup
      String nutrientName = NutrientUtils.toTitleCase(nutrient.name);
      logger.i("Nutrient name for lookup: $nutrientName");

      // Find the matching nutrient data
      var matchingNutrient = nutrientDataMap[nutrientName];

      if (matchingNutrient != null) {
        logger.i("Found matching nutrient: ${matchingNutrient['Nutrient']}");

        // Convert string values to numbers
        double currentDV =
            double.parse(matchingNutrient['Current Daily Value'].toString());
        double fivePercentDV =
            double.parse(matchingNutrient['5%DV'].toString());
        double twentyPercentDV =
            double.parse(matchingNutrient['20%DV'].toString());

        logger.i(
            "Current DV: $currentDV, 5%DV: $fivePercentDV, 20%DV: $twentyPercentDV");

        // Calculate daily value percentage
        double dailyValuePercent = (value / currentDV) * 100;
        dailyValuePercent = double.parse(dailyValuePercent.toStringAsFixed(2));
        logger.i("Calculated DV%: $dailyValuePercent");

        // Determine DV status
        if (value < fivePercentDV) {
          dvStatus = 'Low';
        } else if (value > twentyPercentDV) {
          dvStatus = 'High';
        } else {
          dvStatus = 'Moderate';
        }

        goal = matchingNutrient['Goal'].toString();
        logger.i("DV Status: $dvStatus, Goal: $goal");

        // Calculate health impact based on goal and dv status
        if ((dvStatus == "High" && goal == "At least") ||
            (dvStatus == "Low" && goal == "Less than")) {
          healthImpact = "Good";
        } else if (dvStatus == "Moderate" ||
            (dvStatus == "Low" && goal == "At least")) {
          healthImpact = "Bad";
        } else {
          healthImpact = "Bad"; // High + Less than
        }

        var nutrientInfoItem = {
          'name': nutrientName,
          'quantity': value,
          'unit': unit,
          'dv_status': dvStatus,
          'insight': nutrientInsights[nutrientName],
          'goal': goal,
          'daily_value': dailyValuePercent.toDouble(),
          'health_impact': healthImpact,
        };

        _nutrientInfo.add(nutrientInfoItem);
        logger.i("Added nutrient info: $nutrientInfoItem");
      } else {
        // Handle case where nutrient is not found in nutrientData
        logger.w("Nutrient '$nutrientName' not found in nutrient data");
      }
    }

    logger.i("Final _nutrientInfo length: ${_nutrientInfo.length}");
    logger.i("Final _nutrientInfo: $_nutrientInfo");
    logger.i("=== End calculateNutrientInfo ===");
  }

  @override
  void dispose() {
    _sseSub?.cancel();
    _toolSub?.cancel();
    super.dispose();
  }
}
