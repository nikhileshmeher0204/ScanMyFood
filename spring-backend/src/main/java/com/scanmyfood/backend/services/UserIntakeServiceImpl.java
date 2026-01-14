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

    @Override
    public int saveScannedFoodIntake(SaveScannedFoodInput saveIntakeInput, String imageAccessUrl) throws Exception {
        try {
            // Insert food analysis record
            Map<String, Quantity> nutrientMap = saveIntakeInput.getFoodAnalysisResponse()
                    .getTotalPlateNutrients()
                    .stream()
                    .collect(Collectors.toMap(
                            FoodNutrient::getName,
                            FoodNutrient::getQuantity
                    ));

            Integer dailyIntakeId = userIntakeMapper.insertFoodAnalysis(
                    saveIntakeInput.getUserId(),
                    saveIntakeInput.getFoodAnalysisResponse().getMealName(),
                    imageAccessUrl,
                    saveIntakeInput.getSourceOfIntake(),
                    nutrientMap.get(CALORIES).getValue(), nutrientMap.get(CALORIES).getUnit(),
                    nutrientMap.get(PROTEIN).getValue(), nutrientMap.get(PROTEIN).getUnit(),
                    nutrientMap.get(TOTAL_CARBOHYDRATE).getValue(), nutrientMap.get(TOTAL_CARBOHYDRATE).getUnit(),
                    nutrientMap.get(TOTAL_FAT).getValue(), nutrientMap.get(TOTAL_FAT).getUnit(),
                    nutrientMap.get(DIETARY_FIBER).getValue(), nutrientMap.get(DIETARY_FIBER).getUnit(),
                    nutrientMap.get(TOTAL_SUGARS).getValue(), nutrientMap.get(TOTAL_SUGARS).getUnit(),
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
                        itemNutrientMap.get(TOTAL_CARBOHYDRATE).getValue() * factor, itemNutrientMap.get(TOTAL_CARBOHYDRATE).getUnit(),
                        itemNutrientMap.get(TOTAL_FAT).getValue() * factor, itemNutrientMap.get(TOTAL_FAT).getUnit(),
                        itemNutrientMap.get(DIETARY_FIBER).getValue() * factor, itemNutrientMap.get(DIETARY_FIBER).getUnit(),
                        itemNutrientMap.get(TOTAL_SUGARS).getValue() * factor, itemNutrientMap.get(TOTAL_SUGARS).getUnit(),
                        itemNutrientMap.get(SODIUM).getValue() * factor, itemNutrientMap.get(SODIUM).getUnit(),
                        saveIntakeInput.getUserId());

                // map food items to food analysis record
                userIntakeMapper.insertFoodAnalysisItem(
                        dailyIntakeId,
                        foodItemId,
                        actualQuantityValue,
                        actualQuantityUnit
                );
            }
            return dailyIntakeId;
        } catch (Exception exception) {
            logger.error("Error saving user intake: {}", exception.getMessage(), exception);
            throw new Exception("Error saving user intake", exception);
        }
    }

    @Override
    public int saveScannedLabelIntake(SaveScannedLabelInput scannedLabelInput, String imageAccessUrl) throws Exception {
        try {
            ProductAnalysisResponse productAnalysis = scannedLabelInput.getProductAnalysisResponse();
            
            // Extract nutrients
            Map<String, Quantity> nutrientMap = productAnalysis.getNutritionAnalysis()
                    .getNutrients()
                    .stream()
                    .collect(Collectors.toMap(
                            Nutrient::getName,
                            Nutrient::getQuantity
                    ));

            // Insert food analysis record (aggregated consumption data)
            Integer dailyIntakeId = userIntakeMapper.insertProductAnalysis(
                    scannedLabelInput.getUserId(),
                    productAnalysis.getProduct().getName(),
                    imageAccessUrl,
                    scannedLabelInput.getSourceOfIntake(),
                    nutrientMap.get(ENERGY).getValue(), nutrientMap.get(ENERGY).getUnit(),
                    nutrientMap.get(PROTEIN).getValue(), nutrientMap.get(PROTEIN).getUnit(),
                    nutrientMap.get(TOTAL_CARBOHYDRATE).getValue(), nutrientMap.get(TOTAL_CARBOHYDRATE).getUnit(),
                    nutrientMap.get(TOTAL_FAT).getValue(), nutrientMap.get(TOTAL_FAT).getUnit(),
                    nutrientMap.get(SATURATED_FAT).getValue(), nutrientMap.get(SATURATED_FAT).getUnit(),
                    nutrientMap.get(TRANS_FAT).getValue(), nutrientMap.get(TRANS_FAT).getUnit(),
                    nutrientMap.get(DIETARY_FIBER).getValue(), nutrientMap.get(DIETARY_FIBER).getUnit(),
                    nutrientMap.get(TOTAL_SUGARS).getValue(), nutrientMap.get(TOTAL_SUGARS).getUnit(),
                    nutrientMap.get(ADDED_SUGARS).getValue(), nutrientMap.get(ADDED_SUGARS).getUnit(),
                    nutrientMap.get(SODIUM).getValue(), nutrientMap.get(SODIUM).getUnit(),
                    nutrientMap.get(IRON).getValue(), nutrientMap.get(IRON).getUnit(),
                    nutrientMap.get(POTASSIUM).getValue(), nutrientMap.get(POTASSIUM).getUnit(),
                    nutrientMap.get(CALCIUM).getValue(), nutrientMap.get(CALCIUM).getUnit()
            );

            // Normalize nutrients to per 100g
            Quantity totalQuantity = productAnalysis.getNutritionAnalysis().getTotalQuantity();
            double factor = 100.0 / totalQuantity.getValue();

            // Insert product label (reusable product information)
            Integer productLabelId = userIntakeMapper.insertProductLabel(
                    productAnalysis.getProduct().getName(),
                    productAnalysis.getProduct().getCategory(),
                    totalQuantity.getValue(),
                    totalQuantity.getUnit(),
                    productAnalysis.getNutritionAnalysis().getServingSize().getValue(),
                    productAnalysis.getNutritionAnalysis().getServingSize().getUnit(),
                    nutrientMap.get(ENERGY).getValue() * factor, nutrientMap.get(ENERGY).getUnit(),
                    nutrientMap.get(PROTEIN).getValue() * factor, nutrientMap.get(PROTEIN).getUnit(),
                    nutrientMap.get(TOTAL_CARBOHYDRATE).getValue() * factor, nutrientMap.get(TOTAL_CARBOHYDRATE).getUnit(),
                    nutrientMap.get(TOTAL_FAT).getValue() * factor, nutrientMap.get(TOTAL_FAT).getUnit(),
                    nutrientMap.get(SATURATED_FAT).getValue() * factor, nutrientMap.get(SATURATED_FAT).getUnit(),
                    nutrientMap.get(TRANS_FAT).getValue(), nutrientMap.get(TRANS_FAT).getUnit(),
                    nutrientMap.get(DIETARY_FIBER).getValue() * factor, nutrientMap.get(DIETARY_FIBER).getUnit(),
                    nutrientMap.get(TOTAL_SUGARS).getValue(), nutrientMap.get(TOTAL_SUGARS).getUnit(),
                    nutrientMap.get(ADDED_SUGARS).getValue() * factor, nutrientMap.get(ADDED_SUGARS).getUnit(),
                    nutrientMap.get(SODIUM).getValue() * factor, nutrientMap.get(SODIUM).getUnit(),
                    nutrientMap.get(IRON).getValue() * factor, nutrientMap.get(IRON).getUnit(),
                    nutrientMap.get(POTASSIUM).getValue() * factor, nutrientMap.get(POTASSIUM).getUnit(),
                    nutrientMap.get(CALCIUM).getValue() * factor, nutrientMap.get(CALCIUM).getUnit(),
                    scannedLabelInput.getUserId()
            );

            // Link daily intake to product label
            userIntakeMapper.insertFoodAnalysisProduct(
                    dailyIntakeId,
                    productLabelId,
                    totalQuantity.getValue(),
                    totalQuantity.getUnit()
            );

            // Store primary concerns and recommendations
            List<ProductAnalysisResponse.PrimaryConcern> concerns =
                    productAnalysis.getNutritionAnalysis().getPrimaryConcerns();
            
            if (concerns != null && !concerns.isEmpty()) {
                for (ProductAnalysisResponse.PrimaryConcern concern : concerns) {
                    Integer concernId = userIntakeMapper.insertProductPrimaryConcern(
                            productLabelId,
                            concern.getIssue(),
                            concern.getExplanation()
                    );

                    // Store recommendations for this concern
                    if (concern.getRecommendations() != null && !concern.getRecommendations().isEmpty()) {
                        for (ProductAnalysisResponse.Recommendation recommendation : concern.getRecommendations()) {
                            userIntakeMapper.insertConcernRecommendation(
                                    concernId,
                                    recommendation.getFood(),
                                    recommendation.getQuantity(),
                                    recommendation.getReasoning()
                            );
                        }
                    }
                }
            }
            return dailyIntakeId;
        } catch (Exception exception) {
            logger.error("Error saving scanned label intake: {}", exception.getMessage(), exception);
            throw new Exception("Error saving scanned label intake", exception);
        }
    }

    @Override
    public UserIntakeOutput getUserIntake(String userId, LocalDate date) throws Exception {
        try {
            UserIntakeOutput output = new UserIntakeOutput();
            List<FoodNutrient> totalNutrients = new ArrayList<>();
            List<DailyIntakeRecord> records = userIntakeMapper.fetchUserIntake(userId, date);
            logger.info("User intake records for date {}: {}", date, records.size());
            if (!records.isEmpty()) {
                logger.info("Calculating total nutrients");
                setTotalValues(records, totalNutrients);
            }
            output.setUserId(userId);
            output.setDate(date);
            output.setTotalNutrients(totalNutrients);
            output.setDailyIntake(records);
            return output;
        } catch (Exception exception) {
            logger.error("Error fetching user intake: {}", exception.getMessage(), exception);
            throw new Exception("Error fetching user intake", exception);
        }
    }

    @Override
    public void updateDailyIntakeImage(int dailyIntakeId, String imageAccessUrl) throws Exception {
        try {
            userIntakeMapper.updateDailyIntakeImageUrl(dailyIntakeId, imageAccessUrl);
        } catch (Exception exception) {
            logger.error("Error updating daily intake image: {}", exception.getMessage(), exception);
            throw new Exception("Error updating daily intake image", exception);
        }
    }

    private void setTotalValues(List<DailyIntakeRecord> records, List<FoodNutrient> totalNutrients) {

        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        double totalFiber = 0;
        double totalSugar = 0;
        double totalSodium = 0;
        double totalIron = 0;
        double totalPotassium = 0;
        double totalCalcium = 0;

        for (DailyIntakeRecord record : records) {
            totalCalories += record.getCaloriesValue();
            totalProtein += record.getProteinValue();
            totalCarbs += record.getTotalCarbohydrateValue();
            totalFat += record.getTotalFatValue();
            totalFiber += record.getDietaryFiberValue();
            totalSugar += record.getTotalSugarsValue();
            totalSodium += record.getSodiumValue();
            totalIron += record.getIronValue();
            totalPotassium += record.getPotassiumValue();
            totalCalcium += record.getCalciumValue();
        }

        totalNutrients.add(new FoodNutrient(CALORIES, new Quantity(totalCalories, records.get(0).getCaloriesUnit())));
        totalNutrients.add(new FoodNutrient(PROTEIN, new Quantity(totalProtein, records.get(0).getProteinUnit())));
        totalNutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(totalCarbs, records.get(0).getTotalCarbohydrateUnit())));
        totalNutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(totalFat, records.get(0).getTotalFatUnit())));
        totalNutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(totalFiber, records.get(0).getDietaryFiberUnit())));
        totalNutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(totalSugar, records.get(0).getTotalSugarsUnit())));
        totalNutrients.add(new FoodNutrient(SODIUM, new Quantity(totalSodium, records.get(0).getSodiumUnit())));
        totalNutrients.add(new FoodNutrient(IRON, new Quantity(totalIron, records.get(0).getIronUnit())));
        totalNutrients.add(new FoodNutrient(POTASSIUM, new Quantity(totalPotassium, records.get(0).getPotassiumUnit())));
        totalNutrients.add(new FoodNutrient(CALCIUM, new Quantity(totalCalcium, records.get(0).getCalciumUnit())));
    }

}
