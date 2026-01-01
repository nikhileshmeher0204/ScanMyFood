package com.scanmyfood.backend.mapper;

public interface UserIntakeMapper {
    public void saveIntake(String userId, String mealName, String foodItems, String totalNutrientsJson);
}
