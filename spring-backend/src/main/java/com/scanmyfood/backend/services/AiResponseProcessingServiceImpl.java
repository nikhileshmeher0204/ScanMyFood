package com.scanmyfood.backend.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.models.FoodItem;
import com.scanmyfood.backend.models.ProductAnalysisResponse;

@Service
public class AiResponseProcessingServiceImpl implements AiResponseProcessingService{

    @Override
    public ProductAnalysisResponse processProductImagesResponse(Map<String, Object> aiResponse) {
        ProductAnalysisResponse response = new ProductAnalysisResponse();

        // Process product information
        Map<String, Object> productInfo = (Map<String, Object>) aiResponse.get("product");
        ProductAnalysisResponse.ProductInfo product = new ProductAnalysisResponse.ProductInfo();
        product.setName((String) productInfo.get("name"));
        product.setCategory((String) productInfo.get("category"));
        response.setProduct(product);

        // Process nutrition analysis
        Map<String, Object> nutritionAnalysisMap = (Map<String, Object>) aiResponse.get("nutrition_analysis");
        ProductAnalysisResponse.NutritionAnalysis nutritionAnalysis = new ProductAnalysisResponse.NutritionAnalysis();

        // Set serving size
        nutritionAnalysis.setServingSize((String) nutritionAnalysisMap.get("serving_size"));

        // Process nutrients
        List<Map<String, Object>> nutrientsMap = (List<Map<String, Object>>) nutritionAnalysisMap.get("nutrients");
        List<ProductAnalysisResponse.Nutrient> nutrients = new ArrayList<>();

        for (Map<String, Object> nutrientMap : nutrientsMap) {
            ProductAnalysisResponse.Nutrient nutrient = new ProductAnalysisResponse.Nutrient();
            nutrient.setName((String) nutrientMap.get("name"));
            nutrient.setQuantity((String) nutrientMap.get("quantity"));
            nutrient.setDailyValue((String) nutrientMap.get("daily_value"));
            nutrient.setDvStatus((String) nutrientMap.get("dv_status"));
            nutrient.setGoal((String) nutrientMap.get("goal"));
            nutrient.setHealthImpact((String) nutrientMap.get("health_impact"));
            nutrients.add(nutrient);
        }
        nutritionAnalysis.setNutrients(nutrients);

        // Process primary concerns
        List<Map<String, Object>> concernsMap = (List<Map<String, Object>>) nutritionAnalysisMap.get("primary_concerns");
        if (concernsMap != null) {
            List<ProductAnalysisResponse.PrimaryConcern> concerns = new ArrayList<>();

            for (Map<String, Object> concernMap : concernsMap) {
                ProductAnalysisResponse.PrimaryConcern concern = new ProductAnalysisResponse.PrimaryConcern();
                concern.setIssue((String) concernMap.get("issue"));
                concern.setExplanation((String) concernMap.get("explanation"));

                // Process recommendations
                List<Map<String, Object>> recommendationsMap = (List<Map<String, Object>>) concernMap.get("recommendations");
                if (recommendationsMap != null) {
                    List<ProductAnalysisResponse.Recommendation> recommendations = new ArrayList<>();

                    for (Map<String, Object> recMap : recommendationsMap) {
                        ProductAnalysisResponse.Recommendation recommendation = new ProductAnalysisResponse.Recommendation();
                        recommendation.setFood((String) recMap.get("food"));
                        recommendation.setQuantity((String) recMap.get("quantity"));
                        recommendation.setReasoning((String) recMap.get("reasoning"));
                        recommendations.add(recommendation);
                    }
                    concern.setRecommendations(recommendations);
                }
                concerns.add(concern);
            }
            nutritionAnalysis.setPrimaryConcerns(concerns);
        }

        response.setNutritionAnalysis(nutritionAnalysis);
        return response;
    }

    @Override
    public FoodAnalysisResponse processFoodImageResponse(Map<String, Object> aiResponse) {
        FoodAnalysisResponse response = new FoodAnalysisResponse();
        Map<String, Object> plateAnalysis = (Map<String, Object>)aiResponse.get("plate_analysis");

        response.setMealName((String)plateAnalysis.get("meal_name"));

        // Process food items
        List<FoodItem> foodItems = new ArrayList<>();
        List<Map<String, Object>> items = (List<Map<String, Object>>)plateAnalysis.get("items");

        for (Map<String, Object> item : items) {
            FoodItem foodItem = new FoodItem();
            foodItem.setName((String)item.get("food_name"));

            Map<String, Object> estimatedQuantity = (Map<String, Object>)item.get("estimated_quantity");
            FoodItem.Quantity quantity = new FoodItem.Quantity();
            quantity.setValue(((Number)estimatedQuantity.get("amount")).doubleValue());
            quantity.setUnit((String)estimatedQuantity.get("unit"));
            foodItem.setQuantity(quantity);

            // Process nutrients_per_100g with Quantity objects
            Map<String, Object> nutrientsMap = (Map<String, Object>)item.get("nutrients_per_100g");
            Map<String, FoodItem.Quantity> nutrients = new HashMap<>();

            nutrientsMap.forEach((key, value) -> {
                FoodItem.Quantity nutrientQuantity = new FoodItem.Quantity();
                if (value instanceof Number) {
                    nutrientQuantity.setValue(((Number) value).doubleValue());
                    nutrientQuantity.setUnit(getNutrientUnit(key)); // Helper method for units
                } else if (value instanceof Map) {
                    Map<String, Object> valueMap = (Map<String, Object>) value;
                    nutrientQuantity.setValue(((Number) valueMap.get("value")).doubleValue());
                    nutrientQuantity.setUnit((String) valueMap.get("unit"));
                }
                nutrients.put(key, nutrientQuantity);
            });

            foodItem.setNutrientsPer100g(nutrients);
            foodItems.add(foodItem);
        }

        response.setAnalyzedFoodItems(foodItems);

        // Set total nutrients
        response.setTotalPlateNutrients((Map<String, FoodAnalysisResponse.Quantity>)plateAnalysis.get("total_plate_nutrients"));

        return response;
    }


    @Override
    public FoodAnalysisResponse processFoodDescriptionResponse(Map<String, Object> aiResponse) {
        FoodAnalysisResponse response = new FoodAnalysisResponse();
        Map<String, Object> plateAnalysis = (Map<String, Object>)aiResponse.get("meal_analysis");

        response.setMealName((String)plateAnalysis.get("meal_name"));

        // Process food items
        List<FoodItem> foodItems = new ArrayList<>();
        List<Map<String, Object>> items = (List<Map<String, Object>>)plateAnalysis.get("items");

        for (Map<String, Object> item : items) {
            FoodItem foodItem = new FoodItem();
            foodItem.setName((String)item.get("food_name"));

            Map<String, Object> estimatedQuantity = (Map<String, Object>)item.get("estimated_quantity");
            FoodItem.Quantity quantity = new FoodItem.Quantity();
            quantity.setValue(((Number)estimatedQuantity.get("amount")).doubleValue());
            quantity.setUnit((String)estimatedQuantity.get("unit"));
            foodItem.setQuantity(quantity);

            // Process nutrients_per_100g with Quantity objects
            Map<String, Object> nutrientsMap = (Map<String, Object>)item.get("nutrients_per_100g");
            Map<String, FoodItem.Quantity> nutrients = new HashMap<>();

            nutrientsMap.forEach((key, value) -> {
                FoodItem.Quantity nutrientQuantity = new FoodItem.Quantity();
                if (value instanceof Number) {
                    nutrientQuantity.setValue(((Number) value).doubleValue());
                    nutrientQuantity.setUnit(getNutrientUnit(key)); // Helper method for units
                } else if (value instanceof Map) {
                    Map<String, Object> valueMap = (Map<String, Object>) value;
                    nutrientQuantity.setValue(((Number) valueMap.get("value")).doubleValue());
                    nutrientQuantity.setUnit((String) valueMap.get("unit"));
                }
                nutrients.put(key, nutrientQuantity);
            });

            foodItem.setNutrientsPer100g(nutrients);
            foodItems.add(foodItem);
        }

        response.setAnalyzedFoodItems(foodItems);

        // Set total nutrients
        response.setTotalPlateNutrients((Map<String, FoodAnalysisResponse.Quantity>)plateAnalysis.get("total_nutrients"));

        return response;
    }

    private String getNutrientUnit(String nutrient) {
        Map<String, String> units = Map.of(
                "calories", "kcal",
                "protein", "g",
                "carbohydrates", "g",
                "fat", "g",
                "fiber", "g",
                "sugar", "g",
                "sodium", "mg"
        );
        return units.getOrDefault(nutrient.toLowerCase(), "g");
    }
}
