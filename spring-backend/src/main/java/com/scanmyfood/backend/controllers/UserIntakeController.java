package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.constants.ResponseCodeConstants;
import com.scanmyfood.backend.models.*;
import com.scanmyfood.backend.services.UserIntakeService;
import com.scanmyfood.backend.services.storage.FileStorageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;

import static com.scanmyfood.backend.constants.ResponseCodeConstants.ERROR;


@Slf4j
@RestController
@RequestMapping("/api/users/intake")
public class UserIntakeController {

    @Autowired
    UserIntakeService userIntakeService;

    @Autowired
    FileStorageService fileStorageService;

    @PostMapping("/scanned-food")
    public ResponseEntity<ApiResponse<SaveIntakeOutput>> saveScannedFood(
            @RequestPart(value = "foodImage", required = false) MultipartFile foodImage,
            @RequestPart("saveScannedFoodInput") SaveScannedFoodInput saveScannedFoodInput) {

        log.info("Saving scanned food intake");
        log.info("Food Analysis: {}", saveScannedFoodInput);

        try {
            SaveIntakeOutput saveIntakeOutput = new SaveIntakeOutput();
            String accessUrl = "";
            if (foodImage != null) {
                log.info("Food Image: {}", foodImage.getOriginalFilename());
                String storedPath = fileStorageService.store(foodImage, "food-images");
                accessUrl = fileStorageService.getAccessUrl(storedPath);
            }

            int dailyIntakeRecordId = userIntakeService.saveScannedFoodIntake(saveScannedFoodInput, accessUrl);
            saveIntakeOutput.setDailyIntakeId(dailyIntakeRecordId);
            log.info("Scanned food intake saved successfully");
            return ResponseEntity.ok(ApiResponse.success(saveIntakeOutput, ResponseCodeConstants.SCANNED_FOOD_SAVED, "Scanned food intake saved successfully."));

        } catch (Exception e) {
            log.error("Error saving scanned food: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error(ERROR, "Failed to save scanned food"));
        }
    }

    @PostMapping("/scanned-label")
    public ResponseEntity<ApiResponse<SaveIntakeOutput>> saveScannedLabel(
            @RequestPart("productImage") MultipartFile productImage,
            @RequestPart("saveScannedLabelInput") SaveScannedLabelInput saveScannedLabelInput) {

        log.info("Saving scanned label intake");
        log.info("Product Image: {}", productImage.getOriginalFilename());
        log.info("Product Analysis: {}", saveScannedLabelInput);

        try {
            SaveIntakeOutput saveIntakeOutput = new SaveIntakeOutput();
            String storedPath = fileStorageService.store(productImage, "food-images");
            String accessUrl = fileStorageService.getAccessUrl(storedPath);

            int dailyIntakeRecordId = userIntakeService.saveScannedLabelIntake(saveScannedLabelInput, accessUrl);
            saveIntakeOutput.setDailyIntakeId(dailyIntakeRecordId);
            log.info("Scanned product intake saved successfully");
            return ResponseEntity.ok(ApiResponse.success(saveIntakeOutput, ResponseCodeConstants.SCANNED_LABEL_SAVED, "Scanned product intake saved successfully"));

        } catch (Exception e) {
            log.error("Error saving scanned food: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error(ERROR, "Failed to save scanned food"));
        }
    }

    @GetMapping("/daily-intake")
    public ResponseEntity<ApiResponse<UserIntakeOutput>> getDailyIntake(
            @RequestParam("userId") String userId,
            @RequestParam("date") LocalDate date
    ) throws Exception {
        log.info("Fetching daily intake for userId: {} on date: {}", userId, date);
        UserIntakeOutput dailyIntake = userIntakeService.getUserIntake(userId, date);
        log.info("Daily intake fetched successfully for userId: {} on date: {}", userId, date);
        return ResponseEntity.ok(ApiResponse.success(dailyIntake, ResponseCodeConstants.DAILY_INTAKE_FETCHED, "Daily intake fetched successfully"));

    }

    @GetMapping("/intake-record")
    public ResponseEntity<ApiResponse<FoodAnalysisResponse>> getIntake(
            @RequestParam("userId") String userId,
            @RequestParam("dailyIntakeId") int dailyIntakeId
    ) throws Exception {
        FoodAnalysisResponse intakeDetails = userIntakeService.getIntakeDetails(userId, dailyIntakeId);
        return ResponseEntity.ok(ApiResponse.success(intakeDetails, ResponseCodeConstants.INTAKE_ITEM_FETCHED, "Intake item fetched successfully"));
    }

}
