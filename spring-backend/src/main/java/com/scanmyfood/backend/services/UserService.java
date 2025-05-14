package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.HealthMetric;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.models.UserPreference;
import com.scanmyfood.backend.repositories.HealthMetricRepository;
import com.scanmyfood.backend.repositories.UserPreferenceRepository;
import com.scanmyfood.backend.repositories.UserRepository;
import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private UserPreferenceRepository userPreferenceRepository;
    @Autowired
    private HealthMetricRepository healthMetricRepository;

    private User getUserByFirebaseUid(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new IllegalArgumentException("User not found with firebaseUid: " + firebaseUid));
    }

    @Transactional
    public User findOrCreateUser(String firebaseUid, String email, String displayName) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseGet(() -> {
                    User newUser = new User();
                    log.info("Creating new user with uid {}", firebaseUid);
                    newUser.setFirebaseUid(firebaseUid);
                    newUser.setEmail(email);
                    newUser.setDisplayName(displayName);
                    newUser.setOnboardingComplete(false);
                    return userRepository.save(newUser);
                });
    }

    public boolean isNewUser(String firebaseUid) {
        return !userRepository.existsByFirebaseUid(firebaseUid);
    }

    public boolean isOnboardingComplete(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .map(
                user -> {
                    boolean isMarkedComplete = user.isOnboardingComplete();
                    log.info("User {} onboarding status: markedComplete={}",
                            firebaseUid, isMarkedComplete);
                    return isMarkedComplete;
                }).orElse(false);
    }


    @Transactional
    public void saveHealthMetrics(String firebaseUid, Integer heightFeet, Integer heightInches,
                                  Double weightKg, String goal) {
        User user = getUserByFirebaseUid(firebaseUid);

        HealthMetric healthMetric = user.getHealthMetric();
        if (healthMetric == null) {
            healthMetric = new HealthMetric();
            healthMetric.setUser(user);
        }

        healthMetric.setHeightFeet(heightFeet);
        healthMetric.setHeightInches(heightInches);
        healthMetric.setWeightKg(weightKg);
        healthMetric.setGoal(HealthMetric.Goal.valueOf(goal));

        healthMetricRepository.save(healthMetric);
    }

    @Transactional
    public void saveUserPreferences(String firebaseUid, String dietaryPreference, String country) {
        User user = getUserByFirebaseUid(firebaseUid);

        UserPreference preference = user.getUserPreference();
        if (preference == null) {
            preference = new UserPreference();
            preference.setUser(user);
        }

        preference.setDietaryPreference(UserPreference.DietType.valueOf(dietaryPreference));
        preference.setCountry(country);

        userPreferenceRepository.save(preference);
    }

    public void completeUserOnboarding(String firebaseUid, String dietaryPreference, String country, Integer heightFeet, Integer heightInches, Double weightKg, String goal) {
        User user = getUserByFirebaseUid(firebaseUid);
        // Save preferences
        UserPreference preference = user.getUserPreference();
        if (preference == null) {
            preference = new UserPreference();
            preference.setUser(user);
        }
        preference.setDietaryPreference(UserPreference.DietType.valueOf(dietaryPreference));
        preference.setCountry(country);
        userPreferenceRepository.save(preference);

        // Save health metrics
        HealthMetric healthMetric = user.getHealthMetric();
        if (healthMetric == null) {
            healthMetric = new HealthMetric();
            healthMetric.setUser(user);
        }
        healthMetric.setHeightFeet(heightFeet);
        healthMetric.setHeightInches(heightInches);
        healthMetric.setWeightKg(weightKg);
        healthMetric.setGoal(HealthMetric.Goal.valueOf(goal));
        healthMetricRepository.save(healthMetric);

        // Mark onboarding complete
        user.setOnboardingComplete(true);
        userRepository.save(user);

        log.info("User {} onboarding completed successfully", firebaseUid);
    }
}