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
            @RequestHeader("X-Firebase-Uid") String firebaseUid) {
        log.info("Checking if user with uid {} is new", firebaseUid);
        UserCheckResponse userCheckResponse = userService.isNewUser(firebaseUid);
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.NEW_USER_CHECKED, userCheckResponse));
    }

    @PostMapping("/create-user")
    public ResponseEntity<ApiResponse<CreateUserResponse>> createUser(@RequestBody CreateUserRequest request) {
        log.info("Creating user with uid {}", request.getFirebaseUid());
        User user = userService.findOrCreateUser(request.getFirebaseUid(), request.getEmail(),
                request.getDisplayName());

        CreateUserResponse response = CreateUserResponse.builder()
                .userId(user.getFirebaseUid())
                .created(true)
                .build();
        log.info("User with uid {} created successfully", request.getFirebaseUid());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.USER_CREATED, response));
    }

    @PostMapping("/complete-onboarding")
    public ResponseEntity<ApiResponse<Map<String, Object>>> completeOnboarding(@RequestBody OnboardingRequest request) {
        log.info("Completing onboarding for user {}", request.getFirebaseUid());

        userService.completeUserOnboarding(
                request.getFirebaseUid());

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "success", true,
                "message", "Onboarding completed successfully"), ResponseCodeConstants.ONBOARDING_COMPLETED,
                "Onboarding completed successfully"));
    }

    @PutMapping("/preferences")
    public ResponseEntity<ApiResponse<Void>> savePreferences(@RequestBody UserPreferencesRequest request) {
        log.info("Saving preferences for user {}", request.getFirebaseUid());
        userService.saveUserPreferences(
                request.getFirebaseUid(),
                request.getDietaryPreference(),
                request.getCountry());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.PREFERENCES_SAVED, null));
    }

    @PutMapping("/health-metrics")
    public ResponseEntity<ApiResponse<Void>> saveHealthMetrics(@RequestBody HealthMetricsRequest request) {
        log.info("Saving health metrics for user {}", request.getFirebaseUid());
        userService.saveHealthMetrics(
                request.getFirebaseUid(),
                request.getHeightFeet(),
                request.getHeightInches(),
                request.getWeightKg(),
                request.getGoal());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.HEALTH_METRICS_SAVED, null));
    }

    @PutMapping("/health-conditions")
    public ResponseEntity<ApiResponse<Void>> saveHealthConditions(@RequestBody SaveUserConditionsRequest request) {
        log.info("Saving health conditions for user {}", request.getFirebaseUid());
        healthConditionService.saveUserConditions(
                request.getFirebaseUid(),
                request.getConditionNames());
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.SUCCESS, null));
    }
}