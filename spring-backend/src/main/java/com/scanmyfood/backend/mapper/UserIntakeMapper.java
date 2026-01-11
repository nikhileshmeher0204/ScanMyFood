package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.DailyIntakeRecord;
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
            @Param("totalCarbohydrateValue") double totalCarbohydrateValue,
            @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("totalFatValue") double totalFatValue,
            @Param("totalFatUnit") String totalFatUnit,
            @Param("dietaryFiberValue") double dietaryFiberValue,
            @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValue") double totalSugarsValue,
            @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("sodiumValue") double sodiumValue,
            @Param("sodiumUnit") String sodiumUnit
    );

    Integer insertProductAnalysis(
            @Param("userId") String userId,
            @Param("productName") String productName,
            @Param("imageUrl") String imageUrl,
            @Param("energyValue") double energyValue,
            @Param("energyUnit") String energyUnit,
            @Param("proteinValue") double proteinValue,
            @Param("proteinUnit") String proteinUnit,
            @Param("totalCarbohydrateValue") double totalCarbohydrateValue,
            @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("totalFatValue") double totalFatValue,
            @Param("totalFatUnit") String totalFatUnit,
            @Param("saturatedFatValue") double saturatedFatValue,
            @Param("saturatedFatUnit") String saturatedFatUnit,
            @Param("transFatValue") double transFatValue,
            @Param("transFatUnit") String transFatUnit,
            @Param("dietaryFiberValue") double dietaryFiberValue,
            @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValue") double totalSugarsValue,
            @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("addedSugarsValue") double addedSugarsValue,
            @Param("addedSugarsUnit") String addedSugarsUnit,
            @Param("sodiumValue") double sodiumValue,
            @Param("sodiumUnit") String sodiumUnit,
            @Param("ironValue") double ironValue,
            @Param("ironUnit") String ironUnit,
            @Param("calciumValue") double calciumValue,
            @Param("calciumUnit") String calciumUnit,
            @Param("potassiumValue") double potassiumValue,
            @Param("potassiumUnit") String potassiumUnit
    );

    Integer insertFoodItem(
            @Param("itemName") String itemName,
            @Param("caloriesValuePer100g") double caloriesValuePer100g,
            @Param("caloriesUnit") String caloriesUnit,
            @Param("proteinValuePer100g") double proteinValuePer100g,
            @Param("proteinUnit") String proteinUnit,
            @Param("totalCarbohydrateValuePer100g") double totalCarbohydrateValuePer100g,
            @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("totalFatValuePer100g") double totalFatValuePer100g,
            @Param("totalFatUnit") String totalFatUnit,
            @Param("dietaryFiberValuePer100g") double dietaryFiberValuePer100g,
            @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValuePer100g") double totalSugarsValuePer100g,
            @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("sodiumValuePer100g") double sodiumValuePer100g,
            @Param("sodiumUnit") String sodiumUnit,
            @Param("addedBy") String addedBy
    );

    void insertFoodAnalysisItem(
            @Param("dailyIntakeId") Integer dailyIntakeId,
            @Param("foodItemId") Integer foodItemId,
            @Param("quantityValue") double quantityValue,
            @Param("quantityUnit") String quantityUnit
    );

    List<DailyIntakeRecord> fetchUserIntake(
            @Param("userId") String userId,
            @Param("date") LocalDate date
    );

    Integer insertProductLabel(
            @Param("productName") String productName,
            @Param("category") String category,
            @Param("totalQuantityValue") double totalQuantityValue,
            @Param("totalQuantityUnit") String totalQuantityUnit,
            @Param("servingSizeValue") double servingSizeValue,
            @Param("servingSizeUnit") String servingSizeUnit,
            @Param("energyValuePer100g") double energyValuePer100g,
            @Param("energyUnit") String energyUnit,
            @Param("proteinValuePer100g") double proteinValuePer100g,
            @Param("proteinUnit") String proteinUnit,
            @Param("totalCarbohydrateValuePer100g") double totalCarbohydrateValuePer100g,
            @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("totalFatValuePer100g") double totalFatValuePer100g,
            @Param("totalFatUnit") String totalFatUnit,
            @Param("saturatedFatValuePer100g") double saturatedFatValuePer100g,
            @Param("saturatedFatUnit") String saturatedFatUnit,
            @Param("transFatValuePer100g") double transFatValuePer100g,
            @Param("transFatUnit") String transFatUnit,
            @Param("dietaryFiberValuePer100g") double dietaryFiberValuePer100g,
            @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValuePer100g") double totalSugarsValuePer100g,
            @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("addedSugarsValuePer100g") double addedSugarsValuePer100g,
            @Param("addedSugarsUnit") String addedSugarsUnit,
            @Param("sodiumValuePer100g") double sodiumValuePer100g,
            @Param("sodiumUnit") String sodiumUnit,
            @Param("ironValuePer100g") double ironValuePer100g,
            @Param("ironUnit") String ironUnit,
            @Param("potassiumValuePer100g") double potassiumValuePer100g,
            @Param("potassiumUnit") String potassiumUnit,
            @Param("calciumValuePer100g") double calciumValuePer100g,
            @Param("calciumUnit") String calciumUnit,
            @Param("addedBy") String addedBy
    );

    void insertFoodAnalysisProduct(
            @Param("dailyIntakeId") Integer dailyIntakeId,
            @Param("productLabelId") Integer productLabelId,
            @Param("quantityValue") double quantityValue,
            @Param("quantityUnit") String quantityUnit
    );

    Integer insertProductPrimaryConcern(
            @Param("productLabelId") Integer productLabelId,
            @Param("issue") String issue,
            @Param("explanation") String explanation
    );

    void insertConcernRecommendation(
            @Param("concernId") Integer concernId,
            @Param("food") String food,
            @Param("quantity") String quantity,
            @Param("reasoning") String reasoning
    );


    void updateDailyIntakeImageUrl(
            @Param("dailyIntakeId") Integer dailyIntakeId,
            @Param("imageUrl") String imageUrl
    );

}
