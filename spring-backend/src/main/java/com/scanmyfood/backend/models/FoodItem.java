package com.scanmyfood.backend.models;


import lombok.Data;
import java.util.Map;

@Data
public class FoodItem {
    private String name;
    private Quantity quantity;
    private Map<String, Quantity> nutrientsPer100g;

    @Data
    public static class Quantity {
        private double value;
        private String unit;
    }
}
