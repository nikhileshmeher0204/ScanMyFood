package com.scanmyfood.backend.models;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class SaveScannedFoodInput {
    String userId;
    String sourceOfIntake;
    FoodAnalysisResponse foodAnalysisResponse;
    LocalDateTime createdAt;
}