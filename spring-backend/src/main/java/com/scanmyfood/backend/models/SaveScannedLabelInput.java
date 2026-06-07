package com.scanmyfood.backend.models;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class SaveScannedLabelInput {
    String userId;
    String sourceOfIntake;
    ProductAnalysisResponse productAnalysisResponse;
    LocalDateTime createdAt;
}
