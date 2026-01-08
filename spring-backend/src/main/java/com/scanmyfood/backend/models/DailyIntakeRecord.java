package com.scanmyfood.backend.models;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class DailyIntakeRecord {
    private Integer id;
    private String userId;
    private String mealName;
    private String mealDescriptionName;
    private String productName;
    private String imageUrl;
    
    private Double caloriesValue = 0.0;
    private String caloriesUnit = "kcal";
    private Double energyValue = 0.0;
    private String energyUnit = "kcal";
    private Double proteinValue = 0.0;
    private String proteinUnit = "g";
    private Double cholesterolValue = 0.0;
    private String cholesterolUnit = "mg";
    private Double totalCarbohydrateValue = 0.0;
    private String totalCarbohydrateUnit = "g";
    private Double dietaryFiberValue = 0.0;
    private String dietaryFiberUnit = "g";
    private Double totalSugarsValue = 0.0;
    private String totalSugarsUnit = "g";
    private Double addedSugarsValue = 0.0;
    private String addedSugarsUnit = "g";
    private Double totalFatValue = 0.0;
    private String totalFatUnit = "g";
    private Double saturatedFatValue = 0.0;
    private String saturatedFatUnit = "g";
    private Double transFatValue = 0.0;
    private String transFatUnit = "g";
    private Double sodiumValue = 0.0;
    private String sodiumUnit = "mg";
    private Double calciumValue = 0.0;
    private String calciumUnit = "mg";
    private Double ironValue = 0.0;
    private String ironUnit = "mg";
    private Double potassiumValue = 0.0;
    private String potassiumUnit = "mg";
    private Double magnesiumValue = 0.0;
    private String magnesiumUnit = "mg";
    private Double phosphorusValue = 0.0;
    private String phosphorusUnit = "mg";
    private Double zincValue = 0.0;
    private String zincUnit = "mg";
    private Double folateValue = 0.0;
    private String folateUnit = "mcg";
    private Double vitaminDValue = 0.0;
    private String vitaminDUnit = "mcg";
    private Double vitaminAValue = 0.0;
    private String vitaminAUnit = "mcg";
    private Double vitaminCValue = 0.0;
    private String vitaminCUnit = "mg";
    private Double vitaminB6Value = 0.0;
    private String vitaminB6Unit = "mg";
    private Double vitaminB12Value = 0.0;
    private String vitaminB12Unit = "mcg";
    private Double vitaminEValue = 0.0;
    private String vitaminEUnit = "mg";
    private Double vitaminKValue = 0.0;
    private String vitaminKUnit = "mcg";
    private Timestamp createdAt;
}