import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:read_the_label/core/constants/dv_values.dart';
import 'package:read_the_label/repositories/AiRepositoryInterface.dart';

class AiRepository implements AiRepositoryInterface {
  // Get API key
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

  // Analyze product images (front + nutrition)
  @override
  Future<Map<String, dynamic>> analyzeProductImages(
    File frontImage,
    File labelImage,
  ) async {
    final apiKey = getApiKey();
    if (apiKey == null) {
      throw Exception('API key is null');
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final frontImageBytes = await frontImage.readAsBytes();
    final labelImageBytes = await labelImage.readAsBytes();

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
                  "food": "Complementary food to add",
                  "quantity": "Recommended quantity to add",
                  "reasoning": "How this helps balance nutrition"
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
         - Suggest foods that can be added to complement the product
         - Focus on practical additions 
         - Explain how each addition helps balance nutrition
      7. Use %DV guidelines:
         5% DV or less is considered low
         20% DV or more is considered high
         5% < DV < 20% is considered moderate
      8. For health_impact determination:
         "At least" nutrients (like fiber, protein):
           High status → Good health_impact
           Moderate status → Moderate health_impact
           Low status → Bad health_impact
         "Less than" nutrients (like sodium, saturated fat):
           Low status → Good health_impact
           Moderate status → Moderate health_impact
           High status → Bad health_impact
      """);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, ...nutrientParts, ...imageParts])
      ]);

      final responseText = response.text ?? "";

      // Extract JSON
      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
        throw Exception("Invalid JSON structure in response");
      }

      final jsonString = responseText.substring(startIndex, endIndex + 1);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error communicating with AI: $e");
      throw Exception("Error communicating with AI: $e");
    }
  }

  // Analyze meal/plate image
  @override
  Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    final apiKey = getApiKey();
    if (apiKey == null) {
      throw Exception('API key is null');
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
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

      final responseText = response.text ?? "";

      // Extract JSON
      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
        throw Exception("Invalid JSON structure in response");
      }

      final jsonString = responseText.substring(startIndex, endIndex + 1);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error analyzing food image: $e");
      throw Exception("Error analyzing food image: $e");
    }
  }

  // Text-based meal analysis
  @override
  Future<Map<String, dynamic>> analyzeFoodDescription(
      String description) async {
    final apiKey = getApiKey();
    if (apiKey == null) {
      throw Exception('API key is null');
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final prompt = TextPart(
        """You are a nutrition expert. Analyze these food items and their quantities:\n$description\n. Generate nutritional info for each of the mentioned food items and their respective quantities and respond using this JSON schema: 
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

    try {
      final response = await model.generateContent([
        Content.multi([prompt])
      ]);

      final responseText = response.text ?? "";

      // Extract JSON
      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
        throw Exception("Invalid JSON structure in response");
      }

      final jsonString = responseText.substring(startIndex, endIndex + 1);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error analyzing food description: $e");
      throw Exception("Error analyzing food description: $e");
    }
  }
}
