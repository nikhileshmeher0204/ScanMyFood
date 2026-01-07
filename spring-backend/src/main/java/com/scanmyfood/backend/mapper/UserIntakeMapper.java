package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.FoodAnalysisRecord;
import org.apache.ibatis.annotations.*;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface UserIntakeMapper {

    Integer insertFoodAnalysis(
            @Param("userId") String userId,
            @Param("mealName") String mealName,
            @Param("imageUrl") String imageUrl,
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

    void insertFoodAnalysisItem(
            @Param("foodAnalysisId") Integer foodAnalysisId,
            @Param("foodItemId") Integer foodItemId,
            @Param("quantityValue") double quantityValue,
            @Param("quantityUnit") String quantityUnit
    );

    List<FoodAnalysisRecord> fetchUserIntake(
            @Param("userId") String userId,
            @Param("date") LocalDate date
    );

}
