class ProductAnalysisResponse {
  final ProductInfo product;
  final NutritionAnalysis nutritionAnalysis;

  ProductAnalysisResponse({
    required this.product,
    required this.nutritionAnalysis,
  });

  factory ProductAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return ProductAnalysisResponse(
      product: ProductInfo.fromJson(json['product']),
      nutritionAnalysis: NutritionAnalysis.fromJson(json['nutritionAnalysis']),
    );
  }
}

class ProductInfo {
  final String name;
  final String category;

  ProductInfo({required this.name, required this.category});

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      name: json['name'] ?? 'Unknown Product',
      category: json['category'] ?? 'Unknown Category',
    );
  }
}

class NutritionAnalysis {
  final String servingSize;
  final List<Nutrient> nutrients;
  final List<PrimaryConcern> primaryConcerns;

  NutritionAnalysis({
    required this.servingSize,
    required this.nutrients,
    required this.primaryConcerns,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      servingSize: json['servingSize'] ?? 'Unknown',
      nutrients: (json['nutrients'] as List?)
              ?.map((n) => Nutrient.fromJson(n))
              .toList() ??
          [],
      primaryConcerns: (json['primaryConcerns'] as List?)
              ?.map((c) => PrimaryConcern.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class Nutrient {
  final String name;
  final String quantity;
  final String dailyValue;
  final String status;
  final String healthImpact;

  Nutrient({
    required this.name,
    required this.quantity,
    required this.dailyValue,
    required this.status,
    required this.healthImpact,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) {
    return Nutrient(
      name: json['name'] ?? 'Unknown',
      quantity: json['quantity'] ?? '0',
      dailyValue: json['dailyValue'] ?? '0%',
      status: json['status'] ?? 'Moderate',
      healthImpact: json['healthImpact'] ?? 'Moderate',
    );
  }
}

class PrimaryConcern {
  final String issue;
  final String explanation;
  final List<Recommendation> recommendations;

  PrimaryConcern({
    required this.issue,
    required this.explanation,
    required this.recommendations,
  });

  factory PrimaryConcern.fromJson(Map<String, dynamic> json) {
    return PrimaryConcern(
      issue: json['issue'] ?? 'Unknown',
      explanation: json['explanation'] ?? '',
      recommendations: (json['recommendations'] as List?)
              ?.map((r) => Recommendation.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class Recommendation {
  final String food;
  final String quantity;
  final String reasoning;

  Recommendation({
    required this.food,
    required this.quantity,
    required this.reasoning,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      food: json['food'] ?? 'Unknown',
      quantity: json['quantity'] ?? '',
      reasoning: json['reasoning'] ?? '',
    );
  }
}
