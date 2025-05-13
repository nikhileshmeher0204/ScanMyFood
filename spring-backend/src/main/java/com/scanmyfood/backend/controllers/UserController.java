package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.services.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@Slf4j
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/check/new-user/{firebaseUid}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkIfNewUser(@PathVariable String firebaseUid) {
        log.info("Checking if user with uid {} is new", firebaseUid);
        boolean isNewUser = userService.isNewUser(firebaseUid);
        Map<String, Object> response = new HashMap<>();
        log.info("User with uid {} is new: {}", firebaseUid, isNewUser);
        response.put("isNewUser", isNewUser);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/create-user")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createUser(@RequestBody Map<String, String> userData) {
        log.info("Creating user with uid {}", userData.get("firebaseUid"));
        String firebaseUid = userData.get("firebaseUid");
        String email = userData.get("email");
        String displayName = userData.get("displayName");

        User user = userService.findOrCreateUser(firebaseUid, email, displayName);

        Map<String, Object> response = new HashMap<>();
        response.put("userId", user.getId());
        response.put("created", true);
        log.info("User with uid {} created successfully", firebaseUid);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/check/onboarding-status/{firebaseUid}")
    public ResponseEntity <ApiResponse<Map<String, Object>>> checkIfOnboardingComplete(@PathVariable String firebaseUid) {
        log.info("Checking if user with uid {} is onboarding complete", firebaseUid);
        boolean isOnboardingComplete = userService.isOnboardingComplete(firebaseUid);

        Map<String, Object> response = new HashMap<>();
        response.put("isOnboardingComplete", isOnboardingComplete);
        log.info("User {} onboarding complete status: {}", firebaseUid, isOnboardingComplete);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/complete-onboarding/{firebaseUid}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> markOnboardingComplete(@PathVariable String firebaseUid) {
        log.info("Marking onboarding as complete for user {}", firebaseUid);
        userService.markOnboardingComplete(firebaseUid);

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "success", true,
                "message", "Onboarding marked as complete"
        )));
    }

    @PostMapping("/preferences")
    public ResponseEntity<ApiResponse<Map<String, Object>>> saveUserPreferences(@RequestBody Map<String, String> preferences) {
        String dietaryPreference = preferences.get("dietaryPreference");
        String country = preferences.get("country");
        String firebaseUid = preferences.get("firebaseUid");

        log.info("Saving preferences for user: {} - diet: {}, country: {}", firebaseUid, dietaryPreference, country);

        userService.saveUserPreferences(firebaseUid, dietaryPreference, country);

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "success", true,
                "message", "Preferences saved successfully"
        )));
    }

    @PostMapping("/health-metrics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> saveHealthMetrics(@RequestBody Map<String, Object> metrics) {
        log.info("Saving health metrics: {}", metrics);

        String firebaseUid = (String) metrics.get("firebaseUid");
        Integer heightFeet = (Integer) metrics.get("heightFeet");
        Integer heightInches = (Integer) metrics.get("heightInches");
        Double weightKg = Double.valueOf(metrics.get("weightKg").toString());
        String goal = (String) metrics.get("goal");

        userService.saveHealthMetrics(firebaseUid, heightFeet, heightInches, weightKg, goal);

        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "success", true,
                "message", "Health metrics saved successfully"
        )));
    }
}