package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.FoodItem;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserIntakeMapper {

    @Insert("INSERT INTO food_analysis (" +
            "user_id, meal_name, " +
            "calories_value, calories_unit, " +
            "protein_value, protein_unit, " +
            "carbohydrates_value, carbohydrates_unit, " +
            "fat_value, fat_unit, " +
            "fiber_value, fiber_unit, " +
            "sugar_value, sugar_unit, " +
            "sodium_value, sodium_unit" +
            ") VALUES (" +
            "#{userId}, #{mealName}, " +
            "#{caloriesValue}, #{caloriesUnit}, " +
            "#{proteinValue}, #{proteinUnit}, " +
            "#{carbohydratesValue}, #{carbohydratesUnit}, " +
            "#{fatValue}, #{fatUnit}, " +
            "#{fiberValue}, #{fiberUnit}, " +
            "#{sugarValue}, #{sugarUnit}, " +
            "#{sodiumValue}, #{sodiumUnit}" +
            ") RETURNING id")
    Integer insertFoodAnalysis(
            @Param("userId") String userId,
            @Param("mealName") String mealName,
            @Param("caloriesValue") double caloriesValue,
            @Param("caloriesUnit") String caloriesUnit,
            @Param("proteinValue") double proteinValue,
            @Param("proteinUnit") String proteinUnit,
            @Param("carbohydratesValue") double carbohydratesValue,
            @Param("carbohydratesUnit") String carbohydratesUnit,
            @Param("fatValue") double fatValue,
            @Param("fatUnit") String fatUnit,
            @Param("fiberValue") double fiberValue,
            @Param("fiberUnit") String fiberUnit,
            @Param("sugarValue") double sugarValue,
            @Param("sugarUnit") String sugarUnit,
            @Param("sodiumValue") double sodiumValue,
            @Param("sodiumUnit") String sodiumUnit
    );

    @Insert("INSERT INTO food_item (" +
            "item_name, " +
            "calories_value_per_100g, calories_unit, " +
            "protein_value_per_100g, protein_unit, " +
            "carbohydrates_value_per_100g, carbohydrates_unit, " +
            "fat_value_per_100g, fat_unit, " +
            "fiber_value_per_100g, fiber_unit, " +
            "sugar_value_per_100g, sugar_unit, " +
            "sodium_value_per_100g, sodium_unit, " +
            "added_by" +
            ") VALUES (" +
            "#{itemName}, " +
            "#{caloriesValuePer100g}, #{caloriesUnit}, " +
            "#{proteinValuePer100g}, #{proteinUnit}, " +
            "#{carbohydratesValuePer100g}, #{carbohydratesUnit}, " +
            "#{fatValuePer100g}, #{fatUnit}, " +
            "#{fiberValuePer100g}, #{fiberUnit}, " +
            "#{sugarValuePer100g}, #{sugarUnit}, " +
            "#{sodiumValuePer100g}, #{sodiumUnit}, " +
            "#{addedBy}" +
            ") RETURNING id")
    Integer insertFoodItem(
            @Param("itemName") String itemName,
            @Param("caloriesValuePer100g") double caloriesValuePer100g,
            @Param("caloriesUnit") String caloriesUnit,
            @Param("proteinValuePer100g") double proteinValuePer100g,
            @Param("proteinUnit") String proteinUnit,
            @Param("carbohydratesValuePer100g") double carbohydratesValuePer100g,
            @Param("carbohydratesUnit") String carbohydratesUnit,
            @Param("fatValuePer100g") double fatValuePer100g,
            @Param("fatUnit") String fatUnit,
            @Param("fiberValuePer100g") double fiberValuePer100g,
            @Param("fiberUnit") String fiberUnit,
            @Param("sugarValuePer100g") double sugarValuePer100g,
            @Param("sugarUnit") String sugarUnit,
            @Param("sodiumValuePer100g") double sodiumValuePer100g,
            @Param("sodiumUnit") String sodiumUnit,
            @Param("addedBy") String addedBy
    );

    @Insert("INSERT INTO food_analysis_item (" +
            "food_analysis_id, " +
            "food_item_id, " +
            "quantity_value, " +
            "quantity_unit" +
            ") VALUES (" +
            "#{foodAnalysisId}, " +
            "#{foodItemId}, " +
            "#{quantityValue}, " +
            "#{quantityUnit}" +
            ")")
    void insertFoodAnalysisItem(
            @Param("foodAnalysisId") Integer foodAnalysisId,
            @Param("foodItemId") Integer foodItemId,
            @Param("quantityValue") double quantityValue,
            @Param("quantityUnit") String quantityUnit
    );

}
