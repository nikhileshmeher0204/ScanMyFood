package com.scanmyfood.backend.models;

import lombok.Data;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@Data
public class FoodItem {
    private String name;
    private double portion = 1.0;
    
    @JsonProperty("canonical_name")
    private String canonicalName;
    
    @JsonProperty("dietary_type")
    private String dietaryType;
    
    private Quantity quantity;
    private List<FoodNutrient> nutrients;
}
