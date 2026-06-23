package com.scanmyfood.backend.models;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;
import static com.scanmyfood.backend.constants.NutrientConstants.*;

@Data
public class PlateNutrients {
    private double calories = 0.0;
    private String caloriesUnit = "kcal";

    private double protein = 0.0;
    private String proteinUnit = "g";

    private double totalCarbohydrates = 0.0;
    private String totalCarbohydratesUnit = "g";

    private double totalFat = 0.0;
    private String totalFatUnit = "g";

    private double dietaryFiber = 0.0;
    private String dietaryFiberUnit = "g";

    private double totalSugars = 0.0;
    private String totalSugarsUnit = "g";

    private double sodium = 0.0;
    private String sodiumUnit = "mg";

    public void addFoodItem(FoodItem item) {
        if (item == null || item.getNutrients() == null) {
            return;
        }
        for (FoodNutrient nutrient : item.getNutrients()) {
            double value = nutrient.getQuantity().getValue();
            String unit = nutrient.getQuantity().getUnit();
            switch (nutrient.getName()) {
                case CALORIES:
                    this.calories += value;
                    if (unit != null) this.caloriesUnit = unit;
                    break;
                case PROTEIN:
                    this.protein += value;
                    if (unit != null) this.proteinUnit = unit;
                    break;
                case TOTAL_CARBOHYDRATE:
                    this.totalCarbohydrates += value;
                    if (unit != null) this.totalCarbohydratesUnit = unit;
                    break;
                case TOTAL_FAT:
                    this.totalFat += value;
                    if (unit != null) this.totalFatUnit = unit;
                    break;
                case DIETARY_FIBER:
                    this.dietaryFiber += value;
                    if (unit != null) this.dietaryFiberUnit = unit;
                    break;
                case TOTAL_SUGARS:
                    this.totalSugars += value;
                    if (unit != null) this.totalSugarsUnit = unit;
                    break;
                case SODIUM:
                    this.sodium += value;
                    if (unit != null) this.sodiumUnit = unit;
                    break;
            }
        }
    }

    private double round(double val) {
        return Math.round(val * 100.0) / 100.0;
    }

    public List<FoodNutrient> toFoodNutrientList() {
        List<FoodNutrient> list = new ArrayList<>();
        list.add(new FoodNutrient(CALORIES, new Quantity(round(calories), caloriesUnit)));
        list.add(new FoodNutrient(PROTEIN, new Quantity(round(protein), proteinUnit)));
        list.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(totalCarbohydrates), totalCarbohydratesUnit)));
        list.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(totalFat), totalFatUnit)));
        list.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(dietaryFiber), dietaryFiberUnit)));
        list.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(totalSugars), totalSugarsUnit)));
        list.add(new FoodNutrient(SODIUM, new Quantity(round(sodium), sodiumUnit)));
        return list;
    }
}
