package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FoodNutrient {
    private String name;
    private Quantity quantity;
}