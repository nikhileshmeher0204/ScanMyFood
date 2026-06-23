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
import java.util.HashMap;
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
    private UserService userService;

    @Override
    public int saveScannedFoodIntake(SaveScannedFoodInput saveIntakeInput, String imageAccessUrl) throws Exception {
        try {
            User user = userService.getUserByUserId(saveIntakeInput.getUserId());
            String countryCode = CountryCode.fromCountryName(user.getCountry()).getCode();

            List<FoodItem> foodItems = saveIntakeInput.getFoodAnalysisResponse().getAnalyzedFoodItems();
            List<ProcessedFoodItemInfo> processedItems = new ArrayList<>();

            for (FoodItem foodItem : foodItems) {
                double actualQuantityValue = foodItem.getQuantity().getValue();
                if (actualQuantityValue <= 0) {
                    actualQuantityValue = 100.0;
                }
                String actualQuantityUnit = foodItem.getQuantity().getUnit();
                double factor = 100.0 / actualQuantityValue;

                // Step 1: Check by regional name in alias table
                FoodItemRecord dbFoodItem = userIntakeMapper.findFoodItemByAlias(foodItem.getName(), countryCode);
                
                if (dbFoodItem == null) {
                    String canonicalName = foodItem.getCanonicalName();
                    if (canonicalName == null || canonicalName.trim().isEmpty()) {
                        String name = foodItem.getName();
                        if (name == null || name.trim().isEmpty()) {
                            name = "unknown_food_item";
                        }
                        canonicalName = name.toLowerCase()
                                .replaceAll("[^a-z0-9\\s-]", "")
                                .trim()
                                .replaceAll("[\\s-]+", "_");
                        if (canonicalName.isEmpty()) {
                            canonicalName = "unknown_food_item";
                        }
                    }

                    // Step 2: Check by canonical name in food_item table
                    dbFoodItem = userIntakeMapper.findFoodItemByCanonical(canonicalName);
                    if (dbFoodItem != null) {
                        // Create new country alias mapping
                        userIntakeMapper.insertFoodItemAlias(dbFoodItem.getId(), countryCode, foodItem.getName());
                        dbFoodItem.setItemName(foodItem.getName());
                    } else {
                        // Step 3: Insert new food_item and food_item_alias
                        List<FoodNutrient> nutrients = foodItem.getNutrients();
                        Map<String, Quantity> itemNutrientMap = nutrients.stream()
                                .collect(Collectors.toMap(FoodNutrient::getName, FoodNutrient::getQuantity));
                        
                        Integer newFoodItemId = userIntakeMapper.insertFoodItem(
                                canonicalName,
                                round(itemNutrientMap.get(CALORIES).getValue() * factor), itemNutrientMap.get(CALORIES).getUnit(),
                                round(itemNutrientMap.get(PROTEIN).getValue() * factor), itemNutrientMap.get(PROTEIN).getUnit(),
                                round(itemNutrientMap.get(TOTAL_CARBOHYDRATE).getValue() * factor), itemNutrientMap.get(TOTAL_CARBOHYDRATE).getUnit(),
                                round(itemNutrientMap.get(TOTAL_FAT).getValue() * factor), itemNutrientMap.get(TOTAL_FAT).getUnit(),
                                round(itemNutrientMap.get(DIETARY_FIBER).getValue() * factor), itemNutrientMap.get(DIETARY_FIBER).getUnit(),
                                round(itemNutrientMap.get(TOTAL_SUGARS).getValue() * factor), itemNutrientMap.get(TOTAL_SUGARS).getUnit(),
                                round(itemNutrientMap.get(SODIUM).getValue() * factor), itemNutrientMap.get(SODIUM).getUnit(),
                                saveIntakeInput.getUserId()
                        );
                        userIntakeMapper.insertFoodItemAlias(newFoodItemId, countryCode, foodItem.getName());
                        
                        // Fetch the newly created record
                        dbFoodItem = userIntakeMapper.findFoodItemByCanonical(canonicalName);
                        dbFoodItem.setItemName(foodItem.getName());
                    }
                }

                // Override item nutrients using DB values (per 100g) and portion factor
                double portionFactor = actualQuantityValue / 100.0;
                List<FoodNutrient> overriddenNutrients = new ArrayList<>();
                overriddenNutrients.add(new FoodNutrient(CALORIES, new Quantity(round(safeDouble(dbFoodItem.getCaloriesValuePer100g()) * portionFactor), dbFoodItem.getCaloriesUnit())));
                overriddenNutrients.add(new FoodNutrient(PROTEIN, new Quantity(round(safeDouble(dbFoodItem.getProteinValuePer100g()) * portionFactor), dbFoodItem.getProteinUnit())));
                overriddenNutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(safeDouble(dbFoodItem.getTotalCarbohydrateValuePer100g()) * portionFactor), dbFoodItem.getTotalCarbohydrateUnit())));
                overriddenNutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(safeDouble(dbFoodItem.getTotalFatValuePer100g()) * portionFactor), dbFoodItem.getTotalFatUnit())));
                overriddenNutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(safeDouble(dbFoodItem.getDietaryFiberValuePer100g()) * portionFactor), dbFoodItem.getDietaryFiberUnit())));
                overriddenNutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(safeDouble(dbFoodItem.getTotalSugarsValuePer100g()) * portionFactor), dbFoodItem.getTotalSugarsUnit())));
                overriddenNutrients.add(new FoodNutrient(SODIUM, new Quantity(round(safeDouble(dbFoodItem.getSodiumValuePer100g()) * portionFactor), dbFoodItem.getSodiumUnit())));

                foodItem.setNutrients(overriddenNutrients);
                foodItem.setName(dbFoodItem.getItemName()); // Ensure name matches the exact DB display name casing
                foodItem.setCanonicalName(dbFoodItem.getCanonicalName());

                processedItems.add(new ProcessedFoodItemInfo(dbFoodItem.getId(), actualQuantityValue, actualQuantityUnit));
            }

            // Recalculate daily intake's total plate nutrients based on the overridden items
            recalculateTotalPlateNutrients(saveIntakeInput.getFoodAnalysisResponse());

            // Insert daily_intake record
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
                    nutrientMap.get(SODIUM).getValue(), nutrientMap.get(SODIUM).getUnit(),
                    saveIntakeInput.getCreatedAt()
            );

            // Link daily intake to food items in the junction table
            for (ProcessedFoodItemInfo item : processedItems) {
                userIntakeMapper.insertFoodAnalysisItem(
                        dailyIntakeId,
                        item.getFoodItemId(),
                        item.getQuantityValue(),
                        item.getQuantityUnit()
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
                    nutrientMap.get(CALCIUM).getValue(), nutrientMap.get(CALCIUM).getUnit(),
                    scannedLabelInput.getCreatedAt()
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
                    round(nutrientMap.get(ENERGY).getValue() * factor), nutrientMap.get(ENERGY).getUnit(),
                    round(nutrientMap.get(PROTEIN).getValue() * factor), nutrientMap.get(PROTEIN).getUnit(),
                    round(nutrientMap.get(TOTAL_CARBOHYDRATE).getValue() * factor), nutrientMap.get(TOTAL_CARBOHYDRATE).getUnit(),
                    round(nutrientMap.get(TOTAL_FAT).getValue() * factor), nutrientMap.get(TOTAL_FAT).getUnit(),
                    round(nutrientMap.get(SATURATED_FAT).getValue() * factor), nutrientMap.get(SATURATED_FAT).getUnit(),
                    round(nutrientMap.get(TRANS_FAT).getValue()), nutrientMap.get(TRANS_FAT).getUnit(),
                    round(nutrientMap.get(DIETARY_FIBER).getValue() * factor), nutrientMap.get(DIETARY_FIBER).getUnit(),
                    round(nutrientMap.get(TOTAL_SUGARS).getValue()), nutrientMap.get(TOTAL_SUGARS).getUnit(),
                    round(nutrientMap.get(ADDED_SUGARS).getValue() * factor), nutrientMap.get(ADDED_SUGARS).getUnit(),
                    round(nutrientMap.get(SODIUM).getValue() * factor), nutrientMap.get(SODIUM).getUnit(),
                    round(nutrientMap.get(IRON).getValue() * factor), nutrientMap.get(IRON).getUnit(),
                    round(nutrientMap.get(POTASSIUM).getValue() * factor), nutrientMap.get(POTASSIUM).getUnit(),
                    round(nutrientMap.get(CALCIUM).getValue() * factor), nutrientMap.get(CALCIUM).getUnit(),
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
        return getUserIntakeRange(userId, date, date);
    }

    @Override
    public UserIntakeOutput getUserIntakeRange(String userId, LocalDate fromDate, LocalDate toDate) throws Exception {
        try {
            UserIntakeOutput output = new UserIntakeOutput();
            output.setUserId(userId);
            List<DailyIntakeData> dailyIntakes = new ArrayList<>();

            List<DailyIntakeRecord> records = userIntakeMapper.fetchUserIntakeRange(userId, fromDate, toDate);
            logger.info("User intake records for date range {} to {}: {}", fromDate, toDate, records.size());

            User user = userService.getUserByUserId(userId);
            String countryCode = CountryCode.fromCountryName(user.getCountry()).getCode();

            // Fetch and map constituent food items for each record
            for (DailyIntakeRecord record : records) {
                List<FoodItem> foodItems = new ArrayList<>();
                List<FoodItemRecord> foodItemRecords = userIntakeMapper.fetchFoodItemsByDailyIntakeId(record.getId(), countryCode);
                for (FoodItemRecord itemRecord : foodItemRecords) {
                    FoodItem foodItem = new FoodItem();
                    foodItem.setName(itemRecord.getItemName());
                    foodItem.setCanonicalName(itemRecord.getCanonicalName());
                    foodItem.setQuantity(new Quantity(itemRecord.getQuantityValue(), itemRecord.getQuantityUnit()));
                    
                    List<FoodNutrient> nutrients = new ArrayList<>();
                    double factor = safeDouble(itemRecord.getQuantityValue()) / 100.0;
                    nutrients.add(new FoodNutrient(CALORIES, new Quantity(round(safeDouble(itemRecord.getCaloriesValuePer100g()) * factor), itemRecord.getCaloriesUnit())));
                    nutrients.add(new FoodNutrient(PROTEIN, new Quantity(round(safeDouble(itemRecord.getProteinValuePer100g()) * factor), itemRecord.getProteinUnit())));
                    nutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(safeDouble(itemRecord.getTotalCarbohydrateValuePer100g()) * factor), itemRecord.getTotalCarbohydrateUnit())));
                    nutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(safeDouble(itemRecord.getTotalFatValuePer100g()) * factor), itemRecord.getTotalFatUnit())));
                    nutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(safeDouble(itemRecord.getDietaryFiberValuePer100g()) * factor), itemRecord.getDietaryFiberUnit())));
                    nutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(safeDouble(itemRecord.getTotalSugarsValuePer100g()) * factor), itemRecord.getTotalSugarsUnit())));
                    nutrients.add(new FoodNutrient(SODIUM, new Quantity(round(safeDouble(itemRecord.getSodiumValuePer100g()) * factor), itemRecord.getSodiumUnit())));
                    
                    foodItem.setNutrients(nutrients);
                    foodItems.add(foodItem);
                }
                record.setFoodItems(foodItems);
            }

            // Group records by local date
            Map<LocalDate, List<DailyIntakeRecord>> groupedByDate = records.stream()
                    .collect(Collectors.groupingBy(
                            record -> record.getCreatedAt().toLocalDateTime().toLocalDate()
                    ));

            // Generate explicit entries for all dates in the range (inclusive)
            for (LocalDate date = fromDate; !date.isAfter(toDate); date = date.plusDays(1)) {
                DailyIntakeData dayData = new DailyIntakeData();
                dayData.setDate(date);
                List<DailyIntakeRecord> dayRecords = groupedByDate.getOrDefault(date, new ArrayList<>());
                List<FoodNutrient> totalNutrients = new ArrayList<>();
                if (!dayRecords.isEmpty()) {
                    setTotalValues(dayRecords, totalNutrients);
                }
                dayData.setTotalNutrients(totalNutrients);
                dayData.setDailyIntake(dayRecords);
                dailyIntakes.add(dayData);
            }

            output.setDailyIntakes(dailyIntakes);
            return output;
        } catch (Exception exception) {
            logger.error("Error fetching user intake range: {}", exception.getMessage(), exception);
            throw new Exception("Error fetching user intake range", exception);
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

    @Override
    public FoodAnalysisResponse getIntakeDetails(String userId, int dailyIntakeId) throws Exception {
        try{
            FoodAnalysisResponse intakeResponse = new FoodAnalysisResponse();
            List<FoodNutrient> totalNutrients = new ArrayList<>();
            List<FoodItem> foodItems = new ArrayList<>();
            DailyIntakeRecord intakeRecord = userIntakeMapper.fetchIntakeById(userId, dailyIntakeId);
            if (intakeRecord.getCaloriesValue() != null && intakeRecord.getCaloriesValue() != 0) {
                totalNutrients.add(
                        new FoodNutrient(
                                CALORIES,
                                new Quantity(intakeRecord.getCaloriesValue(), intakeRecord.getCaloriesUnit())
                        )
                );
            } else if (intakeRecord.getEnergyValue() != null && intakeRecord.getEnergyValue() != 0) {
                totalNutrients.add(
                        new FoodNutrient(
                                ENERGY,
                                new Quantity(intakeRecord.getEnergyValue(), intakeRecord.getEnergyUnit())
                        )
                );
            }
            totalNutrients.add(new FoodNutrient(PROTEIN, new Quantity(intakeRecord.getProteinValue(), intakeRecord.getProteinUnit())));
            totalNutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(intakeRecord.getTotalCarbohydrateValue(), intakeRecord.getTotalCarbohydrateUnit())));
            totalNutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(intakeRecord.getTotalFatValue(), intakeRecord.getTotalFatUnit())));
            totalNutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(intakeRecord.getDietaryFiberValue(), intakeRecord.getDietaryFiberUnit())));
            totalNutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(intakeRecord.getTotalSugarsValue(), intakeRecord.getTotalSugarsUnit())));
            totalNutrients.add(new FoodNutrient(SODIUM, new Quantity(intakeRecord.getSodiumValue(), intakeRecord.getSodiumUnit())));
            User user = userService.getUserByUserId(userId);
            String countryCode = CountryCode.fromCountryName(user.getCountry()).getCode();
            List<FoodItemRecord> foodItemRecords = userIntakeMapper.fetchFoodItemsByDailyIntakeId(dailyIntakeId, countryCode);
            for(FoodItemRecord record : foodItemRecords) {
                FoodItem foodItem = new FoodItem();
                foodItem.setName(record.getItemName());
                foodItem.setCanonicalName(record.getCanonicalName());
                foodItem.setQuantity(new Quantity(record.getQuantityValue(), record.getQuantityUnit()));
                List<FoodNutrient> nutrients = new ArrayList<>();
                double factor = safeDouble(record.getQuantityValue()) / 100.0;
                nutrients.add(new FoodNutrient(CALORIES, new Quantity(round(safeDouble(record.getCaloriesValuePer100g()) * factor), record.getCaloriesUnit())));
                nutrients.add(new FoodNutrient(PROTEIN, new Quantity(round(safeDouble(record.getProteinValuePer100g()) * factor), record.getProteinUnit())));
                nutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(safeDouble(record.getTotalCarbohydrateValuePer100g()) * factor), record.getTotalCarbohydrateUnit())));
                nutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(safeDouble(record.getTotalFatValuePer100g()) * factor), record.getTotalFatUnit())));
                nutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(safeDouble(record.getDietaryFiberValuePer100g()) * factor), record.getDietaryFiberUnit())));
                nutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(safeDouble(record.getTotalSugarsValuePer100g()) * factor), record.getTotalSugarsUnit())));
                nutrients.add(new FoodNutrient(SODIUM, new Quantity(round(safeDouble(record.getSodiumValuePer100g()) * factor), record.getSodiumUnit())));
                foodItem.setNutrients(nutrients);
                foodItems.add(foodItem);
            }
            intakeResponse.setMealName(intakeRecord.getIntakeName());
            intakeResponse.setAnalyzedFoodItems(foodItems);
            intakeResponse.setTotalPlateNutrients(totalNutrients);
            return intakeResponse;
        }catch (Exception exception){
            throw new Exception("Error fetching user intake", exception);
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
            totalCalories += safeDouble(record.getCaloriesValue());
            totalProtein += safeDouble(record.getProteinValue());
            totalCarbs += safeDouble(record.getTotalCarbohydrateValue());
            totalFat += safeDouble(record.getTotalFatValue());
            totalFiber += safeDouble(record.getDietaryFiberValue());
            totalSugar += safeDouble(record.getTotalSugarsValue());
            totalSodium += safeDouble(record.getSodiumValue());
            totalIron += safeDouble(record.getIronValue());
            totalPotassium += safeDouble(record.getPotassiumValue());
            totalCalcium += safeDouble(record.getCalciumValue());
        }

        String caloriesUnit = records.get(0).getCaloriesUnit() != null ? records.get(0).getCaloriesUnit() : "kcal";
        String proteinUnit = records.get(0).getProteinUnit() != null ? records.get(0).getProteinUnit() : "g";
        String carbohydrateUnit = records.get(0).getTotalCarbohydrateUnit() != null ? records.get(0).getTotalCarbohydrateUnit() : "g";
        String fatUnit = records.get(0).getTotalFatUnit() != null ? records.get(0).getTotalFatUnit() : "g";
        String fiberUnit = records.get(0).getDietaryFiberUnit() != null ? records.get(0).getDietaryFiberUnit() : "g";
        String sugarsUnit = records.get(0).getTotalSugarsUnit() != null ? records.get(0).getTotalSugarsUnit() : "g";
        String sodiumUnit = records.get(0).getSodiumUnit() != null ? records.get(0).getSodiumUnit() : "mg";
        String ironUnit = records.get(0).getIronUnit() != null ? records.get(0).getIronUnit() : "mg";
        String potassiumUnit = records.get(0).getPotassiumUnit() != null ? records.get(0).getPotassiumUnit() : "mg";
        String calciumUnit = records.get(0).getCalciumUnit() != null ? records.get(0).getCalciumUnit() : "mg";

        totalNutrients.add(new FoodNutrient(CALORIES, new Quantity(round(totalCalories), caloriesUnit)));
        totalNutrients.add(new FoodNutrient(PROTEIN, new Quantity(round(totalProtein), proteinUnit)));
        totalNutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(totalCarbs), carbohydrateUnit)));
        totalNutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(totalFat), fatUnit)));
        totalNutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(totalFiber), fiberUnit)));
        totalNutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(totalSugar), sugarsUnit)));
        totalNutrients.add(new FoodNutrient(SODIUM, new Quantity(round(totalSodium), sodiumUnit)));
        totalNutrients.add(new FoodNutrient(IRON, new Quantity(round(totalIron), ironUnit)));
        totalNutrients.add(new FoodNutrient(POTASSIUM, new Quantity(round(totalPotassium), potassiumUnit)));
        totalNutrients.add(new FoodNutrient(CALCIUM, new Quantity(round(totalCalcium), calciumUnit)));
    }

    private double safeDouble(Double val) {
        return val == null ? 0.0 : val;
    }

    private double round(double val) {
        return Math.round(val * 100.0) / 100.0;
    }

    private void recalculateTotalPlateNutrients(FoodAnalysisResponse response) {
        PlateNutrients plateNutrients = new PlateNutrients();
        for (FoodItem item : response.getAnalyzedFoodItems()) {
            plateNutrients.addFoodItem(item);
        }
        response.setTotalPlateNutrients(plateNutrients.toFoodNutrientList());
    }

    private static class ProcessedFoodItemInfo {
        private final Integer foodItemId;
        private final double quantityValue;
        private final String quantityUnit;

        public ProcessedFoodItemInfo(Integer foodItemId, double quantityValue, String quantityUnit) {
            this.foodItemId = foodItemId;
            this.quantityValue = quantityValue;
            this.quantityUnit = quantityUnit;
        }

        public Integer getFoodItemId() {
            return foodItemId;
        }

        public double getQuantityValue() {
            return quantityValue;
        }

        public String getQuantityUnit() {
            return quantityUnit;
        }
    }

}
