package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.DailyIntakeRecord;
import com.scanmyfood.backend.models.FoodItemRecord;
import com.scanmyfood.backend.models.RecipeItem;
import org.apache.ibatis.annotations.*;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface UserIntakeMapper {

    Integer insertFoodAnalysis(
            @Param("userId") String userId,
            @Param("intakeName") String intakeName,
            @Param("imageUrl") String imageUrl,
            @Param("sourceOfIntake") String sourceOfIntake,
            @Param("portion") double portion,
            @Param("createdBy") String createdBy,
            @Param("updatedBy") String updatedBy,
            @Param("createdTs") java.time.LocalDateTime createdTs,
            @Param("updatedTs") java.time.LocalDateTime updatedTs
    );

    Integer insertFoodItem(
            @Param("dailyIntakeId") Integer dailyIntakeId,
            @Param("itemName") String itemName,
            @Param("canonicalName") String canonicalName,
            @Param("quantityValue") double quantityValue,
            @Param("quantityUnit") String quantityUnit,
            @Param("portion") double portion,
            @Param("dietaryType") String dietaryType,
            @Param("createdTs") java.time.LocalDateTime createdTs
    );

    List<DailyIntakeRecord> fetchUserIntake(
            @Param("userId") String userId,
            @Param("date") LocalDate date
    );

    List<DailyIntakeRecord> fetchUserIntakeRange(
            @Param("userId") String userId,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    DailyIntakeRecord fetchIntakeById(
            @Param("userId") String userId,
            @Param("dailyIntakeId") Integer dailyIntakeId
    );

    List<FoodItemRecord> fetchFoodItemsByDailyIntakeId(
            @Param("dailyIntakeId") Integer dailyIntakeId,
            @Param("countryCode") String countryCode
    );

    FoodItemRecord findFoodItemByAlias(
            @Param("displayName") String displayName,
            @Param("countryCode") String countryCode
    );

    FoodItemRecord findFoodItemByCanonical(
            @Param("canonicalName") String canonicalName
    );

    void insertFoodItemAlias(
            @Param("canonicalName") String canonicalName,
            @Param("countryCode") String countryCode,
            @Param("displayName") String displayName
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

    Integer insertFoodMeal(
            @Param("mealName") String mealName,
            @Param("imageUrl") String imageUrl,
            @Param("quantityValue") Double quantityValue,
            @Param("quantityUnit") String quantityUnit,
            @Param("caloriesValue") Double caloriesValue, @Param("caloriesUnit") String caloriesUnit,
            @Param("energyValue") Double energyValue, @Param("energyUnit") String energyUnit,
            @Param("proteinValue") Double proteinValue, @Param("proteinUnit") String proteinUnit,
            @Param("cholesterolValue") Double cholesterolValue, @Param("cholesterolUnit") String cholesterolUnit,
            @Param("totalCarbohydrateValue") Double totalCarbohydrateValue, @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("dietaryFiberValue") Double dietaryFiberValue, @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValue") Double totalSugarsValue, @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("sugarValue") Double sugarValue, @Param("sugarUnit") String sugarUnit,
            @Param("addedSugarsValue") Double addedSugarsValue, @Param("addedSugarsUnit") String addedSugarsUnit,
            @Param("totalFatValue") Double totalFatValue, @Param("totalFatUnit") String totalFatUnit,
            @Param("saturatedFatValue") Double saturatedFatValue, @Param("saturatedFatUnit") String saturatedFatUnit,
            @Param("transFatValue") Double transFatValue, @Param("transFatUnit") String transFatUnit,
            @Param("sodiumValue") Double sodiumValue, @Param("sodiumUnit") String sodiumUnit,
            @Param("calciumValue") Double calciumValue, @Param("calciumUnit") String calciumUnit,
            @Param("ironValue") Double ironValue, @Param("ironUnit") String ironUnit,
            @Param("potassiumValue") Double potassiumValue, @Param("potassiumUnit") String potassiumUnit,
            @Param("magnesiumValue") Double magnesiumValue, @Param("magnesiumUnit") String magnesiumUnit,
            @Param("phosphorusValue") Double phosphorusValue, @Param("phosphorusUnit") String phosphorusUnit,
            @Param("zincValue") Double zincValue, @Param("zincUnit") String zincUnit,
            @Param("folateValue") Double folateValue, @Param("folateUnit") String folateUnit,
            @Param("vitaminDValue") Double vitaminDValue, @Param("vitaminDUnit") String vitaminDUnit,
            @Param("vitaminAValue") Double vitaminAValue, @Param("vitaminAUnit") String vitaminAUnit,
            @Param("vitaminCValue") Double vitaminCValue, @Param("vitaminCUnit") String vitaminCUnit,
            @Param("vitaminB6Value") Double vitaminB6Value, @Param("vitaminB6Unit") String vitaminB6Unit,
            @Param("vitaminB12Value") Double vitaminB12Value, @Param("vitaminB12Unit") String vitaminB12Unit,
            @Param("vitaminEValue") Double vitaminEValue, @Param("vitaminEUnit") String vitaminEUnit,
            @Param("vitaminKValue") Double vitaminKValue, @Param("vitaminKUnit") String vitaminKUnit
    );

    Integer insertFoodProduct(
            @Param("productLabelId") Integer productLabelId,
            @Param("quantityValue") Double quantityValue,
            @Param("quantityUnit") String quantityUnit,
            @Param("caloriesValue") Double caloriesValue, @Param("caloriesUnit") String caloriesUnit,
            @Param("energyValue") Double energyValue, @Param("energyUnit") String energyUnit,
            @Param("proteinValue") Double proteinValue, @Param("proteinUnit") String proteinUnit,
            @Param("cholesterolValue") Double cholesterolValue, @Param("cholesterolUnit") String cholesterolUnit,
            @Param("totalCarbohydrateValue") Double totalCarbohydrateValue, @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("dietaryFiberValue") Double dietaryFiberValue, @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValue") Double totalSugarsValue, @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("sugarValue") Double sugarValue, @Param("sugarUnit") String sugarUnit,
            @Param("addedSugarsValue") Double addedSugarsValue, @Param("addedSugarsUnit") String addedSugarsUnit,
            @Param("totalFatValue") Double totalFatValue, @Param("totalFatUnit") String totalFatUnit,
            @Param("saturatedFatValue") Double saturatedFatValue, @Param("saturatedFatUnit") String saturatedFatUnit,
            @Param("transFatValue") Double transFatValue, @Param("transFatUnit") String transFatUnit,
            @Param("sodiumValue") Double sodiumValue, @Param("sodiumUnit") String sodiumUnit,
            @Param("calciumValue") Double calciumValue, @Param("calciumUnit") String calciumUnit,
            @Param("ironValue") Double ironValue, @Param("ironUnit") String ironUnit,
            @Param("potassiumValue") Double potassiumValue, @Param("potassiumUnit") String potassiumUnit,
            @Param("magnesiumValue") Double magnesiumValue, @Param("magnesiumUnit") String magnesiumUnit,
            @Param("phosphorusValue") Double phosphorusValue, @Param("phosphorusUnit") String phosphorusUnit,
            @Param("zincValue") Double zincValue, @Param("zincUnit") String zincUnit,
            @Param("folateValue") Double folateValue, @Param("folateUnit") String folateUnit,
            @Param("vitaminDValue") Double vitaminDValue, @Param("vitaminDUnit") String vitaminDUnit,
            @Param("vitaminAValue") Double vitaminAValue, @Param("vitaminAUnit") String vitaminAUnit,
            @Param("vitaminCValue") Double vitaminCValue, @Param("vitaminCUnit") String vitaminCUnit,
            @Param("vitaminB6Value") Double vitaminB6Value, @Param("vitaminB6Unit") String vitaminB6Unit,
            @Param("vitaminB12Value") Double vitaminB12Value, @Param("vitaminB12Unit") String vitaminB12Unit,
            @Param("vitaminEValue") Double vitaminEValue, @Param("vitaminEUnit") String vitaminEUnit,
            @Param("vitaminKValue") Double vitaminKValue, @Param("vitaminKUnit") String vitaminKUnit
    );

    void updateFoodMealImageUrlByDailyIntakeId(
            @Param("dailyIntakeId") Integer dailyIntakeId,
            @Param("imageUrl") String imageUrl
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

    void insertOrUpdateFoodItemDictionary(
            @Param("canonicalName") String canonicalName,
            @Param("caloriesValuePer100g") double caloriesValuePer100g, @Param("caloriesUnit") String caloriesUnit,
            @Param("proteinValuePer100g") double proteinValuePer100g, @Param("proteinUnit") String proteinUnit,
            @Param("totalCarbohydrateValuePer100g") double totalCarbohydrateValuePer100g, @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("totalFatValuePer100g") double totalFatValuePer100g, @Param("totalFatUnit") String totalFatUnit,
            @Param("dietaryFiberValuePer100g") double dietaryFiberValuePer100g, @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValuePer100g") double totalSugarsValuePer100g, @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("sodiumValuePer100g") double sodiumValuePer100g, @Param("sodiumUnit") String sodiumUnit,
            @Param("ironValuePer100g") double ironValuePer100g, @Param("ironUnit") String ironUnit,
            @Param("dietaryType") String dietaryType,
            @Param("verifiedInd") Boolean verifiedInd
    );

    void insertOrUpdateMealDictionary(
            @Param("canonicalMealName") String canonicalMealName,
            @Param("displayMealName") String displayMealName,
            @Param("recipeItems") List<RecipeItem> recipeItems,
            @Param("standardQuantityValue") double standardQuantityValue,
            @Param("standardQuantityUnit") String standardQuantityUnit,
            @Param("caloriesValue") double caloriesValue, @Param("caloriesUnit") String caloriesUnit,
            @Param("proteinValue") double proteinValue, @Param("proteinUnit") String proteinUnit,
            @Param("totalCarbohydrateValue") double totalCarbohydrateValue, @Param("totalCarbohydrateUnit") String totalCarbohydrateUnit,
            @Param("totalFatValue") double totalFatValue, @Param("totalFatUnit") String totalFatUnit,
            @Param("dietaryFiberValue") double dietaryFiberValue, @Param("dietaryFiberUnit") String dietaryFiberUnit,
            @Param("totalSugarsValue") double totalSugarsValue, @Param("totalSugarsUnit") String totalSugarsUnit,
            @Param("sodiumValue") double sodiumValue, @Param("sodiumUnit") String sodiumUnit,
            @Param("verifiedInd") Boolean verifiedInd,
            @Param("createdByUserId") String createdByUserId
    );

    com.scanmyfood.backend.models.MealDictionaryRecord findMealInDictionary(
            @Param("canonicalMealName") String canonicalMealName
    );


}
