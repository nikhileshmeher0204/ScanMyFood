package com.scanmyfood.backend.services;

import com.scanmyfood.backend.configurations.FirebaseConfig;
import com.scanmyfood.backend.mapper.UserIntakeMapper;
import com.scanmyfood.backend.models.FoodItem;
import com.scanmyfood.backend.models.FoodNutrient;
import com.scanmyfood.backend.models.Quantity;
import com.scanmyfood.backend.models.SaveScannedFoodInput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.scanmyfood.backend.constants.NutrientConstants.*;

@Service
public class UserIntakeServiceImpl implements UserIntakeService {

    private static final Logger logger = LoggerFactory.getLogger(UserIntakeServiceImpl.class);

    @Autowired
    private UserIntakeMapper userIntakeMapper;

    @Override
    public void saveIntake(SaveScannedFoodInput saveIntakeInput) {
        try {
            // Insert food analysis record
            Map<String, Quantity> nutrientMap = saveIntakeInput.getFoodAnalysisResponse()
                    .getTotalPlateNutrients()
                    .stream()
                    .collect(Collectors.toMap(
                            FoodNutrient::getName,
                            FoodNutrient::getQuantity
                    ));

            Integer foodAnalysisId = userIntakeMapper.insertFoodAnalysis(
                    saveIntakeInput.getUserId(),
                    saveIntakeInput.getFoodAnalysisResponse().getMealName(),
                    nutrientMap.get(CALORIES).getValue(), nutrientMap.get(CALORIES).getUnit(),
                    nutrientMap.get(PROTEIN).getValue(), nutrientMap.get(PROTEIN).getUnit(),
                    nutrientMap.get(CARBOHYDRATES).getValue(), nutrientMap.get(CARBOHYDRATES).getUnit(),
                    nutrientMap.get(FAT).getValue(), nutrientMap.get(FAT).getUnit(),
                    nutrientMap.get(FIBER).getValue(), nutrientMap.get(FIBER).getUnit(),
                    nutrientMap.get(SUGAR).getValue(), nutrientMap.get(SUGAR).getUnit(),
                    nutrientMap.get(SODIUM).getValue(), nutrientMap.get(SODIUM).getUnit()

            );


            // insert food items
            List<FoodItem> foodItems = saveIntakeInput.getFoodAnalysisResponse().getAnalyzedFoodItems();
            for (FoodItem foodItem : foodItems) {
                List<FoodNutrient> nutrients = foodItem.getNutrients();
                Map<String, Quantity> itemNutrientMap = nutrients.stream().collect(Collectors.toMap(FoodNutrient::getName, FoodNutrient::getQuantity));
                double actualQuantityValue = foodItem.getQuantity().getValue();
                String actualQuantityUnit = foodItem.getQuantity().getUnit();
                double factor = 100.0 / actualQuantityValue;
                Integer foodItemId = userIntakeMapper.insertFoodItem(foodItem.getName(),
                        itemNutrientMap.get(CALORIES).getValue() * factor, itemNutrientMap.get(CALORIES).getUnit(),
                        itemNutrientMap.get(PROTEIN).getValue() * factor, itemNutrientMap.get(PROTEIN).getUnit(),
                        itemNutrientMap.get(CARBOHYDRATES).getValue() * factor, itemNutrientMap.get(CARBOHYDRATES).getUnit(),
                        itemNutrientMap.get(FAT).getValue() * factor, itemNutrientMap.get(FAT).getUnit(),
                        itemNutrientMap.get(FIBER).getValue() * factor, itemNutrientMap.get(FIBER).getUnit(),
                        itemNutrientMap.get(SUGAR).getValue() * factor, itemNutrientMap.get(SUGAR).getUnit(),
                        itemNutrientMap.get(SODIUM).getValue() * factor, itemNutrientMap.get(SODIUM).getUnit(),
                        saveIntakeInput.getUserId());

                // map food items to food analysis record
                userIntakeMapper.insertFoodAnalysisItem(
                        foodAnalysisId,
                        foodItemId,
                        actualQuantityValue,
                        actualQuantityUnit
                );
            }
        } catch (Exception exception) {
            logger.error("Error saving user intake: {}", exception.getMessage(), exception);
        }
    }
}
