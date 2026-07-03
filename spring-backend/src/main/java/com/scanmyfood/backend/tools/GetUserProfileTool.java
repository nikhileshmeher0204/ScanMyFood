package com.scanmyfood.backend.tools;

import com.scanmyfood.backend.dto.HealthConditionDto;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.services.HealthConditionService;
import com.scanmyfood.backend.services.UserService;
import com.scanmyfood.backend.utils.UserContextHolder;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class GetUserProfileTool {

    @Autowired
    private UserService userService;

    @Autowired
    private HealthConditionService healthConditionService;

    @Tool(description = "Fetches the user's health profile including weight, height, BMI, dietary preferences, health conditions, and fitness goals. No PII is returned (no email, no display name).")
    public Map<String, Object> getUserProfile() {
        String userId = UserContextHolder.getUserId();
        if (userId == null || userId.isEmpty()) {
            userId = "dev-user-id";
            // Ensure dev user exists in database
            userService.findOrCreateUser(userId, "dev@example.com", "Dev User");
        }

        User user = userService.getUserByUserId(userId);
        List<HealthConditionDto> conditions = healthConditionService.getUserConditions(userId);

        Double bmi = null;
        String bmiCategory = null;
        if (user.getWeightKg() != null && user.getHeightFeet() != null && user.getHeightInches() != null) {
            int totalInches = (user.getHeightFeet() * 12) + user.getHeightInches();
            double heightMeters = totalInches * 0.0254;
            if (heightMeters > 0) {
                bmi = user.getWeightKg() / (heightMeters * heightMeters);
                bmi = Math.round(bmi * 10.0) / 10.0;

                if (bmi < 18.5) {
                    bmiCategory = "Underweight";
                } else if (bmi < 25) {
                    bmiCategory = "Normal weight";
                } else if (bmi < 30) {
                    bmiCategory = "Overweight";
                } else {
                    bmiCategory = "Obese";
                }
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("weight_kg", user.getWeightKg());
        result.put("height_feet", user.getHeightFeet());
        result.put("height_inches", user.getHeightInches());
        result.put("dietary_preference", user.getDietaryPreference() != null ? user.getDietaryPreference().name() : null);
        result.put("country", user.getCountry());
        result.put("goal", user.getGoal() != null ? user.getGoal().name() : null);
        result.put("bmi", bmi);
        result.put("bmi_category", bmiCategory);
        result.put("health_conditions", conditions.stream().map(HealthConditionDto::getName).collect(Collectors.toList()));

        return result;
    }
}
