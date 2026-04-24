package com.scanmyfood.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthConditionDto {
    private String name;
    private String description;
    private List<String> nutrientsToLimit;
    private List<String> nutrientsToIncrease;
    private List<String> ingredientsToLimit;
    private List<String> dietaryTagsToLimit;
}
