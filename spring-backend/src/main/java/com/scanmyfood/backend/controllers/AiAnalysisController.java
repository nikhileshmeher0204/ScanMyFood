package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.models.ProductAnalysisResponse;
import com.scanmyfood.backend.services.AiResponseProcessingService;
import com.scanmyfood.backend.services.AiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiAnalysisController {
    private final AiService aiService;
    private final AiResponseProcessingService aiResponseProcessingService;


    @Autowired
    public AiAnalysisController(AiService aiService, AiResponseProcessingService aiResponseProcessingService) {
        this.aiService = aiService;
        this.aiResponseProcessingService = aiResponseProcessingService;
    }

    @PostMapping(value = "/analyze/product", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ProductAnalysisResponse>> analyzeProductImages(
            @RequestParam("frontImage") MultipartFile frontImage,
            @RequestParam("labelImage") MultipartFile labelImage) {
        Map<String, Object> analysis = aiService.analyzeProductImages(frontImage, labelImage);
        ProductAnalysisResponse processedAnalysis = aiResponseProcessingService.processProductImagesResponse(analysis);
        return ResponseEntity.ok(ApiResponse.success(processedAnalysis));
    }

    @PostMapping(value = "/analyze/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<FoodAnalysisResponse>> analyzeFoodImage(
            @RequestParam("image") MultipartFile imageFile) {
        Map<String, Object> analysis = aiService.analyzeFoodImage(imageFile);
        FoodAnalysisResponse processedAnalysis = aiResponseProcessingService.processFoodImageResponse(analysis);
        return ResponseEntity.ok(ApiResponse.success(processedAnalysis));
    }

    @PostMapping("/analyze/description")
    public ResponseEntity<ApiResponse<FoodAnalysisResponse>> analyzeFoodDescription(
            @RequestBody Map<String, String> request) {
        String description = request.get("description");
        Map<String, Object> analysis = aiService.analyzeFoodDescription(description);
        FoodAnalysisResponse processedAnalysis = aiResponseProcessingService.processFoodDescriptionResponse(analysis);
        return ResponseEntity.ok(ApiResponse.success(processedAnalysis));
    }
}
