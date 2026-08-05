package com.scanmyfood.backend.utils;

import com.scanmyfood.backend.models.FoodNutrient;
import com.scanmyfood.backend.models.NutrientType;
import com.scanmyfood.backend.models.Quantity;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

public class NutrientSanitizer {

    public static List<FoodNutrient> sanitize(List<FoodNutrient> rawNutrients) {
        Map<NutrientType, FoodNutrient> normalizedMap = new EnumMap<>(NutrientType.class);

        // 1. Group and normalize incoming nutrients
        if (rawNutrients != null) {
            for (FoodNutrient nutrient : rawNutrients) {
                if (nutrient == null || nutrient.getName() == null) continue;
                
                NutrientType type = NutrientType.fromString(nutrient.getName());
                if (type != null) {
                    nutrient.setName(type.getCanonicalName());
                    // Protect against null values/units
                    if (nutrient.getQuantity() == null) {
                        nutrient.setQuantity(new Quantity(0.0, getDefaultUnit(type)));
                    } else {
                        if (nutrient.getQuantity().getValue() == null) {
                            nutrient.getQuantity().setValue(0.0);
                        }
                        if (nutrient.getQuantity().getUnit() == null || nutrient.getQuantity().getUnit().isEmpty()) {
                            nutrient.getQuantity().setUnit(getDefaultUnit(type));
                        }
                    }
                    normalizedMap.put(type, nutrient);
                }
            }
        }

        // 2. Ensure all required core nutrients are present
        for (NutrientType type : NutrientType.values()) {
            if (!normalizedMap.containsKey(type)) {
                normalizedMap.put(type, new FoodNutrient(
                    type.getCanonicalName(),
                    new Quantity(0.0, getDefaultUnit(type))
                ));
            }
        }

        return new ArrayList<>(normalizedMap.values());
    }

    private static String getDefaultUnit(NutrientType type) {
        switch (type) {
            case CALORIES: return "kcal";
            case SODIUM: return "mg";
            default: return "g";
        }
    }
}
