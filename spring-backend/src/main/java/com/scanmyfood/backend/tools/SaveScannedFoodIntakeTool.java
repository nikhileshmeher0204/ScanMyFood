package com.scanmyfood.backend.tools;

import com.scanmyfood.backend.events.MealLoggedEvent;
import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.models.SaveScannedFoodInput;
import com.scanmyfood.backend.services.UserIntakeService;
import com.scanmyfood.backend.utils.UserContextHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZonedDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class SaveScannedFoodIntakeTool {

    private static final Logger logger = LoggerFactory.getLogger(SaveScannedFoodIntakeTool.class);

    @Autowired
    private UserIntakeService userIntakeService;

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Tool(description = "Saves the analyzed meal details into the user's daily intake log. Call this only after the user explicitly confirms they want to log the meal.")
    public Map<String, Object> saveScannedFoodIntake(
            @ToolParam(description = "The food analysis response object containing analyzed food items and total nutrients.") FoodAnalysisResponse foodAnalysisResponse,
            @ToolParam(description = "The source of the intake, e.g., 'SD' for scanned description or 'SM' for scanned meal.") String sourceOfIntake,
            @ToolParam(description = "The timestamp of when the meal was consumed in ISO-8601 format, e.g., '2026-07-02T12:00:00'. Optional, defaults to now.") String createdAt) {

        String userId = UserContextHolder.getUserId();
        logger.info("saveScannedFoodIntake tool called for user: {}, source: {}, date: {}", userId, sourceOfIntake, createdAt);

        // Normalize sourceOfIntake strictly to enum values ("SD", "SM", etc.)
        String normalizedSource = "SD";
        if (sourceOfIntake != null) {
            String src = sourceOfIntake.trim().toUpperCase();
            if (src.contains("MEAL") || src.equals("SM")) {
                normalizedSource = "SM";
            } else if (src.contains("LABEL") || src.equals("SL")) {
                normalizedSource = "SL";
            }
        }

        // Parse consumption date/time robustly
        LocalDateTime createdTime = LocalDateTime.now();
        if (createdAt != null && !createdAt.trim().isEmpty()) {
            try {
                createdTime = LocalDateTime.parse(createdAt);
            } catch (Exception e1) {
                try {
                    createdTime = OffsetDateTime.parse(createdAt).toLocalDateTime();
                } catch (Exception e2) {
                    try {
                        createdTime = ZonedDateTime.parse(createdAt).toLocalDateTime();
                    } catch (Exception e3) {
                        logger.warn("Could not parse consumption date/time: '{}', falling back to current time.", createdAt);
                    }
                }
            }
        }

        SaveScannedFoodInput input = new SaveScannedFoodInput();
        input.setUserId(userId);
        input.setSourceOfIntake(normalizedSource);
        input.setFoodAnalysisResponse(foodAnalysisResponse);
        input.setCreatedAt(createdTime);

        Map<String, Object> response = new LinkedHashMap<>();
        try {
            int dailyIntakeId = userIntakeService.saveScannedFoodIntake(input, "");
            logger.info("Successfully saved scanned food intake with record ID: {}", dailyIntakeId);

            // Publish application event for SSE real-time stream sync
            eventPublisher.publishEvent(new MealLoggedEvent(userId, dailyIntakeId));

            response.put("success", true);
            response.put("dailyIntakeId", dailyIntakeId);
            response.put("message", "Meal logged successfully in daily intake.");
        } catch (Exception e) {
            logger.error("Failed to save scanned food intake: {}", e.getMessage(), e);
            response.put("success", false);
            response.put("message", "Failed to save intake: " + e.getMessage());
        }

        return response;
    }
}
