package com.scanmyfood.backend.models;

import lombok.Data;

@Data
public class IntakeDescriptionRequest {
    String description;
    int dailyIntakeId;
}
