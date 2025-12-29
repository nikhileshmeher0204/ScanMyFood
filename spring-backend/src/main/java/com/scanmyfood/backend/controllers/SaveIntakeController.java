package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.SaveScannedFoodInput;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;


@Slf4j
@RestController
@RequestMapping("/api/user/save")
public class SaveIntakeController {

    @PostMapping("/scannedFood")
    public ResponseEntity<ApiResponse> saveScannedFood(
            @RequestPart("foodImage") MultipartFile foodImage,
            @RequestPart("saveScannedFoodInput") SaveScannedFoodInput saveScannedFoodInput) {

        log.info("Saving scanned food intake");
        log.info("Food Image: {}", foodImage.getOriginalFilename());
        log.info("Food Analysis: {}", saveScannedFoodInput);

        //save totalPlateNutrients to user DB

        //save FoodAnalysis to ScannedMeal DB


        return ResponseEntity.ok(ApiResponse.success(null, "Scanned food intake saved successfully."));
    }
}
