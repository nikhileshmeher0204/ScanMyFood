package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class HealthCondition {
    
    private String name;
    private String description;
    private List<String> nutrientsToLimit;
    private List<String> nutrientsToIncrease;
    private List<String> ingredientsToLimit;
    private List<String> dietaryTagsToLimit;
}
