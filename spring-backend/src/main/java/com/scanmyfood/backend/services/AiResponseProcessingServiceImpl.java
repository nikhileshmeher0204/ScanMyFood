package com.scanmyfood.backend.services;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.scanmyfood.backend.models.*;
import org.springframework.stereotype.Service;

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
            Quantity quantity = new Quantity();
            quantity.setValue(((Number)estimatedQuantity.get("amount")).doubleValue());
            quantity.setUnit((String)estimatedQuantity.get("unit"));
            foodItem.setQuantity(quantity);

            // Process nutrients_in_mentioned_quantity
            Map<String, Object> nutrientsMap = (Map<String, Object>) item.get("nutrients_in_estimated_quantity");
            List<FoodNutrient> nutrients = new ArrayList<>();

            if (nutrientsMap != null) {
                for (Map.Entry<String, Object> entry : nutrientsMap.entrySet()) {
                    String nutrientName = entry.getKey();
                    Map<String, Object> quantityMap = (Map<String, Object>) entry.getValue();

                    FoodNutrient nutrient = new FoodNutrient();
                    nutrient.setName(nutrientName);
                    nutrient.setQuantity(mapToQuantity(quantityMap));
                    nutrients.add(nutrient);
                }
            }
            foodItem.setNutrients(nutrients);

            foodItems.add(foodItem);
        }

        response.setAnalyzedFoodItems(foodItems);

        Map<String, Object> totalNutrientsMap = (Map<String, Object>) plateAnalysis.get("total_plate_nutrients");
        List<FoodNutrient> totalPlateNutrients = new ArrayList<>();

        if (totalNutrientsMap != null) {
            for (Map.Entry<String, Object> entry : totalNutrientsMap.entrySet()) {
                String nutrientName = entry.getKey();
                Map<String, Object> quantityMap = (Map<String, Object>) entry.getValue();

                FoodNutrient nutrient = new FoodNutrient();
                nutrient.setName(nutrientName);
                nutrient.setQuantity(mapToQuantity(quantityMap));
                totalPlateNutrients.add(nutrient);
            }
        }

        response.setTotalPlateNutrients(totalPlateNutrients);


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

            Map<String, Object> estimatedQuantity = (Map<String, Object>)item.get("nutrients_in_estimated_quantity");
            Quantity quantity = new Quantity();
            quantity.setValue(((Number)estimatedQuantity.get("amount")).doubleValue());
            quantity.setUnit((String)estimatedQuantity.get("unit"));
            foodItem.setQuantity(quantity);

            foodItems.add(foodItem);
        }

        response.setAnalyzedFoodItems(foodItems);

        // Set total nutrients
        Map<String, Object> totalNutrientsMap = (Map<String, Object>) plateAnalysis.get("total_plate_nutrients");
        List<FoodNutrient> totalPlateNutrients = new ArrayList<>();

        if (totalNutrientsMap != null) {
            for (Map.Entry<String, Object> entry : totalNutrientsMap.entrySet()) {
                String nutrientName = entry.getKey();
                Map<String, Object> quantityMap = (Map<String, Object>) entry.getValue();

                FoodNutrient nutrient = new FoodNutrient();
                nutrient.setName(nutrientName);
                nutrient.setQuantity(mapToQuantity(quantityMap));
                totalPlateNutrients.add(nutrient);
            }
        }

        response.setTotalPlateNutrients(totalPlateNutrients);


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

    private Quantity mapToQuantity(Object obj) {
        if (obj instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) obj;
            Quantity quantity = new Quantity();
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
            nutrient.setQuantity((Quantity) mapToQuantity(map.get("quantity")));
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
