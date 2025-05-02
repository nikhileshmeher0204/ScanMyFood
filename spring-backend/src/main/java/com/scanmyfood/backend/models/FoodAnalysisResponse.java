package com.scanmyfood.backend.models;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class FoodAnalysisResponse {
    private String mealName;
    private List<FoodItem> analyzedFoodItems;
    private Map<String, Object> totalPlateNutrients;
}

