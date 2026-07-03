package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.tools.GetUserProfileTool;
import com.scanmyfood.backend.tools.LogMealViaDescriptionTool;
import com.scanmyfood.backend.tools.SaveScannedFoodIntakeTool;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.scanmyfood.backend.utils.UserContextHolder;
import com.scanmyfood.backend.exceptions.NotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/tools")
public class ToolExecutionController {

    @Autowired
    private GetUserProfileTool userProfileTool;

    @Autowired
    private LogMealViaDescriptionTool logMealViaDescriptionTool;

    @Autowired
    private SaveScannedFoodIntakeTool saveScannedFoodIntakeTool;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/{toolName}/execute")
    public ResponseEntity<ApiResponse<Map<String, Object>>> executeTool(
            @PathVariable String toolName,
            @RequestBody Map<String, Object> args,
            @RequestHeader("X-User-Id") String userId) {
        
        log.info("Executing tool: {} for userId: {}", toolName, userId);

        try {
            UserContextHolder.setUserId(userId);

            Map<String, Object> result;
            switch (toolName) {
                case "getUserProfile":
                    result = userProfileTool.getUserProfile();
                    break;
                case "logMealViaDescription":
                    String description = (String) args.get("description");
                    if (description == null || description.isEmpty()) {
                        throw new IllegalArgumentException("Description parameter is required");
                    }
                    result = logMealViaDescriptionTool.logMealViaDescription(description);
                    break;
                case "saveScannedFoodIntake":
                    Map<String, Object> foodAnalysisMap = (Map<String, Object>) args.get("food_analysis_response");
                    String source = (String) args.get("source_of_intake");
                    String created = (String) args.get("created_at");
                    if (foodAnalysisMap == null) {
                        throw new IllegalArgumentException("food_analysis_response parameter is required");
                    }
                    FoodAnalysisResponse foodAnalysisResponse = objectMapper.convertValue(foodAnalysisMap, FoodAnalysisResponse.class);
                    result = saveScannedFoodIntakeTool.saveScannedFoodIntake(foodAnalysisResponse, source, created);
                    break;
                default:
                    throw new NotFoundException("TOOL_NOT_FOUND", "Unknown tool: " + toolName);
            }

            return ResponseEntity.ok(ApiResponse.success("TOOL_EXECUTED", result));
        } finally {
            UserContextHolder.clear();
        }
    }
}
