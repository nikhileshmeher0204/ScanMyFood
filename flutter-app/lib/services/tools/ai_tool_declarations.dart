import 'package:firebase_ai/firebase_ai.dart' as fbai;

class AiToolDeclarations {
  static List<fbai.FunctionDeclaration> get all => [
        fbai.FunctionDeclaration(
          'getUserProfile',
          'Fetches the user\'s health profile including weight, height, BMI, dietary preferences, health conditions, and fitness goals. No PII is returned.',
          parameters: {},
        ),
        fbai.FunctionDeclaration(
          'logMealViaDescription',
          'Analyzes a natural language meal description to extract nutritional data and saves it as a meal intake record. Returns the meal details.',
          parameters: {
            'description': fbai.Schema.string(
              description: 'Natural language description of the meal (e.g. "2 eggs and toast with butter")',
            ),
          },
        ),
        fbai.FunctionDeclaration(
          'saveScannedFoodIntake',
          'Saves the analyzed meal details into the user\'s daily intake log. Call this only after the user explicitly confirms they want to log the meal.',
          parameters: {
            'food_analysis_response': fbai.Schema.object(
              description: 'The food analysis response details to save',
              properties: {
                'meal_name': fbai.Schema.string(description: 'Name of the meal'),
                'analyzed_food_items': fbai.Schema.array(
                  description: 'List of individual food items analyzed',
                  items: fbai.Schema.object(
                    properties: {
                      'name': fbai.Schema.string(description: 'Name of the food item'),
                      'canonical_name': fbai.Schema.string(description: 'Canonical English name in snake_case'),
                      'quantity': fbai.Schema.object(
                        properties: {
                          'value': fbai.Schema.number(description: 'Value of the quantity'),
                          'unit': fbai.Schema.string(description: 'Unit of measurement, e.g. g'),
                        }
                      ),
                      'nutrients': fbai.Schema.array(
                        items: fbai.Schema.object(
                          properties: {
                            'name': fbai.Schema.string(description: 'Name of nutrient'),
                            'quantity': fbai.Schema.object(
                              properties: {
                                'value': fbai.Schema.number(description: 'Value'),
                                'unit': fbai.Schema.string(description: 'Unit'),
                              }
                            ),
                          }
                        )
                      ),
                    }
                  )
                ),
                'total_plate_nutrients': fbai.Schema.array(
                  items: fbai.Schema.object(
                    properties: {
                      'name': fbai.Schema.string(description: 'Name of nutrient'),
                      'quantity': fbai.Schema.object(
                        properties: {
                          'value': fbai.Schema.number(description: 'Value'),
                          'unit': fbai.Schema.string(description: 'Unit'),
                        }
                      ),
                    }
                  )
                ),
              }
            ),
            'source_of_intake': fbai.Schema.string(
              description: 'The source of the intake, e.g., "SD" for scanned description.',
            ),
            'created_at': fbai.Schema.string(
              description: 'The ISO-8601 consumed date and time (e.g. "2026-07-02T12:00:00"). Optional, defaults to now.',
            ),
          },
        ),
      ];

  static String humanLabel(String toolName, Map<String, dynamic> args) {
    switch (toolName) {
      case 'getUserProfile':
        return 'Fetching your profile...';
      case 'logMealViaDescription':
        final desc = args['description'] ?? 'meal';
        return 'Logging "$desc"...';
      case 'saveScannedFoodIntake':
        final mealName = args['food_analysis_response']?['meal_name'] ?? 'meal';
        return 'Saving "$mealName" to your intake...';
      default:
        return 'Processing...';
    }
  }
}
