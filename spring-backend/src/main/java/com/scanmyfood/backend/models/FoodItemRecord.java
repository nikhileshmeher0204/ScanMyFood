package com.scanmyfood.backend.models;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class FoodItemRecord {

    private Integer id;
    private String itemName;
    private String canonicalName;

    private Double caloriesValuePer100g;
    private String caloriesUnit;

    private Double proteinValuePer100g;
    private String proteinUnit;

    private Double totalCarbohydrateValuePer100g;
    private String totalCarbohydrateUnit;

    private Double dietaryFiberValuePer100g;
    private String dietaryFiberUnit;

    private Double totalSugarsValuePer100g;
    private String totalSugarsUnit;

    private Double totalFatValuePer100g;
    private String totalFatUnit;

    private Double sodiumValuePer100g;
    private String sodiumUnit;

    private Double ironValuePer100g;
    private String ironUnit;

    private Double quantityValue;
    private String quantityUnit;
    private Integer dailyIntakeId;
    private Double portion = 1.0;
    private LocalDateTime createdTs;
}
