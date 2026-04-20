package com.scanmyfood.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String firebaseUid;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private boolean isOnboardingComplete;

    private String displayName;

    // Denormalized Preference Fields
    @Enumerated(EnumType.STRING)
    private DietType dietaryPreference;
    private String country;

    // Denormalized Health Metric Fields
    private Integer heightFeet;
    private Integer heightInches;
    private Double weightKg;

    @Enumerated(EnumType.STRING)
    private Goal goal;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Enums
    public enum DietType {
        VEG, NON_VEG, VEGAN
    }

    public enum Goal {
        BALANCED_DIET, MUSCLE_GAIN, WEIGHT_LOSS
    }
}