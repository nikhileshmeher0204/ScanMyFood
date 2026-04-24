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

    @Transactional
    public User findOrCreateUser(String firebaseUid, String email, String displayName) {
        log.info("findOrCreateUser — firebaseUid: {}", firebaseUid);
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user != null) {
            log.info("Existing user found for firebaseUid: {}", firebaseUid);
            return user;
        }

        log.info("Creating new user for firebaseUid: {}", firebaseUid);
        User newUser = new User();
        newUser.setFirebaseUid(firebaseUid);
        newUser.setEmail(email);
        newUser.setDisplayName(displayName);
        newUser.setOnboardingComplete(false);
        userMapper.insertUser(newUser);
        log.info("New user created successfully for firebaseUid: {}", firebaseUid);
        return newUser;
    }

    public UserCheckResponse isNewUser(String firebaseUid) {
        log.info("isNewUser check for firebaseUid: {}", firebaseUid);
        try {
            User user = getUserByFirebaseUid(firebaseUid);
            UserCheckResponse response = new UserCheckResponse();
            response.setNewUser(false);
            response.setOnboardingComplete(user.isOnboardingComplete());
            log.info("User {} exists — isNewUser=false, isOnboardingComplete={}", firebaseUid,
                    user.isOnboardingComplete());
            return response;
        } catch (NotFoundException e) {
            log.info("No backend record for firebaseUid: {} — treating as new user", firebaseUid);
            UserCheckResponse response = new UserCheckResponse();
            response.setNewUser(true);
            response.setOnboardingComplete(false);
            return response;
        }
    }

    @Transactional
    public void saveHealthMetrics(String firebaseUid, Integer heightFeet, Integer heightInches,
            Double weightKg, String goal) {
        log.info("saveHealthMetrics — firebaseUid: {}, height={}ft {}in, weight={}kg, goal={}",
                firebaseUid, heightFeet, heightInches, weightKg, goal);
        getUserByFirebaseUid(firebaseUid);
        userMapper.updateHealthMetrics(firebaseUid, heightFeet, heightInches, weightKg, User.Goal.valueOf(goal));
        log.info("Health metrics saved for firebaseUid: {}", firebaseUid);
    }

    @Transactional
    public void saveUserPreferences(String firebaseUid, String dietaryPreference, String country) {
        log.info("saveUserPreferences — firebaseUid: {}, diet={}, country={}", firebaseUid, dietaryPreference, country);
        getUserByFirebaseUid(firebaseUid);
        userMapper.updatePreferences(firebaseUid, User.DietType.valueOf(dietaryPreference), country);
        log.info("Preferences saved for firebaseUid: {}", firebaseUid);
    }

    @Transactional
    public void completeUserOnboarding(String firebaseUid) {
        log.info("completeUserOnboarding — firebaseUid: {}", firebaseUid);
        User user = getUserByFirebaseUid(firebaseUid);
        user.setOnboardingComplete(true);
        userMapper.updateUser(user);
        log.info("Onboarding completed for firebaseUid: {}", firebaseUid);
    }

    private User getUserByFirebaseUid(String firebaseUid) {
        log.debug("Looking up user by firebaseUid: {}", firebaseUid);
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user == null) {
            log.warn("User not found for firebaseUid: {}", firebaseUid);
            throw new NotFoundException(ErrorCodes.ERR_USER_NOT_FOUND,
                    "No user exists with firebase uid: " + firebaseUid);
        }
        log.debug("User found for firebaseUid: {}", firebaseUid);
        return user;
    }
}