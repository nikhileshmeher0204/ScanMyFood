package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.HealthMetric;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.models.UserPreference;
import com.scanmyfood.backend.mapper.UserMapper;
import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    private User getUserByFirebaseUid(String firebaseUid) {
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user == null) {
            throw new IllegalArgumentException("User not found with firebaseUid: " + firebaseUid);
        }
        return user;
    }

    @Transactional
    public User findOrCreateUser(String firebaseUid, String email, String displayName) {
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user != null) {
            return user;
        }
        
        User newUser = new User();
        log.info("Creating new user with uid {}", firebaseUid);
        newUser.setFirebaseUid(firebaseUid);
        newUser.setEmail(email);
        newUser.setDisplayName(displayName);
        newUser.setOnboardingComplete(false);
        userMapper.insertUser(newUser);
        return newUser;
    }

    public boolean isNewUser(String firebaseUid) {
        return !userMapper.existsByFirebaseUid(firebaseUid);
    }

    public boolean isOnboardingComplete(String firebaseUid) {
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user != null) {
            boolean isMarkedComplete = user.isOnboardingComplete();
            log.info("User {} onboarding status: markedComplete={}",
                    firebaseUid, isMarkedComplete);
            return isMarkedComplete;
        }
        return false;
    }


    @Transactional
    public void saveHealthMetrics(String firebaseUid, Integer heightFeet, Integer heightInches,
                                  Double weightKg, String goal) {
        // Ensure user exists
        getUserByFirebaseUid(firebaseUid);

        HealthMetric existingMetric = userMapper.findHealthMetricByFirebaseUid(firebaseUid);
        HealthMetric metric = new HealthMetric();
        metric.setFirebaseUid(firebaseUid);
        metric.setHeightFeet(heightFeet);
        metric.setHeightInches(heightInches);
        metric.setWeightKg(weightKg);
        metric.setGoal(HealthMetric.Goal.valueOf(goal));

        if (existingMetric == null) {
            userMapper.insertHealthMetric(firebaseUid, metric);
        } else {
            userMapper.updateHealthMetric(firebaseUid, metric);
        }
    }

    @Transactional
    public void saveUserPreferences(String firebaseUid, String dietaryPreference, String country) {
        // Ensure user exists
        getUserByFirebaseUid(firebaseUid);

        UserPreference existingPreference = userMapper.findPreferenceByFirebaseUid(firebaseUid);
        UserPreference preference = new UserPreference();
        preference.setFirebaseUid(firebaseUid);
        preference.setDietaryPreference(UserPreference.DietType.valueOf(dietaryPreference));
        preference.setCountry(country);

        if (existingPreference == null) {
            userMapper.insertUserPreference(firebaseUid, preference);
        } else {
            userMapper.updateUserPreference(firebaseUid, preference);
        }
    }

    @Transactional
    public void completeUserOnboarding(String firebaseUid) {
        User user = getUserByFirebaseUid(firebaseUid);
        // Mark onboarding complete
        user.setOnboardingComplete(true);
        userMapper.updateUser(user);

        log.info("User {} onboarding completed successfully", firebaseUid);
    }
}