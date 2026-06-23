package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.models.ProductAnalysisResponse;
import org.springframework.web.multipart.MultipartFile;

public interface AiService {
    ProductAnalysisResponse analyzeProductImages(MultipartFile frontImage, MultipartFile labelImage, String userId);
    FoodAnalysisResponse analyzeFoodImage(MultipartFile imageFile, String description, String userId);
    FoodAnalysisResponse analyzeFoodDescription(String description, String userId);
    byte[] generateFoodImage(String foodDescription);
}