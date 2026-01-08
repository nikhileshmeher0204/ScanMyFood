package com.scanmyfood.backend.models;

import lombok.Data;

@Data
public class SaveScannedLabelInput {
    String userId;
    ProductAnalysisResponse productAnalysisResponse;
}
