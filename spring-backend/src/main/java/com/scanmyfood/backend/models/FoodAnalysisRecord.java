package com.scanmyfood.backend.models;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class FoodAnalysisRecord {
    private Integer id;
    private String userId;
    private String mealName;
    private String imageUrl;
    private Double caloriesValue;
    private String caloriesUnit;
    private Double proteinValue;
    private String proteinUnit;
    private Double carbohydratesValue;
    private String carbohydratesUnit;
    private Double fatValue;
    private String fatUnit;
    private Double fiberValue;
    private String fiberUnit;
    private Double sugarValue;
    private String sugarUnit;
    private Double sodiumValue;
    private String sodiumUnit;
    private Timestamp createdAt;
}