package com.scanmyfood.backend.models;

import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Getter
@Setter
public class DailyIntake {
    private Long id;
    private User user;
    private LocalDate date;
    private String foodName;
    private Double calories;
    private Double protein;
    private Double carbohydrate;
    private Double fat;
    private Double fiber;
    private String nutrientsJson;
    private String source;
}