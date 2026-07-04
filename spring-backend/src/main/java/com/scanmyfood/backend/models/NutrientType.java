package com.scanmyfood.backend.models;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public enum NutrientType {
    CALORIES("calories", Arrays.asList("energy", "kcal")),
    PROTEIN("protein", Collections.singletonList("proteins")),
    TOTAL_CARBOHYDRATE("total_carbohydrate", Arrays.asList("carbs", "carbohydrate", "total_carbohydrates")),
    TOTAL_FAT("total_fat", Arrays.asList("fat", "total_fats")),
    SATURATED_FAT("saturated_fat", Arrays.asList("sat_fat", "saturated_fats")),
    TRANS_FAT("trans_fat", Arrays.asList("trans_fats")),
    DIETARY_FIBER("dietary_fiber", Arrays.asList("fiber", "fibers")),
    TOTAL_SUGARS("total_sugars", Arrays.asList("sugar", "sugars")),
    ADDED_SUGARS("added_sugars", Arrays.asList("added_sugar")),
    SODIUM("sodium", Collections.singletonList("salt"));

    private final String canonicalName;
    private final List<String> aliases;

    NutrientType(String canonicalName, List<String> aliases) {
        this.canonicalName = canonicalName;
        this.aliases = aliases;
    }

    public String getCanonicalName() {
        return canonicalName;
    }

    public static NutrientType fromString(String value) {
        if (value == null) return null;
        String clean = value.trim().toLowerCase().replace(" ", "_");
        for (NutrientType type : values()) {
            if (type.canonicalName.equals(clean) || type.aliases.contains(clean)) {
                return type;
            }
        }
        return null;
    }
}
