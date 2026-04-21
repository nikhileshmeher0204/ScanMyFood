package com.scanmyfood.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthMetricsRequest {
    private String firebaseUid;
    private int heightFeet;
    private int heightInches;
    private double weightKg;
    private String goal;
}
