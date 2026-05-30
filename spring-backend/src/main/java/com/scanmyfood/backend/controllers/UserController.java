package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.constants.ResponseCodeConstants;
import com.scanmyfood.backend.dto.*;
import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.services.HealthConditionService;
import com.scanmyfood.backend.services.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private HealthConditionService healthConditionService;

    @GetMapping("/user")
    public ResponseEntity<ApiResponse<UserCheckResponse>> checkIfNewUser(
            @RequestHeader("X-User-Id") String userId) {
        log.info("Checking if user with id {} is new", userId);
        UserCheckResponse userCheckResponse = userService.isNewUser(userId);
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.NEW_USER_CHECKED, userCheckResponse));
    }

    @PostMapping("/create-user")
    public ResponseEntity<ApiResponse<CreateUserResponse>> createUser(@RequestBody CreateUserRequest request) {
        log.info("Creating user with id {}", request.getUserId());
        User user = userService.findOrCreateUser(request.getUserId(), request.getEmail(),
                request.getDisplayName());

        CreateUserResponse response = CreateUserResponse.builder()
                .userId(user.getUserId())
                .created(true)
                .build();
        log.info("User with id {} created successfully", request.getUserId());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.USER_CREATED, response));
    }

    @PostMapping("/complete-onboarding")
    public ResponseEntity<ApiResponse<Map<String, Object>>> completeOnboarding(@RequestBody OnboardingRequest request) {
        log.info("Completing onboarding for user {}", request.getUserId());

        userService.completeUserOnboarding(request.getUserId());

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "success", true,
                "message", "Onboarding completed successfully"), ResponseCodeConstants.ONBOARDING_COMPLETED,
                "Onboarding completed successfully"));
    }

    @PutMapping("/preferences")
    public ResponseEntity<ApiResponse<Void>> savePreferences(@RequestBody UserPreferencesRequest request) {
        log.info("Saving preferences for user {}", request.getUserId());
        userService.saveUserPreferences(
                request.getUserId(),
                request.getDietaryPreference(),
                request.getCountry());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.PREFERENCES_SAVED, null));
    }

    @PutMapping("/health-metrics")
    public ResponseEntity<ApiResponse<Void>> saveHealthMetrics(@RequestBody HealthMetricsRequest request) {
        log.info("Saving health metrics for user {}", request.getUserId());
        userService.saveHealthMetrics(
                request.getUserId(),
                request.getHeightFeet(),
                request.getHeightInches(),
                request.getWeightKg(),
                request.getGoal());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.HEALTH_METRICS_SAVED, null));
    }

    @PutMapping("/health-conditions")
    public ResponseEntity<ApiResponse<Void>> saveHealthConditions(@RequestBody SaveUserConditionsRequest request) {
        log.info("Saving health conditions for user {}", request.getUserId());
        healthConditionService.saveUserConditions(
                request.getUserId(),
                request.getConditionNames());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.SUCCESS, null));
    }

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getUserProfile(
            @RequestHeader("X-User-Id") String userId) {
        log.info("Fetching complete user profile for id {}", userId);
        
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
        
        UserProfileResponse profileResponse = UserProfileResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .displayName(user.getDisplayName())
                .isOnboardingComplete(user.isOnboardingComplete())
                .dietaryPreference(user.getDietaryPreference() != null ? user.getDietaryPreference().name() : null)
                .country(user.getCountry())
                .heightFeet(user.getHeightFeet())
                .heightInches(user.getHeightInches())
                .weightKg(user.getWeightKg())
                .goal(user.getGoal() != null ? user.getGoal().name() : null)
                .bmi(bmi)
                .bmiCategory(bmiCategory)
                .healthConditions(conditions)
                .build();
                
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.SUCCESS, profileResponse));
    }
}
