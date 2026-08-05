package com.scanmyfood.backend.models;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FoodItemDictionaryRecord {
    private Integer id;
    private String canonicalName;

    private Double caloriesValuePer100g;
    private String caloriesUnit;

    private Double proteinValuePer100g;
    private String proteinUnit;

    private Double totalCarbohydrateValuePer100g;
    private String totalCarbohydrateUnit;

    private Double totalFatValuePer100g;
    private String totalFatUnit;

    private Double dietaryFiberValuePer100g;
    private String dietaryFiberUnit;

    private Double totalSugarsValuePer100g;
    private String totalSugarsUnit;

    private Double sodiumValuePer100g;
    private String sodiumUnit;

    private Double ironValuePer100g;
    private String ironUnit;

    private Boolean verifiedInd;
    private LocalDateTime createdAt;
}
