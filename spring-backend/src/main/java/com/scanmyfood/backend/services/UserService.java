package com.scanmyfood.backend.services;

import com.scanmyfood.backend.constants.ErrorCodes;
import com.scanmyfood.backend.dto.UserCheckResponse;
import com.scanmyfood.backend.exceptions.NotFoundException;
import com.scanmyfood.backend.models.User;
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
            throw new NotFoundException(ErrorCodes.ERR_USER_NOT_FOUND,
                    "No user exists with firebase uid: " + firebaseUid);
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

    public UserCheckResponse isNewUser(String firebaseUid) {
        User user = getUserByFirebaseUid(firebaseUid);
        UserCheckResponse userCheckResponse = new UserCheckResponse();
        userCheckResponse.setNewUser(true);
        userCheckResponse.setOnboardingComplete(user.isOnboardingComplete());
        return userCheckResponse;
    }

    @Transactional
    public void saveHealthMetrics(String firebaseUid, Integer heightFeet, Integer heightInches,
            Double weightKg, String goal) {
        // Ensure user exists
        getUserByFirebaseUid(firebaseUid);

        userMapper.updateHealthMetrics(firebaseUid, heightFeet, heightInches, weightKg, User.Goal.valueOf(goal));
    }

    @Transactional
    public void saveUserPreferences(String firebaseUid, String dietaryPreference, String country) {
        // Ensure user exists
        getUserByFirebaseUid(firebaseUid);

        userMapper.updatePreferences(firebaseUid, User.DietType.valueOf(dietaryPreference), country);
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