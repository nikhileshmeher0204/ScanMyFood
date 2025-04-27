class NutritionAnalysis {
  final String productName;
  final String category;
  final String servingSize;
  final List<NutrientInfo> nutrients;
  final List<NutritionalConcern> concerns;

  NutritionAnalysis({
    required this.productName,
    required this.category,
    required this.servingSize,
    required this.nutrients,
    required this.concerns,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      productName: json['product']['name'] ?? '',
      category: json['product']['category'] ?? '',
      servingSize: json['nutrition_analysis']['serving_size'] ?? '',
      nutrients: (json['nutrition_analysis']['nutrients'] as List?)
              ?.map((nutrient) => NutrientInfo(
                    name: nutrient['name'] ?? '',
                    quantity: nutrient['quantity'] ?? '',
                    dailyValue: double.tryParse(
                            nutrient['daily_value']?.toString() ?? '0') ??
                        0.0,
                    status: nutrient['status'] ?? '',
                    healthImpact: nutrient['health_impact'] ?? '',
                  ))
              .toList() ??
          [],
      concerns: (json['nutrition_analysis']['primary_concerns'] as List?)
              ?.map((concern) => NutritionalConcern(
                    issue: concern['issue'] ?? '',
                    explanation: concern['explanation'] ?? '',
                    recommendations: (concern['recommendations'] as List?)
                            ?.map((rec) => FoodRecommendation(
                                  food: rec['food'] ?? '',
                                  quantity: rec['quantity'] ?? '',
                                  reasoning: rec['reasoning'] ?? '',
                                ))
                            .toList() ??
                        [],
                  ))
              .toList() ??
          [],
    );
  }
}

class NutrientInfo {
  final String name;
  final String quantity;
  final double dailyValue;
  final String status;
  final String healthImpact;

  NutrientInfo({
    required this.name,
    required this.quantity,
    required this.dailyValue,
    required this.status,
    required this.healthImpact,
  });
}

class NutritionalConcern {
  final String issue;
  final String explanation;
  final List<FoodRecommendation> recommendations;

  NutritionalConcern({
    required this.issue,
    required this.explanation,
    required this.recommendations,
  });
}

class FoodRecommendation {
  final String food;
  final String quantity;
  final String reasoning;

  FoodRecommendation({
    required this.food,
    required this.quantity,
    required this.reasoning,
  });
}
