package com.scanmyfood.backend.models;


import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class FoodItem {
    private String name;
    private Quantity quantity;
    private List<FoodNutrient> nutrients;
}
