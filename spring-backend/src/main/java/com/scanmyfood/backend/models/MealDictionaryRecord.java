package com.scanmyfood.backend.models;

import lombok.Data;
import java.time.LocalDateTime;

import java.util.List;

@Data
public class MealDictionaryRecord {
    private Integer id;
    private String canonicalMealName;
    private String displayMealName;
    private List<RecipeItem> recipeItems;

    private Double standardQuantityValue;
    private String standardQuantityUnit;

    private Double caloriesValue;
    private String caloriesUnit;

    private Double proteinValue;
    private String proteinUnit;

    private Double totalCarbohydrateValue;
    private String totalCarbohydrateUnit;

    private Double totalFatValue;
    private String totalFatUnit;

    private Double dietaryFiberValue;
    private String dietaryFiberUnit;

    private Double totalSugarsValue;
    private String totalSugarsUnit;

    private Double sodiumValue;
    private String sodiumUnit;

    private Boolean verifiedInd;
    private String createdByUserId;
    private LocalDateTime createdAt;
}
