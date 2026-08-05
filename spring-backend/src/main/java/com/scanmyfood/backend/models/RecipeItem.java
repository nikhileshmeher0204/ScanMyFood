package com.scanmyfood.backend.models;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import com.fasterxml.jackson.annotation.JsonProperty;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeItem {
    @JsonProperty("canonical_name")
    private String canonicalName;
    
    private String name;
    private Double value;
    private String unit;
}
