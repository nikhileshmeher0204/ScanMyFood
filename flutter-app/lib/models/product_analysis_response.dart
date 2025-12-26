import 'package:read_the_label/models/quantity.dart';

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
      nutritionAnalysis: NutritionAnalysis.fromJson(json['nutrition_analysis']),
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
  final Quantity totalQuantity;
  final Quantity servingSize;
  final List<Nutrient> nutrients;
  final List<PrimaryConcern> primaryConcerns;

  NutritionAnalysis({
    required this.totalQuantity,
    required this.servingSize,
    required this.nutrients,
    required this.primaryConcerns,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      totalQuantity: json['total_quantity'] != null
          ? Quantity.fromJson(json['total_quantity'])
          : Quantity(value: 0, unit: 'g'),
      servingSize: json['serving_size'] != null
          ? Quantity.fromJson(json['serving_size'])
          : Quantity(value: 0, unit: 'g'),
      nutrients: (json['nutrients'] as List?)
              ?.map((n) => Nutrient.fromJson(n))
              .toList() ??
          [],
      primaryConcerns: (json['primary_concerns'] as List?)
              ?.map((c) => PrimaryConcern.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class Nutrient {
  final String name;
  final Quantity quantity;
  final String dailyValue;
  final String dvStatus;
  final String goal;
  final String healthImpact;

  Nutrient({
    required this.name,
    required this.quantity,
    required this.dailyValue,
    required this.dvStatus,
    required this.goal,
    required this.healthImpact,
  });

  factory Nutrient.fromJson(Map<String, dynamic> json) {
    return Nutrient(
      name: json['name'] ?? 'Unknown',
      quantity: json['quantity'] != null
          ? Quantity.fromJson(json['quantity'])
          : Quantity(value: 0, unit: 'g'),
      dailyValue: json['daily_value'] ?? '0',
      dvStatus: json['dv_status'] ?? '',
      goal: json['goal'] ?? 'At least',
      healthImpact: json['health_impact'] ?? 'Moderate',
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
