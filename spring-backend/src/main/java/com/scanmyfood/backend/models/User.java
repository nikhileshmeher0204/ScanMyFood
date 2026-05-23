package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User {

    private String userId;
    private String email;
    private boolean isOnboardingComplete;
    private String displayName;

    // Denormalized Preference Fields
    private DietType dietaryPreference;
    private String country;

    // Denormalized Health Metric Fields
    private Integer heightFeet;
    private Integer heightInches;
    private Double weightKg;
    private Goal goal;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Enums
    public enum DietType {
        VEG, NON_VEG, VEGAN
    }

    public enum Goal {
        BALANCED_DIET, MUSCLE_GAIN, WEIGHT_LOSS
    }
}