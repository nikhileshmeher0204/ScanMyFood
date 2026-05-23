package com.scanmyfood.backend.models;

import lombok.Data;

@Data
public class Nutrient {
    private String name;
    private Quantity quantity;
    private Double dailyValue;
    private String dvStatus;
    private String goal;
    private String healthImpact;

    public void setDailyValue(Double dailyValue) {
        if (dailyValue != null) {
            this.dailyValue = Math.round(dailyValue * 100.0) / 100.0;
        } else {
            this.dailyValue = 0.00;
        }
    }
}
