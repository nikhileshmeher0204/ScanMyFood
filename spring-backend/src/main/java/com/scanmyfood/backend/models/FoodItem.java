package com.scanmyfood.backend.models;

import lombok.Data;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@Data
public class FoodItem {
    private String name;
    
    @JsonProperty("canonical_name")
    private String canonicalName;
    
    private Quantity quantity;
    private List<FoodNutrient> nutrients;
}
