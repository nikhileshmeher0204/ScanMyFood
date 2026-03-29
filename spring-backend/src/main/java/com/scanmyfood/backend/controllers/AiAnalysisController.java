package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.constants.ResponseCodeConstants;
import com.scanmyfood.backend.models.*;
import com.scanmyfood.backend.services.AiService;
import com.scanmyfood.backend.services.UserIntakeService;
import com.scanmyfood.backend.services.storage.FileStorageService;
import com.scanmyfood.backend.utils.ByteArrayMultipartFile;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Base64;

@Slf4j
@RestController
@RequestMapping("/api/ai")
public class AiAnalysisController {
    private final AiService aiService;
    private final UserIntakeService userIntakeService;
    private final FileStorageService fileStorageService;


    @Autowired
    public AiAnalysisController(AiService aiService, 
                                UserIntakeService userIntakeService, FileStorageService fileStorageService) {
        this.aiService = aiService;
        this.userIntakeService = userIntakeService;
        this.fileStorageService = fileStorageService;
    }

    @PostMapping(value = "/analyze/product", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ProductAnalysisResponse>> analyzeProductImages(
            @RequestParam("frontImage") MultipartFile frontImage,
            @RequestParam("labelImage") MultipartFile labelImage) {
        log.info("Analyzing product images");
        ProductAnalysisResponse analysis = aiService.analyzeProductImages(frontImage, labelImage);
        log.info("Product images analyzed successfully");
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.PRODUCT_ANALYZED, analysis));
    }

    @PostMapping(value = "/analyze/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<FoodAnalysisResponse>> analyzeFoodImage(
            @RequestParam("image") MultipartFile imageFile) {
        log.info("Analyzing food image");
        FoodAnalysisResponse analysis = aiService.analyzeFoodImage(imageFile);
        log.info("Food image analyzed successfully");
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.FOOD_ANALYZED, analysis));
    }

    @PostMapping("/analyze/description")
    public ResponseEntity<ApiResponse<FoodAnalysisResponse>> analyzeFoodDescription(
            @RequestBody IntakeDescriptionRequest request) {
        log.info("Analyzing food description");
        String description = request.getDescription();
        FoodAnalysisResponse analysis = aiService.analyzeFoodDescription(description);
        log.info("Food description analyzed successfully");
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.DESCRIPTION_ANALYZED, analysis));
    }

    @PostMapping("/generate/intake-description-image")
    public ResponseEntity<ApiResponse<ImageGenerationResponse>> generateFoodImage(
            @RequestBody IntakeDescriptionRequest request) throws Exception{
        log.info("Generating food image from description");
        
        try {
            byte[] imageBytes = aiService.generateFoodImage(request.getDescription());
            
            // Check if image was actually generated
            if (imageBytes == null || imageBytes.length == 0) {
                log.error("Image generation returned empty bytes");
                throw new Exception("Image generation returned empty bytes");
            }
               //Convert byte array to MultipartFile for storage
            String filename = "generated_" + System.currentTimeMillis() + ".png";
            MultipartFile imageFile = new ByteArrayMultipartFile(
                imageBytes,
                "generatedImage",
                filename,
                "image/png"
            );
            
            // Store the image and get the access URL
            String storedPath = fileStorageService.store(imageFile, "generated-images");
            String imageUrl = fileStorageService.getAccessUrl(storedPath);
            log.info("Generated image stored at: {}", imageUrl);
            
            // Update database with image URL
            userIntakeService.updateDailyIntakeImage(request.getDailyIntakeId(), imageUrl);
            
            // Encode image to base64 for API response
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            
            // Create response object
            ImageGenerationResponse imageResponse = new ImageGenerationResponse(
                base64Image,
                "image/png",
                    request.getDescription(),
                imageBytes.length
            );
            log.info("Food image generated successfully, size: {} bytes", imageBytes.length);
            return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.IMAGE_GENERATED, imageResponse));
        } catch (Exception exception) {
            log.error("Failed to generate food image", exception);
            throw new Exception("Image generation failed: " + exception.getMessage(), exception);
        }
    }
}
