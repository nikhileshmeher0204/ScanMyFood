package com.scanmyfood.backend.models;

import lombok.Data;

@Data
public class Nutrient {
    private String name;
    private Quantity quantity;
    private String dailyValue;
    private String dvStatus;
    private String goal;
    private String healthImpact;
}
