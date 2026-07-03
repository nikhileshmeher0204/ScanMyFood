package com.scanmyfood.backend.tools;

import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.services.AiService;
import com.scanmyfood.backend.services.UserService;
import com.scanmyfood.backend.utils.UserContextHolder;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class LogMealViaDescriptionTool {

    @Autowired
    private AiService aiService;

    @Autowired
    private UserService userService;

    @Tool(description = "Analyzes a natural language meal description to extract nutritional data and saves it as a meal intake record. Returns the meal name, analyzed food items, and total nutrients.")
    public Map<String, Object> logMealViaDescription(
            @ToolParam(description = "Natural language description of the meal, e.g., '2 eggs, a slice of whole wheat toast with butter'") String description) {

        String userId = UserContextHolder.getUserId();

        // Single service call analyzes food description and saves the intake
        FoodAnalysisResponse result = aiService.analyzeFoodDescription(description, userId);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("success", true);
        response.put("meal_name", result.getMealName());
        response.put("food_items", result.getAnalyzedFoodItems());
        response.put("total_nutrients", result.getTotalPlateNutrients());

        return response;
    }
}
