package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.models.ProductAnalysisResponse;

import java.util.Map;

public interface AiResponseProcessingService {

    ProductAnalysisResponse processProductImagesResponse(Map<String, Object> aiResponse);
    FoodAnalysisResponse processFoodImageResponse(Map<String, Object> aiResponse);
    FoodAnalysisResponse processFoodDescriptionResponse(Map<String, Object> aiResponse);

}
