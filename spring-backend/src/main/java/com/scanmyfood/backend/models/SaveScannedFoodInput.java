package com.scanmyfood.backend.models;

import lombok.Data;

@Data
public class SaveScannedFoodInput {
    String userId;
    String sourceOfIntake;
    FoodAnalysisResponse foodAnalysisResponse;
}