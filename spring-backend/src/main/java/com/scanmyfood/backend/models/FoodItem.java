package com.scanmyfood.backend.models;


import lombok.Data;
import java.util.Map;
import java.util.HashMap;

@Data
public class FoodItem {
    private String name;
    private double quantity;
    private String unit;
    private Map<String, Object> nutrientsPer100g;

    public Map<String, Double> calculateTotalNutrients() {
        double factor = quantity / 100.0;
        Map<String, Double> totalNutrients = new HashMap<>();

        totalNutrients.put("calories", ((Number)nutrientsPer100g.get("calories")).doubleValue() * factor);
        totalNutrients.put("protein", ((Number)nutrientsPer100g.get("protein")).doubleValue() * factor);
        totalNutrients.put("carbohydrates", ((Number)nutrientsPer100g.get("carbohydrates")).doubleValue() * factor);
        totalNutrients.put("fat", ((Number)nutrientsPer100g.get("fat")).doubleValue() * factor);
        totalNutrients.put("fiber", ((Number)nutrientsPer100g.get("fiber")).doubleValue() * factor);

        return totalNutrients;
    }
}
