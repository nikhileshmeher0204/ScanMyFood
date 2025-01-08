import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // Add this import
import 'package:read_the_label/models/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/dv_values.dart';
import 'models/food_consumption.dart';

class Logic {
  String _generatedText = "";
  File? _frontImage;
  File? _nutritionLabelImage;
  File? get frontImage => _frontImage;
  File? get nutritionLabelImage => _nutritionLabelImage;
  List<Map<String, dynamic>> parsedNutrients = [];
  List<Map<String, dynamic>> goodNutrients = [];
  List<Map<String, dynamic>> badNutrients = [];
  File? foodImage;
  List<FoodItem> analyzedFoodItems = [];
  Map<String, dynamic> totalPlateNutrients = {};
  double _servingSize = 0.0;
  double sliderValue = 0.0;
  Map<String, double> dailyIntake = {};
  bool _isLoading = false;
  static final navKey = GlobalKey<NavigatorState>();
  Function(void Function())? _mySetState;
  String _productName = "";
  String get productName => _productName;
  Map<String, dynamic> _nutritionAnalysis = {};
  Map<String, dynamic> get nutritionAnalysis => _nutritionAnalysis;
  List<FoodConsumption> _foodHistory = [];
  List<FoodConsumption> get foodHistory => _foodHistory;
  final ValueNotifier<bool> loadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> mealNameNotifier = ValueNotifier<String>("");
  final dailyIntakeNotifier = ValueNotifier<Map<String, double>>({});

  // String _mealName = "";
  // String get mealName => _mealName;
  String get mealName => mealNameNotifier.value;
  set _mealName(String value) {
    mealNameNotifier.value = value;
  }

  @override
  void dispose() {
    mealNameNotifier.dispose();
    loadingNotifier.dispose();
  }

  bool get isAnalyzing => loadingNotifier.value;
  set _isAnalyzing(bool value) {
    loadingNotifier.value = value;
  }

  String? getApiKey() {
    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key == null || key.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }
      return key;
    } catch (e) {
      debugPrint('Error loading API key: $e');
      return null;
    }
  }

  String getStorageKey(DateTime date) {
    // Standardize the storage key format
    return 'dailyIntake_${date.year}-${date.month}-${date.day}';
  }

  Future<void> debugCheckStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all keys
    final keys = prefs.getKeys();
    print("All SharedPreferences keys: $keys");

    // Print food history
    final foodHistoryData = prefs.getString('food_history');
    print("Stored food history: $foodHistoryData");

    // Print daily intakes for last 7 days
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = 'dailyIntake_${date.year}-${date.month}-${date.day}';
      final data = prefs.getString(key);
      print("Daily intake for ${date.toString().split(' ')[0]}: $data");
    }
  }

  Future<void> saveDailyIntake() async {
    try {
      print("✅Start of saveDailyIntake()");
      print("⚡Daily intake at the start of saveDailyIntake(): $dailyIntake");
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final storageKey = getStorageKey(today);

      // Get existing data first
      final existingData = prefs.getString(storageKey);
      Map<String, double> updatedIntake = {};

      if (existingData != null) {
        final decoded = jsonDecode(existingData) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          updatedIntake[key] = (value as num).toDouble();
        });
      }

      // Merge existing data with new data
      dailyIntake.forEach((key, value) {
        updatedIntake[key] = (updatedIntake[key] ?? 0.0) + value;
      });

      print("Saving daily intake with key: $storageKey");
      print("Data being saved: $updatedIntake");

      await prefs.setString(storageKey, jsonEncode(updatedIntake));
      dailyIntake = updatedIntake; // Update the current dailyIntake

      // Verify the save
      final savedData = prefs.getString(storageKey);
      print("Verification - Saved data: $savedData");
      print("⚡Daily intake at the end of saveDailyIntake(): $dailyIntake");
      print("✅End of saveDailyIntake()");
    } catch (e) {
      print("Error saving daily intake: $e");
    }
  }

  Future<void> addToFoodHistory({
    required String foodName,
    required Map<String, double> nutrients,
    required String source,
    required String imagePath,
  }) async {
    print("✅Start of addToFoodHistory()");
    print("⚡Daily intake at start of addToFoodHistory(): $dailyIntake");
    print("Adding to food history: $foodName");
    print("With nutrients: $nutrients");
    print("Source: $source");
    print("Image path: $imagePath");

    // Load existing history first
    await loadFoodHistory();

    final consumption = FoodConsumption(
      foodName: foodName,
      dateTime: DateTime.now(),
      nutrients: nutrients,
      source: source,
      imagePath: imagePath,
    );

    // Add new item to existing history
    _foodHistory.add(consumption);
    print("Updated food history length: ${_foodHistory.length}");

    await _saveFoodHistory();
    print("✅End of addToFoodHistory()");
    print("⚡Daily intake at end of addToFoodHistory(): $dailyIntake");
  }

  Future<void> loadFoodHistory() async {
    print("✅Start of loadFoodHistory()");
    print("⚡Daily intake: $dailyIntake");
    print("Loading food history from storage...");
    final prefs = await SharedPreferences.getInstance();
    final String? storedHistory = prefs.getString('food_history');

    if (storedHistory != null) {
      print("Found stored food history");
      try {
        final List<dynamic> decoded = jsonDecode(storedHistory);
        print("Decoded food history items: ${decoded.length}");

        // Create new list instead of clearing existing one
        _foodHistory =
            decoded.map((item) => FoodConsumption.fromJson(item)).toList();

        print("Successfully loaded ${_foodHistory.length} food items");
        _foodHistory.forEach((item) {
          print("Loaded item: ${item.foodName} on ${item.dateTime}");
        });
        print("⚡Daily intake: $dailyIntake");
        print("✅End of loadFoodHistory()");
      } catch (e) {
        print("Error loading food history: $e");
        _foodHistory = [];
      }
    } else {
      print("No stored food history found");
      _foodHistory = [];
    }
  }

  Future<void> _saveFoodHistory() async {
    try {
      print("✅Start of _saveFoodHistory()");
      print("⚡Daily intake at start of _saveFoodHistory(): $dailyIntake");
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _foodHistory.map((item) => item.toJson()).toList();
      print("Saving food history with ${historyJson.length} items");

      await prefs.setString('food_history', jsonEncode(historyJson));

      // Verify the save
      final savedData = prefs.getString('food_history');
      final decodedSave =
          savedData != null ? jsonDecode(savedData) as List : [];
      print("Verification - Saved food history items: ${decodedSave.length}");
      print("⚡Daily intake at end of _saveFoodHIistory(): $dailyIntake");
      print("✅End of _saveFoodHistory()");
    } catch (e) {
      print("Error saving food history: $e");
    }
  }

  Future<void> addToDailyIntake(
      BuildContext context, Function(int) updateIndex, String source) async {
    dailyIntake = {};
    print("Adding to daily intake. Source: $source");
    print("Current daily intake before: $dailyIntake");
    print("✅Start of addToDailyIntake()");
    print("⚡Daily intake at start of addToDailyIntake(): $dailyIntake");

    Map<String, double> newNutrients = {};
    File? imageFile;

    if (source == 'label' && parsedNutrients.isNotEmpty) {
      for (var nutrient in parsedNutrients) {
        final name = nutrient['name'];
        final quantity = double.tryParse(
                nutrient['quantity'].replaceAll(RegExp(r'[^0-9\.]'), '')) ??
            0;
        double adjustedQuantity = quantity * (sliderValue / _servingSize);
        newNutrients[name] = adjustedQuantity;
      }
      imageFile = _frontImage;
    } else if (source == 'food' && totalPlateNutrients.isNotEmpty) {
      newNutrients = {
        'Energy': (totalPlateNutrients['calories'] ?? 0).toDouble(),
        'Protein': (totalPlateNutrients['protein'] ?? 0).toDouble(),
        'Carbohydrate': (totalPlateNutrients['carbohydrates'] ?? 0).toDouble(),
        'Fat': (totalPlateNutrients['fat'] ?? 0).toDouble(),
        'Fiber': (totalPlateNutrients['fiber'] ?? 0).toDouble(),
      };
      imageFile = foodImage;
    }

    // Save the image to the device storage
    String imagePath = '';
    if (imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await imageFile.copy('${directory.path}/$imageName');
      imagePath = savedImage.path;
    }

    // Update dailyIntake with new nutrients
    newNutrients.forEach((key, value) {
      dailyIntake[key] = (dailyIntake[key] ?? 0.0) + value;
    });

    await addToFoodHistory(
      foodName: source == 'label' ? _productName : mealName,
      nutrients: newNutrients,
      source: source,
      imagePath: imagePath,
    );

    await saveDailyIntake();
    dailyIntakeNotifier.value = Map.from(dailyIntake);
    print("⚡Daily intake at end of addToDailyIntake(): $dailyIntake");
    print("✅End of addToDailyIntake()");

    updateIndex(2);
  }

  double getServingSize() => _servingSize;
  List<Map<String, dynamic>> getGoodNutrients() => goodNutrients;
  List<Map<String, dynamic>> getBadNutrients() => badNutrients;

  bool getIsLoading() => _isLoading;

  void setSetState(Function(void Function()) setState) {
    _mySetState = setState;
  }

  void updateSliderValue(double newValue, Function(void Function()) setState) {
    sliderValue = newValue;
    setState(() {});
  }

  static GlobalKey<NavigatorState> getNavKey() => navKey;

  String? getInsights(Map<String, double> dailyIntake) {
    for (var nutrient in nutrientData) {
      String nutrientName = nutrient['Nutrient'];
      if (dailyIntake.containsKey(nutrientName)) {
        try {
          double dvValue = double.parse(nutrient['Current Daily Value']
              .replaceAll(RegExp(r'[^0-9\.]'), ''));
          double percent = dailyIntake[nutrientName]! / dvValue;
          if (percent > 1.0) {
            return "You have exceeded the recommended daily intake of $nutrientName";
          }
        } catch (e) {
          print("Error parsing to double: $e");
        }
      }
    }
    return null;
  }

  void updateServingSize(double newSize) {
    _servingSize = newSize;
    // Reset slider value when serving size changes
    sliderValue = 0.0;
    if (_mySetState != null) {
      _mySetState!(() {});
    }
  }

  double getCalories() {
    var energyNutrient = parsedNutrients.firstWhere(
      (nutrient) => nutrient['name'] == 'Energy',
      orElse: () => {'quantity': '0.0'},
    );
    // Parse the quantity string to remove any non-numeric characters except decimal points
    var quantity = energyNutrient['quantity']
        .toString()
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(quantity) ?? 0.0;
  }

  String getUnit(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'energy':
        return ' kcal';
      case 'protein':
      case 'carbohydrate':
      case 'fat':
      case 'fiber':
      case 'sugar':
        return 'g';
      case 'sodium':
      case 'potassium':
      case 'calcium':
      case 'iron':
        return 'mg';
      default:
        return '';
    }
  }

  IconData getNutrientIcon(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'energy':
        return Icons.bolt;
      case 'protein':
        return Icons.fitness_center;
      case 'carbohydrate':
        return Icons.grain;
      case 'fat':
        return Icons.opacity;
      case 'fiber':
        return Icons.grass;
      case 'sodium':
        return Icons.water_drop;
      case 'calcium':
        return Icons.shield;
      case 'iron':
        return Icons.architecture;
      case 'vitamin':
        return Icons.brightness_high;
      default:
        return Icons.science;
    }
  }

  Color getColorForPercent(double percent, BuildContext context) {
    if (percent > 1.0) return Colors.red; // Exceeded daily value
    if (percent > 0.8) return Colors.green; // High but not exceeded
    if (percent > 0.6) return Colors.yellow; // Moderate
    if (percent > 0.4) return Colors.yellow; // Low to moderate
    return Colors.green; // Low
  }

  Future<String> analyzeImages(
      {required Function(void Function()) setState}) async {
    _isLoading = true;
    setState(() {});

    final apiKey = getApiKey();

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);

    final frontImageBytes = await _frontImage!.readAsBytes();
    final labelImageBytes = await _nutritionLabelImage!.readAsBytes();

    final imageParts = [
      DataPart('image/jpeg', frontImageBytes),
      DataPart('image/jpeg', labelImageBytes),
    ];

    final nutrientParts = nutrientData
        .map((nutrient) => TextPart(
            "${nutrient['Nutrient']}: ${nutrient['Current Daily Value']}"))
        .toList();
    final prompt = TextPart(
        """Analyze the food product, product name and its nutrition label. Provide response in this strict JSON format:
{
  "product": {
    "name": "Product name from front image",
    "category": "Food category (e.g., snack, beverage, etc.)"
  },
  "nutrition_analysis": {
    "serving_size": "Serving size with unit",
    "nutrients": [
      {
        "name": "Nutrient name",
        "quantity": "Quantity with unit",
        "daily_value": "Percentage of daily value",
        "status": "High/Moderate/Low based on DV%",
        "health_impact": "Good/Bad/Moderate"
      }
    ],
    "primary_concerns": [
      {
        "issue": "Primary nutritional concern",
        "explanation": "Brief explanation of health impact",
        "recommendations": [
          {
            "food": "Complementary food suitable to add to this product, consider product name for determining suitability for complementary food additions",
            "quantity": "Recommended quantity to add",
            "reasoning": "How this addition helps balance the nutrition (e.g., slows sugar absorption, adds fiber, reduces glycemic index)"
          }
        ]
      }
    ]
  }
}

Strictly follow these rules:
1. Mention Quantity with units in the label
2. Do not include any extra characters or formatting outside of the JSON object
3. Use accurate escape sequences for any special characters
4. Avoid including nutrients that aren't mentioned in the label
5. For primary_concerns, focus on major nutritional imbalances
6. For recommendations:
   - Suggest foods that can be added to or consumed with the product to improve its nutritional balance
   - Focus on practical additions that complement the main product
   - Explain how each addition helps balance the nutrition (e.g., adding fiber to slow sugar absorption)
   - Consider cultural context and common food pairings
   - Provide specific quantities for the recommended additions
7. Use %DV to determine if a serving is high or low in an individual nutrient:
   5% DV or less is considered low
   20% DV or more is considered high
   5% < DV < 20% is considered moderate
8. For health_impact determination:
   For "At least" nutrients (like fiber, protein):
     High status → Good health_impact
     Moderate status → Moderate health_impact
     Low status → Bad health_impact
   For "Less than" nutrients (like sodium, saturated fat):
     Low status → Good health_impact
     Moderate status → Moderate health_impact
     High status → Bad health_impact
""");

    final response = await model.generateContent([
      Content.multi([prompt, ...nutrientParts, ...imageParts])
    ]);

    _generatedText = response.text!;
    print("This is response content: $_generatedText");
    try {
      final jsonString = _generatedText.substring(
          _generatedText.indexOf('{'), _generatedText.lastIndexOf('}') + 1);
      final jsonResponse = jsonDecode(jsonString);

      _productName = jsonResponse['product']['name'];
      _nutritionAnalysis = jsonResponse['nutrition_analysis'];

      if (_nutritionAnalysis.containsKey("serving_size")) {
        _servingSize = double.tryParse(_nutritionAnalysis["serving_size"]
                .replaceAll(RegExp(r'[^0-9\.]'), '')) ??
            0.0;
      }

      parsedNutrients = (_nutritionAnalysis['nutrients'] as List)
          .cast<Map<String, dynamic>>();

      parsedNutrients = (_nutritionAnalysis['nutrients'] as List)
          .cast<Map<String, dynamic>>()
          .map((nutrient) {
        // Handle null values by providing default values
        return {
          'name': nutrient['name'] ?? 'Unknown',
          'quantity': nutrient['quantity'] ?? '0',
          'daily_value': nutrient['daily_value'] ?? '0%',
          'status': nutrient['status'] ?? 'Moderate',
          'health_impact': nutrient['health_impact'] ?? 'Moderate',
        };
      }).toList();

      // Clear and update good/bad nutrients
      goodNutrients.clear();
      badNutrients.clear();
      for (var nutrient in parsedNutrients) {
        if (nutrient["health_impact"] == "Good" ||
            nutrient["health_impact"] == "Moderate") {
          goodNutrients.add(nutrient);
        } else {
          badNutrients.add(nutrient);
        }
      }
    } catch (e) {
      print("Error parsing JSON: $e");
    }

    _isLoading = false;
    setState(() {});
    return _generatedText;
  }

  Future<String> logMealViaText({
    required String foodItemsText,
  }) async {
    try {
      _isAnalyzing = true;

      print("Processing logging food items via text: \n$foodItemsText");
      final apiKey = getApiKey();
      print("Apikey is: ");
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
      );

      final prompt = TextPart(
          """You are a nutrition expert. Analyze these food items and their quantities:\n$foodItemsText\n. Generate nutritional info for each of the mentioned food items and their respective quantities and respond using this JSON schema: 
{
  "meal_analysis": {
  "meal_name": "Name of the meal",
    "items": [
      {
        "food_name": "Name of the food item",
        "mentioned_quantity": {
          "amount": 0,
          "unit": "g",
        },
        "nutrients_per_100g": {
          "calories": 0,
          "protein": {"value": 0, "unit": "g"},
          "carbohydrates": {"value": 0, "unit": "g"},
          "fat": {"value": 0, "unit": "g"},
          "fiber": {"value": 0, "unit": "g"}
        },
        "nutrients_in_mentioned_quantity": {
          "calories": 0,
          "protein": {"value": 0, "unit": "g"},
          "carbohydrates": {"value": 0, "unit": "g"},
          "fat": {"value": 0, "unit": "g"},
          "fiber": {"value": 0, "unit": "g"}
        },
      }
    ],
    "total_nutrients": {
      "calories": 0,
      "protein": {"value": 0, "unit": "g"},
      "carbohydrates": {"value": 0, "unit": "g"},
      "fat": {"value": 0, "unit": "g"},
      "fiber": {"value": 0, "unit": "g"}
    }
  }
}

Important considerations:
1. Use standard USDA database values when available
2. Account for common preparation methods
3. Convert all measurements to standard units
4. Consider regional variations in portion sizes
5. Round values to one decimal place
6. Account for density and volume-to-weight conversions

Provide accurate nutritional data based on the most reliable food databases and scientific sources.
""");
      final response = await model.generateContent([
        Content.multi([prompt])
      ]);
      if (response.text == null) {
        throw Exception("Empty response from model");
      }
      print("\n\nGot response from model!");

      try {
        // Extract JSON from response
        final jsonString = response.text!.substring(
          response.text!.indexOf('{'),
          response.text!.lastIndexOf('}') + 1,
        );
        final jsonResponse = jsonDecode(jsonString);
        final plateAnalysis = jsonResponse['meal_analysis'];
        _mealName = plateAnalysis['meal_name'] ?? 'Unknown Meal';
        // Clear previous analysis
        analyzedFoodItems.clear();

        // Process each food item
        if (plateAnalysis['items'] != null) {
          for (var item in plateAnalysis['items']) {
            analyzedFoodItems.add(FoodItem(
              name: item['food_name'],
              quantity: item['mentioned_quantity']['amount'].toDouble(),
              unit: item['mentioned_quantity']['unit'],
              nutrientsPer100g: {
                'calories': item['nutrients_per_100g']['calories'],
                'protein': item['nutrients_per_100g']['protein']['value'],
                'carbohydrates': item['nutrients_per_100g']['carbohydrates']
                    ['value'],
                'fat': item['nutrients_per_100g']['fat']['value'],
                'fiber': item['nutrients_per_100g']['fiber']['value'],
              },
            ));
          }
        }

        // Store total nutrients
        totalPlateNutrients = {
          'calories': plateAnalysis['total_nutrients']['calories'],
          'protein': plateAnalysis['total_nutrients']['protein']['value'],
          'carbohydrates': plateAnalysis['total_nutrients']['carbohydrates']
              ['value'],
          'fat': plateAnalysis['total_nutrients']['fat']['value'],
          'fiber': plateAnalysis['total_nutrients']['fiber']['value'],
        };

        // Print statements to check values
        print("Total Plate Nutrients:");
        print("Calories: ${totalPlateNutrients['calories']}");
        print("Protein: ${totalPlateNutrients['protein']}");
        print("Carbohydrates: ${totalPlateNutrients['carbohydrates']}");
        print("Fat: ${totalPlateNutrients['fat']}");
        print("Fiber: ${totalPlateNutrients['fiber']}");
        _isAnalyzing = false;
        print("\n\nsetting _isLoading to false\n\n");
        return response.text!;
      } catch (e) {
        print("Error analyzing food: $e");
        _isAnalyzing = false;
        return "Error";
      }
    } catch (e) {
      print("Error: $e");
      return "Unexpected error";
    }
  }

  Future<String> analyzeFoodImage({
    required File imageFile,
    required Function(void Function()) setState,
    required bool mounted,
  }) async {
    _isLoading = true;
    setState(() {});

    final apiKey = getApiKey();

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);

    final imageBytes = await imageFile.readAsBytes();

    final prompt = TextPart(
        """Analyze this food image and break down each visible food item. 
Provide response in this strict JSON format:
{
  "plate_analysis": {
  "meal_name": "Name of the meal",
    "items": [
      {
        "food_name": "Name of the food item",
        "estimated_quantity": {
          "amount": 0,
          "unit": "g",
        },
        "nutrients_per_100g": {
          "calories": 0,
          "protein": {"value": 0, "unit": "g"},
          "carbohydrates": {"value": 0, "unit": "g"},
          "fat": {"value": 0, "unit": "g"},
          "fiber": {"value": 0, "unit": "g"}
        },
        "total_nutrients": {
          "calories": 0,
          "protein": {"value": 0, "unit": "g"},
          "carbohydrates": {"value": 0, "unit": "g"},
          "fat": {"value": 0, "unit": "g"},
          "fiber": {"value": 0, "unit": "g"}
        },
        "visual_cues": ["List of visual indicators used for estimation"],
        "position": "Description of item location in the image"
      }
    ],
    "total_plate_nutrients": {
      "calories": 0,
      "protein": {"value": 0, "unit": "g"},
      "carbohydrates": {"value": 0, "unit": "g"},
      "fat": {"value": 0, "unit": "g"},
      "fiber": {"value": 0, "unit": "g"}
    }
  }
}

Consider:
1. Use visual cues to estimate portions (size relative to plate, height of food, etc.)
2. Provide nutrients both per 100g and for estimated total quantity
3. Consider common serving sizes and preparation methods
""");

    try {
      final response = await model.generateContent([
        Content.multi([prompt, DataPart('image/jpeg', imageBytes)])
      ]);

      if (response.text != null) {
        try {
          // Extract JSON from response
          final jsonString = response.text!.substring(
            response.text!.indexOf('{'),
            response.text!.lastIndexOf('}') + 1,
          );
          final jsonResponse = jsonDecode(jsonString);
          final plateAnalysis = jsonResponse['plate_analysis'];
          _mealName = plateAnalysis['meal_name'] ?? 'Unknown Meal';
          // Clear previous analysis
          analyzedFoodItems.clear();

          // Process each food item
          if (plateAnalysis['items'] != null) {
            for (var item in plateAnalysis['items']) {
              analyzedFoodItems.add(FoodItem(
                name: item['food_name'],
                quantity: item['estimated_quantity']['amount'].toDouble(),
                unit: item['estimated_quantity']['unit'],
                nutrientsPer100g: {
                  'calories': item['nutrients_per_100g']['calories'],
                  'protein': item['nutrients_per_100g']['protein']['value'],
                  'carbohydrates': item['nutrients_per_100g']['carbohydrates']
                      ['value'],
                  'fat': item['nutrients_per_100g']['fat']['value'],
                  'fiber': item['nutrients_per_100g']['fiber']['value'],
                },
              ));
            }
          }

          // Store total nutrients
          totalPlateNutrients = {
            'calories': plateAnalysis['total_plate_nutrients']['calories'],
            'protein': plateAnalysis['total_plate_nutrients']['protein']
                ['value'],
            'carbohydrates': plateAnalysis['total_plate_nutrients']
                ['carbohydrates']['value'],
            'fat': plateAnalysis['total_plate_nutrients']['fat']['value'],
            'fiber': plateAnalysis['total_plate_nutrients']['fiber']['value'],
          };

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          return response.text!;
        } catch (e) {
          print("Error parsing JSON response: $e");
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return "Error parsing response";
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return "No response received";
    } catch (e) {
      print("Error analyzing food image: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return "Error analyzing image";
    }
  }

  Future<void> captureImage({
    required ImageSource source,
    required bool isFrontImage,
    required Function(void Function()) setState,
  }) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: source);

    if (image != null) {
      if (isFrontImage) {
        _frontImage = File(image.path);
      } else {
        _nutritionLabelImage = File(image.path);
      }
      setState(() {});
    }
  }

  bool canAnalyze() => _frontImage != null && _nutritionLabelImage != null;

  void updateTotalNutrients() {
    totalPlateNutrients = {
      'calories': 0.0,
      'protein': 0.0,
      'carbohydrates': 0.0,
      'fat': 0.0,
      'fiber': 0.0,
    };

    for (var item in analyzedFoodItems) {
      var itemNutrients = item.calculateTotalNutrients();
      totalPlateNutrients['calories'] =
          (totalPlateNutrients['calories'] ?? 0.0) +
              (itemNutrients['calories'] ?? 0.0);
      totalPlateNutrients['protein'] = (totalPlateNutrients['protein'] ?? 0.0) +
          (itemNutrients['protein'] ?? 0.0);
      totalPlateNutrients['carbohydrates'] =
          (totalPlateNutrients['carbohydrates'] ?? 0.0) +
              (itemNutrients['carbohydrates'] ?? 0.0);
      totalPlateNutrients['fat'] =
          (totalPlateNutrients['fat'] ?? 0.0) + (itemNutrients['fat'] ?? 0.0);
      totalPlateNutrients['fiber'] = (totalPlateNutrients['fiber'] ?? 0.0) +
          (itemNutrients['fiber'] ?? 0.0);
    }
  }
}
