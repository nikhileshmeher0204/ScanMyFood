// UserPreference.java
package com.scanmyfood.backend.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_preferences")
public class UserPreference {
    @Id
    private String firebaseUid;

    @OneToOne
    @JoinColumn(name = "firebase_uid", referencedColumnName = "firebaseUid")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DietType dietaryPreference;

    private String country;

    // Enum for dietary preference
    public enum DietType {
        VEG, NON_VEG, VEGAN
    }
}