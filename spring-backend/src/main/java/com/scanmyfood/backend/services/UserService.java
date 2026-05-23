package com.scanmyfood.backend.services;

import com.scanmyfood.backend.constants.ErrorCodes;
import com.scanmyfood.backend.dto.UserCheckResponse;
import com.scanmyfood.backend.exceptions.NotFoundException;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.mapper.UserMapper;
import org.springframework.transaction.annotation.Transactional;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Transactional
    public User findOrCreateUser(String userId, String email, String displayName) {
        log.info("findOrCreateUser — userId: {}", userId);
        User user = userMapper.findByUserId(userId);
        if (user != null) {
            log.info("Existing user found for userId: {}", userId);
            return user;
        }

        log.info("Creating new user for userId: {}", userId);
        User newUser = new User();
        newUser.setUserId(userId);
        newUser.setEmail(email);
        newUser.setDisplayName(displayName);
        newUser.setOnboardingComplete(false);
        userMapper.insertUser(newUser);
        log.info("New user created successfully for userId: {}", userId);
        return newUser;
    }

    public UserCheckResponse isNewUser(String userId) {
        log.info("isNewUser check for userId: {}", userId);
        try {
            User user = getUserByUserId(userId);
            UserCheckResponse response = new UserCheckResponse();
            response.setNewUser(false);
            response.setOnboardingComplete(user.isOnboardingComplete());
            log.info("User {} exists — isNewUser=false, isOnboardingComplete={}", userId,
                    user.isOnboardingComplete());
            return response;
        } catch (NotFoundException e) {
            log.info("No backend record for userId: {} — treating as new user", userId);
            UserCheckResponse response = new UserCheckResponse();
            response.setNewUser(true);
            response.setOnboardingComplete(false);
            return response;
        }
    }

    @Transactional
    public void saveHealthMetrics(String userId, Integer heightFeet, Integer heightInches,
            Double weightKg, String goal) {
        log.info("saveHealthMetrics — userId: {}, height={}ft {}in, weight={}kg, goal={}",
                userId, heightFeet, heightInches, weightKg, goal);
        getUserByUserId(userId);
        userMapper.updateHealthMetrics(userId, heightFeet, heightInches, weightKg, User.Goal.valueOf(goal));
        log.info("Health metrics saved for userId: {}", userId);
    }

    @Transactional
    public void saveUserPreferences(String userId, String dietaryPreference, String country) {
        log.info("saveUserPreferences — userId: {}, diet={}, country={}", userId, dietaryPreference, country);
        getUserByUserId(userId);
        userMapper.updatePreferences(userId, User.DietType.valueOf(dietaryPreference), country);
        log.info("Preferences saved for userId: {}", userId);
    }

    @Transactional
    public void completeUserOnboarding(String userId) {
        log.info("completeUserOnboarding — userId: {}", userId);
        User user = getUserByUserId(userId);
        user.setOnboardingComplete(true);
        userMapper.updateUser(user);
        log.info("Onboarding completed for userId: {}", userId);
    }

    public User getUserByUserId(String userId) {
        log.debug("Looking up user by userId: {}", userId);
        User user = userMapper.findByUserId(userId);
        if (user == null) {
            log.warn("User not found for userId: {}", userId);
            throw new NotFoundException(ErrorCodes.ERR_USER_NOT_FOUND,
                    "No user exists with user id: " + userId);
        }
        log.debug("User found for userId: {}", userId);
        return user;
    }

}