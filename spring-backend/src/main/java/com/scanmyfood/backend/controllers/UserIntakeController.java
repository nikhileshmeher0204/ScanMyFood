package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.SaveScannedFoodInput;
import com.scanmyfood.backend.models.UserIntakeOutput;
import com.scanmyfood.backend.services.UserIntakeService;
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

    @PostMapping("/scannedFood")
    public ResponseEntity<ApiResponse> saveScannedFood(
            @RequestPart("foodImage") MultipartFile foodImage,
            @RequestPart("saveScannedFoodInput") SaveScannedFoodInput saveScannedFoodInput) {

        log.info("Saving scanned food intake");
        log.info("Food Image: {}", foodImage.getOriginalFilename());
        log.info("Food Analysis: {}", saveScannedFoodInput);

        //create food analysis record
        userIntakeService.saveIntake(saveScannedFoodInput);
        //insert food items

        //map food items to food analysis record


        return ResponseEntity.ok(ApiResponse.success(null, "Scanned food intake saved successfully."));
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
