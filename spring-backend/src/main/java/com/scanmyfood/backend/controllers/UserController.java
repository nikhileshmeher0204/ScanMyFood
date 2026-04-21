package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.constants.ResponseCodeConstants;
import com.scanmyfood.backend.dto.*;
import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.User;
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

    @GetMapping("/check/new-user/{firebaseUid}")
    public ResponseEntity<ApiResponse<UserCheckResponse>> checkIfNewUser(@PathVariable("firebaseUid") String firebaseUid) {
        log.info("Checking if user with uid {} is new", firebaseUid);
        boolean isNewUser = userService.isNewUser(firebaseUid);
        log.info("User with uid {} is new: {}", firebaseUid, isNewUser);
        UserCheckResponse response = UserCheckResponse.builder().isNewUser(isNewUser).build();
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.NEW_USER_CHECKED, response));
    }

    @PostMapping("/create-user")
    public ResponseEntity<ApiResponse<CreateUserResponse>> createUser(@RequestBody CreateUserRequest request) {
        log.info("Creating user with uid {}", request.getFirebaseUid());
        User user = userService.findOrCreateUser(request.getFirebaseUid(), request.getEmail(), request.getDisplayName());

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
                request.getFirebaseUid()
        );

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "success", true,
                "message", "Onboarding completed successfully"
        ), ResponseCodeConstants.ONBOARDING_COMPLETED, "Onboarding completed successfully"));
    }

    @GetMapping("/check/onboarding-status/{firebaseUid}")
    public ResponseEntity <ApiResponse<OnboardingStatusResponse>> checkIfOnboardingComplete(@PathVariable("firebaseUid") String firebaseUid) {
        log.info("Checking if user with uid {} is onboarding complete", firebaseUid);
        boolean isOnboardingComplete = userService.isOnboardingComplete(firebaseUid);

        OnboardingStatusResponse response = OnboardingStatusResponse.builder()
                .isOnboardingComplete(isOnboardingComplete)
                .build();
        log.info("User {} onboarding complete status: {}", firebaseUid, isOnboardingComplete);

        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.ONBOARDING_STATUS_CHECKED, response));
    }

    @PutMapping("/preferences")
    public ResponseEntity<ApiResponse<Void>> savePreferences(@RequestBody UserPreferencesRequest request) {
        log.info("Saving preferences for user {}", request.getFirebaseUid());
        userService.saveUserPreferences(
                request.getFirebaseUid(),
                request.getDietaryPreference(),
                request.getCountry()
        );
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
                request.getGoal()
        );
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.HEALTH_METRICS_SAVED, null));
    }
}