package com.scanmyfood.backend.models;

import lombok.Data;

@Data
public class FoodNutrient {
    private String name;
    private Quantity quantity;
}