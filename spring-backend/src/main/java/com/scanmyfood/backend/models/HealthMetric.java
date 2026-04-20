package com.scanmyfood.backend.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "health_metrics")
public class HealthMetric {
    @Id
    @Column(name = "firebase_uid")
    private String firebaseUid;

    private Integer heightFeet;
    private Integer heightInches;
    private Double weightKg;

    @Enumerated(EnumType.STRING)
    private Goal goal;

    // Enum for goals
    public enum Goal {
        BALANCED_DIET, MUSCLE_GAIN, WEIGHT_LOSS
    }
}