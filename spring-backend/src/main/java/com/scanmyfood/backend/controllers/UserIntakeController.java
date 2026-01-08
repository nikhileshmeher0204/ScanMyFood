package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.SaveScannedFoodInput;
import com.scanmyfood.backend.models.SaveScannedLabelInput;
import com.scanmyfood.backend.models.UserIntakeOutput;
import com.scanmyfood.backend.services.UserIntakeService;
import com.scanmyfood.backend.services.storage.FileStorageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;


@Slf4j
@RestController
@RequestMapping("/api/user")
public class UserIntakeController {

    @Autowired
    UserIntakeService userIntakeService;

    @Autowired
    FileStorageService fileStorageService;

    @PostMapping("save/scannedFood")
    public ResponseEntity<ApiResponse> saveScannedFood(
            @RequestPart("foodImage") MultipartFile foodImage,
            @RequestPart("saveScannedFoodInput") SaveScannedFoodInput saveScannedFoodInput) {

        log.info("Saving scanned food intake");
        log.info("Food Image: {}", foodImage.getOriginalFilename());
        log.info("Food Analysis: {}", saveScannedFoodInput);

        try {
            String storedPath = fileStorageService.store(foodImage, "food-images");
            String accessUrl = fileStorageService.getAccessUrl(storedPath);

            userIntakeService.saveScannedFoodIntake(saveScannedFoodInput, accessUrl);
            log.info("Successfully saved intake");
            return ResponseEntity.ok(ApiResponse.success(null, "Scanned food intake saved successfully."));

        } catch (Exception e) {
            log.error("Error saving scanned food: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to save scanned food"));
        }
    }

    @PostMapping("save/scannedLabel")
    public ResponseEntity<ApiResponse> saveScannedLabel(
            @RequestPart("foodImage") MultipartFile foodImage,
            @RequestPart("saveScannedLabelInput") SaveScannedLabelInput saveScannedLabelInput) {

        log.info("Saving scanned label intake");
        log.info("Food Image: {}", foodImage.getOriginalFilename());
        log.info("Food Analysis: {}", saveScannedLabelInput);

        try {
            String storedPath = fileStorageService.store(foodImage, "food-images");
            String accessUrl = fileStorageService.getAccessUrl(storedPath);

            userIntakeService.saveScannedLabelIntake(saveScannedLabelInput, accessUrl);

            return ResponseEntity.ok(ApiResponse.success(null, "Scanned food intake saved successfully."));

        } catch (Exception e) {
            log.error("Error saving scanned food: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to save scanned food"));
        }
    }

    @GetMapping("/intake")
    public ResponseEntity<ApiResponse<UserIntakeOutput>> getDailyIntake(
            @RequestParam("userId") String userId,
            @RequestParam("date") LocalDate date
    ) throws Exception {
        log.info("Fetching daily intake for userId: {} on date: {}", userId, date);
        UserIntakeOutput dailyIntake = userIntakeService.getUserIntake(userId, date);
        if(dailyIntake.getFoodAnalysisResponse().isEmpty()){
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(ApiResponse.success(dailyIntake, "Daily intake fetched successfully."));

    }
}
