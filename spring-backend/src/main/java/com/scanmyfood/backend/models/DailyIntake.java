package com.scanmyfood.backend.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "daily_intakes")
public class DailyIntake {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate date;

    private String foodName;

    private Double calories;
    private Double protein;
    private Double carbohydrates;
    private Double fat;
    private Double fiber;

    @Column(columnDefinition = "TEXT")
    private String nutrientsJson;

    private String source;
}