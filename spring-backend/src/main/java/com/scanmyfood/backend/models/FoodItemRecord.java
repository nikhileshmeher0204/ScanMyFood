package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
public class FoodItemRecord {

    private Integer id;
    private String itemName;

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

    private String addedBy;
    private LocalDateTime createdAt;

    private Double quantityValue;
    private String quantityUnit;
}
