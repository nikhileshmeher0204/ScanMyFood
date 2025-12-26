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
        response.setProduct(mapToProductInfo((Map<String, Object>) aiResponse.get("product")));

        Map<String, Object> nutritionAnalysisMap = (Map<String, Object>) aiResponse.get("nutrition_analysis");
        ProductAnalysisResponse.NutritionAnalysis nutritionAnalysis = new ProductAnalysisResponse.NutritionAnalysis();
        nutritionAnalysis.setTotalQuantity(mapToQuantity(nutritionAnalysisMap.get("total_quantity")));
        nutritionAnalysis.setServingSize(mapToQuantity(nutritionAnalysisMap.get("serving_size")));
        nutritionAnalysis.setNutrients(mapToNutrients((List<Map<String, Object>>) nutritionAnalysisMap.get("nutrients")));
        nutritionAnalysis.setPrimaryConcerns(mapToPrimaryConcerns((List<Map<String, Object>>) nutritionAnalysisMap.get("primary_concerns")));
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
    private ProductAnalysisResponse.ProductInfo mapToProductInfo(Map<String, Object> map) {
        if (map == null) return null;
        ProductAnalysisResponse.ProductInfo info = new ProductAnalysisResponse.ProductInfo();
        info.setName((String) map.get("name"));
        info.setCategory((String) map.get("category"));
        return info;
    }

    private ProductAnalysisResponse.Quantity mapToQuantity(Object obj) {
        if (obj instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) obj;
            ProductAnalysisResponse.Quantity quantity = new ProductAnalysisResponse.Quantity();
            quantity.setValue(((Number) map.get("value")).doubleValue());
            quantity.setUnit((String) map.get("unit"));
            return quantity;
        }
        return null;
    }

    private List<ProductAnalysisResponse.Nutrient> mapToNutrients(List<Map<String, Object>> list) {
        if (list == null) return null;
        List<ProductAnalysisResponse.Nutrient> nutrients = new ArrayList<>();
        for (Map<String, Object> map : list) {
            ProductAnalysisResponse.Nutrient nutrient = new ProductAnalysisResponse.Nutrient();
            nutrient.setName((String) map.get("name"));
            nutrient.setQuantity((ProductAnalysisResponse.Quantity) mapToQuantity(map.get("quantity")));
            nutrient.setDailyValue((String) map.get("daily_value"));
            nutrient.setDvStatus((String) map.get("dv_status"));
            nutrient.setGoal((String) map.get("goal"));
            nutrient.setHealthImpact((String) map.get("health_impact"));
            nutrients.add(nutrient);
        }
        return nutrients;
    }

    private List<ProductAnalysisResponse.PrimaryConcern> mapToPrimaryConcerns(List<Map<String, Object>> list) {
        if (list == null) return null;
        List<ProductAnalysisResponse.PrimaryConcern> concerns = new ArrayList<>();
        for (Map<String, Object> map : list) {
            ProductAnalysisResponse.PrimaryConcern concern = new ProductAnalysisResponse.PrimaryConcern();
            concern.setIssue((String) map.get("issue"));
            concern.setExplanation((String) map.get("explanation"));
            concern.setRecommendations(mapToRecommendations((List<Map<String, Object>>) map.get("recommendations")));
            concerns.add(concern);
        }
        return concerns;
    }

    private List<ProductAnalysisResponse.Recommendation> mapToRecommendations(List<Map<String, Object>> list) {
        if (list == null) return null;
        List<ProductAnalysisResponse.Recommendation> recommendations = new ArrayList<>();
        for (Map<String, Object> map : list) {
            ProductAnalysisResponse.Recommendation rec = new ProductAnalysisResponse.Recommendation();
            rec.setFood((String) map.get("food"));
            rec.setQuantity((String) map.get("quantity"));
            rec.setReasoning((String) map.get("reasoning"));
            recommendations.add(rec);
        }
        return recommendations;
    }
}
