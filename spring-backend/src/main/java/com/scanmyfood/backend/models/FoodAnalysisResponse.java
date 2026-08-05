package com.scanmyfood.backend.models;

import lombok.Data;

import java.util.List;

@Data
public class FoodAnalysisResponse {
    private String mealName;
    private double portion = 1.0;
    private List<FoodItem> analyzedFoodItems;
    private List<FoodNutrient> totalPlateNutrients;
}