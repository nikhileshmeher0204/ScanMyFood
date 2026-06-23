package com.scanmyfood.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    private String userId;
    private String email;
    private String displayName;
    private boolean isOnboardingComplete;
    private String dietaryPreference;
    private String country;
    private Integer heightFeet;
    private Integer heightInches;
    private Double weightKg;
    private String goal;
    private Double bmi;
    private String bmiCategory;
    private List<HealthConditionDto> healthConditions;
}
