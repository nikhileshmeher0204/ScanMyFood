package com.scanmyfood.backend.services;

import com.scanmyfood.backend.mapper.UserIntakeMapper;
import com.scanmyfood.backend.models.*;
import com.scanmyfood.backend.services.storage.FileStorageService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.scanmyfood.backend.constants.NutrientConstants.*;

@Service
public class UserIntakeServiceImpl implements UserIntakeService {

    private static final Logger logger = LoggerFactory.getLogger(UserIntakeServiceImpl.class);

    @Autowired
    private UserIntakeMapper userIntakeMapper;

    @Autowired
    FileStorageService fileStorageService;

    @Override
    public void saveIntake(SaveScannedFoodInput saveIntakeInput, String imageAccessUrl) {
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
                    imageAccessUrl,
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

    @Override
    public UserIntakeOutput getUserIntake(String userId, LocalDate date) throws Exception {
        try {
            UserIntakeOutput output = new UserIntakeOutput();
            List<FoodNutrient> totalNutrients = new ArrayList<>();
            List<FoodAnalysisRecord> records = userIntakeMapper.fetchUserIntake(userId, date);
            logger.info("User intake records for date {}: {}", date, records.size());
            if (!records.isEmpty()) {
                logger.info("Calculating total nutrients");
                totalNutrients = getTotalValues(records);
                records.forEach(foodAnalysisRecord -> {
                    if (foodAnalysisRecord.getImageUrl() != null) {
                        foodAnalysisRecord.setImageUrl(fileStorageService.getAccessUrl(foodAnalysisRecord.getImageUrl()));
                    }
                });
            }
            output.setUserId(userId);
            output.setDate(date);
            output.setTotalNutrients(totalNutrients);
            output.setFoodAnalysisResponse(records);
            return output;
        } catch (Exception exception) {
            logger.error("Error fetching user intake: {}", exception.getMessage(), exception);
            throw new Exception("Error fetching user intake", exception);
        }
    }

    private List<FoodNutrient> getTotalValues(List<FoodAnalysisRecord> records) {

        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;
        double totalSugar = 0;
        double totalSodium = 0;

        for (FoodAnalysisRecord record : records) {
            totalCalories += record.getCaloriesValue();
            totalProtein += record.getProteinValue();
            totalCarbs += record.getCarbohydratesValue();
            totalFat += record.getFatValue();
            totalFiber += record.getFiberValue();
            totalSugar += record.getSugarValue();
            totalSodium += record.getSodiumValue();
        }

        List<FoodNutrient> totalNutrients = new ArrayList<>();

        totalNutrients.add(new FoodNutrient(CALORIES, new Quantity(totalCalories, records.get(0).getCaloriesUnit())));
        totalNutrients.add(new FoodNutrient(PROTEIN, new Quantity(totalProtein, records.get(0).getProteinUnit())));
        totalNutrients.add(new FoodNutrient(CARBOHYDRATES, new Quantity(totalCarbs, records.get(0).getCarbohydratesUnit())));
        totalNutrients.add(new FoodNutrient(FAT, new Quantity(totalFat, records.get(0).getFatUnit())));
        totalNutrients.add(new FoodNutrient(FIBER, new Quantity(totalFiber, records.get(0).getFiberUnit())));
        totalNutrients.add(new FoodNutrient(SUGAR, new Quantity(totalSugar, records.get(0).getSugarUnit())));
        totalNutrients.add(new FoodNutrient(SODIUM, new Quantity(totalSodium, records.get(0).getSodiumUnit())));

        return totalNutrients;
    }

}
