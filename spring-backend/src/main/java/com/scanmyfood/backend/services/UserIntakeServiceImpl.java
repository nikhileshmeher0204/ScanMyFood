package com.scanmyfood.backend.services;

import com.scanmyfood.backend.mapper.UserIntakeMapper;
import com.scanmyfood.backend.models.*;
import com.scanmyfood.backend.services.storage.FileStorageService;
import com.scanmyfood.backend.utils.NutrientSanitizer;
import com.fasterxml.jackson.databind.ObjectMapper;
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

import com.scanmyfood.backend.events.MealLoggedEvent;
import com.scanmyfood.backend.utils.ByteArrayMultipartFile;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.web.multipart.MultipartFile;
import java.util.concurrent.CompletableFuture;

import static com.scanmyfood.backend.constants.NutrientConstants.*;

@Service
public class UserIntakeServiceImpl implements UserIntakeService {

    private static final Logger logger = LoggerFactory.getLogger(UserIntakeServiceImpl.class);

    @Autowired
    private UserIntakeMapper userIntakeMapper;

    @Autowired
    private UserService userService;

    @Autowired
    private AiService aiService;

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public int saveScannedFoodIntake(SaveScannedFoodInput saveIntakeInput, String imageAccessUrl) throws Exception {
        try {
            User user = userService.getUserByUserId(saveIntakeInput.getUserId());
            String countryCode = CountryCode.fromCountryName(user.getCountry()).getCode();

            List<FoodItem> foodItems = saveIntakeInput.getFoodAnalysisResponse().getAnalyzedFoodItems();
            
            // Clean/sanitize nutrients of food items defensively
            for (FoodItem foodItem : foodItems) {
                if (foodItem != null) {
                    foodItem.setNutrients(NutrientSanitizer.sanitize(foodItem.getNutrients()));
                }
            }

            // Prepare total nutrients map of the meal
            Map<String, Quantity> nutrientMap = saveIntakeInput.getFoodAnalysisResponse()
                    .getTotalPlateNutrients()
                    .stream()
                    .collect(Collectors.toMap(
                            FoodNutrient::getName,
                            FoodNutrient::getQuantity
                    ));

            String dailyIntakeImageUrl = imageAccessUrl;
            if ("SD".equalsIgnoreCase(saveIntakeInput.getSourceOfIntake()) && (dailyIntakeImageUrl == null || dailyIntakeImageUrl.isEmpty())) {
                dailyIntakeImageUrl = "GENERATING";
            }

            double mealPortion = saveIntakeInput.getFoodAnalysisResponse().getPortion() > 0 
                    ? saveIntakeInput.getFoodAnalysisResponse().getPortion() : 1.0;

            // 1. Insert into daily_intake (primary user log)
            Integer dailyIntakeId = userIntakeMapper.insertFoodAnalysis(
                    saveIntakeInput.getUserId(),
                    saveIntakeInput.getFoodAnalysisResponse().getMealName(),
                    dailyIntakeImageUrl,
                    saveIntakeInput.getSourceOfIntake(),
                    mealPortion,
                    saveIntakeInput.getUserId(),
                    saveIntakeInput.getUserId(),
                    saveIntakeInput.getCreatedAt(),
                    saveIntakeInput.getCreatedAt()
            );

            // 2. Insert constituent food items into food_item
            for (FoodItem foodItem : foodItems) {
                double qtyVal = foodItem.getQuantity() != null ? foodItem.getQuantity().getValue() : 100.0;
                if (qtyVal <= 0) {
                    qtyVal = 100.0;
                }
                String qtyUnit = foodItem.getQuantity() != null ? foodItem.getQuantity().getUnit() : "g";

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

                double itemPortion = foodItem.getPortion() > 0 ? foodItem.getPortion() : 1.0;

                userIntakeMapper.insertFoodItem(
                        dailyIntakeId,
                        foodItem.getName(),
                        canonicalName,
                        qtyVal,
                        qtyUnit,
                        itemPortion,
                        saveIntakeInput.getCreatedAt()
                );
            }

            // Publish event
            eventPublisher.publishEvent(new MealLoggedEvent(saveIntakeInput.getUserId(), dailyIntakeId));

            // If source is description-based (SD), trigger asynchronous image generation and notification update
            if ("SD".equalsIgnoreCase(saveIntakeInput.getSourceOfIntake()) && (imageAccessUrl == null || imageAccessUrl.isEmpty())) {
                final Integer finalDailyIntakeId = dailyIntakeId;
                final String mealName = saveIntakeInput.getFoodAnalysisResponse().getMealName();
                final String userId = saveIntakeInput.getUserId();
                CompletableFuture.runAsync(() -> {
                    try {
                        logger.info("Asynchronously generating image for daily intake {} (meal: {})", finalDailyIntakeId, mealName);
                        byte[] imageBytes = aiService.generateFoodImage(mealName);
                        if (imageBytes != null && imageBytes.length > 0) {
                            String filename = "generated_" + System.currentTimeMillis() + ".png";
                            MultipartFile imageFile = new ByteArrayMultipartFile(
                                    imageBytes,
                                    "generatedImage",
                                    filename,
                                    "image/png"
                            );
                            String storedPath = fileStorageService.store(imageFile, "generated-images");
                            String imageUrl = fileStorageService.getAccessUrl(storedPath);

                            // Update both daily_intake and constituent food_item tables
                            updateDailyIntakeImage(finalDailyIntakeId, imageUrl);
                            logger.info("Successfully updated async image for daily intake {} to {}", finalDailyIntakeId, imageUrl);

                            // Broadcast updated meal event to refresh the client UI to load the new image
                            eventPublisher.publishEvent(new MealLoggedEvent(userId, finalDailyIntakeId));
                        }
                    } catch (Exception e) {
                        logger.error("Error generating asynchronous image for daily intake: {}", e.getMessage(), e);
                    }
                });
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
                    round(safeDouble(safeGetNutrientValue(nutrientMap, ENERGY)) * factor), safeGetNutrientUnit(nutrientMap, ENERGY),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, PROTEIN)) * factor), safeGetNutrientUnit(nutrientMap, PROTEIN),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, TOTAL_CARBOHYDRATE)) * factor), safeGetNutrientUnit(nutrientMap, TOTAL_CARBOHYDRATE),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, TOTAL_FAT)) * factor), safeGetNutrientUnit(nutrientMap, TOTAL_FAT),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, SATURATED_FAT)) * factor), safeGetNutrientUnit(nutrientMap, SATURATED_FAT),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, TRANS_FAT)) * factor), safeGetNutrientUnit(nutrientMap, TRANS_FAT),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, DIETARY_FIBER)) * factor), safeGetNutrientUnit(nutrientMap, DIETARY_FIBER),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, TOTAL_SUGARS)) * factor), safeGetNutrientUnit(nutrientMap, TOTAL_SUGARS),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, ADDED_SUGARS)) * factor), safeGetNutrientUnit(nutrientMap, ADDED_SUGARS),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, SODIUM)) * factor), safeGetNutrientUnit(nutrientMap, SODIUM),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, IRON)) * factor), safeGetNutrientUnit(nutrientMap, IRON),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, POTASSIUM)) * factor), safeGetNutrientUnit(nutrientMap, POTASSIUM),
                    round(safeDouble(safeGetNutrientValue(nutrientMap, CALCIUM)) * factor), safeGetNutrientUnit(nutrientMap, CALCIUM),
                    scannedLabelInput.getUserId()
            );

            // Insert daily_intake record
            Integer dailyIntakeId = userIntakeMapper.insertFoodAnalysis(
                    scannedLabelInput.getUserId(),
                    productAnalysis.getProduct().getName(),
                    imageAccessUrl,
                    scannedLabelInput.getSourceOfIntake(),
                    1.0,
                    scannedLabelInput.getUserId(),
                    scannedLabelInput.getUserId(),
                    scannedLabelInput.getCreatedAt(),
                    scannedLabelInput.getCreatedAt()
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

            // Publish MealLoggedEvent for real-time notification synchronization
            eventPublisher.publishEvent(new MealLoggedEvent(scannedLabelInput.getUserId(), dailyIntakeId));

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
                    foodItem.setPortion(itemRecord.getPortion() != null ? itemRecord.getPortion() : 1.0);
                    double mealPortion = record.getPortion() != null ? record.getPortion() : 1.0;
                    double itemPortion = itemRecord.getPortion() != null ? itemRecord.getPortion() : 1.0;
                    double factor = (safeDouble(itemRecord.getQuantityValue()) / 100.0) * itemPortion * mealPortion;

                    foodItem.setQuantity(new Quantity(round(safeDouble(itemRecord.getQuantityValue()) * itemPortion * mealPortion), itemRecord.getQuantityUnit()));

                    List<FoodNutrient> nutrients = new ArrayList<>();
                    nutrients.add(new FoodNutrient(CALORIES, new Quantity(round(safeDouble(itemRecord.getCaloriesValuePer100g()) * factor), safeUnit(itemRecord.getCaloriesUnit(), "kcal"))));
                    nutrients.add(new FoodNutrient(PROTEIN, new Quantity(round(safeDouble(itemRecord.getProteinValuePer100g()) * factor), safeUnit(itemRecord.getProteinUnit(), "g"))));
                    nutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(safeDouble(itemRecord.getTotalCarbohydrateValuePer100g()) * factor), safeUnit(itemRecord.getTotalCarbohydrateUnit(), "g"))));
                    nutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(safeDouble(itemRecord.getTotalFatValuePer100g()) * factor), safeUnit(itemRecord.getTotalFatUnit(), "g"))));
                    nutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(safeDouble(itemRecord.getDietaryFiberValuePer100g()) * factor), safeUnit(itemRecord.getDietaryFiberUnit(), "g"))));
                    nutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(safeDouble(itemRecord.getTotalSugarsValuePer100g()) * factor), safeUnit(itemRecord.getTotalSugarsUnit(), "g"))));
                    nutrients.add(new FoodNutrient(SODIUM, new Quantity(round(safeDouble(itemRecord.getSodiumValuePer100g()) * factor), safeUnit(itemRecord.getSodiumUnit(), "mg"))));
                    
                    foodItem.setNutrients(nutrients);
                    foodItems.add(foodItem);

                    // Aggregate into record
                    record.setCaloriesValue(round(record.getCaloriesValue() + safeDouble(itemRecord.getCaloriesValuePer100g()) * factor));
                    record.setProteinValue(round(record.getProteinValue() + safeDouble(itemRecord.getProteinValuePer100g()) * factor));
                    record.setTotalCarbohydrateValue(round(record.getTotalCarbohydrateValue() + safeDouble(itemRecord.getTotalCarbohydrateValuePer100g()) * factor));
                    record.setTotalFatValue(round(record.getTotalFatValue() + safeDouble(itemRecord.getTotalFatValuePer100g()) * factor));
                    record.setDietaryFiberValue(round(record.getDietaryFiberValue() + safeDouble(itemRecord.getDietaryFiberValuePer100g()) * factor));
                    record.setTotalSugarsValue(round(record.getTotalSugarsValue() + safeDouble(itemRecord.getTotalSugarsValuePer100g()) * factor));
                    record.setSodiumValue(round(record.getSodiumValue() + safeDouble(itemRecord.getSodiumValuePer100g()) * factor));
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
        try {
            FoodAnalysisResponse intakeResponse = new FoodAnalysisResponse();
            List<FoodItem> foodItems = new ArrayList<>();
            DailyIntakeRecord intakeRecord = userIntakeMapper.fetchIntakeById(userId, dailyIntakeId);
            if (intakeRecord == null) {
                throw new Exception("Intake record not found");
            }
            intakeResponse.setPortion(intakeRecord.getPortion() != null ? intakeRecord.getPortion() : 1.0);
            intakeResponse.setMealName(intakeRecord.getIntakeName());

            User user = userService.getUserByUserId(userId);
            String countryCode = CountryCode.fromCountryName(user.getCountry()).getCode();
            List<FoodItemRecord> foodItemRecords = userIntakeMapper.fetchFoodItemsByDailyIntakeId(dailyIntakeId, countryCode);

            double mealPortion = intakeRecord.getPortion() != null ? intakeRecord.getPortion() : 1.0;

            for (FoodItemRecord record : foodItemRecords) {
                FoodItem foodItem = new FoodItem();
                foodItem.setName(record.getItemName());
                foodItem.setCanonicalName(record.getCanonicalName());
                double itemPortion = record.getPortion() != null ? record.getPortion() : 1.0;
                foodItem.setPortion(itemPortion);
                double factor = (safeDouble(record.getQuantityValue()) / 100.0) * itemPortion * mealPortion;
                foodItem.setQuantity(new Quantity(round(safeDouble(record.getQuantityValue()) * itemPortion * mealPortion), record.getQuantityUnit()));

                List<FoodNutrient> nutrients = new ArrayList<>();
                nutrients.add(new FoodNutrient(CALORIES, new Quantity(round(safeDouble(record.getCaloriesValuePer100g()) * factor), safeUnit(record.getCaloriesUnit(), "kcal"))));
                nutrients.add(new FoodNutrient(PROTEIN, new Quantity(round(safeDouble(record.getProteinValuePer100g()) * factor), safeUnit(record.getProteinUnit(), "g"))));
                nutrients.add(new FoodNutrient(TOTAL_CARBOHYDRATE, new Quantity(round(safeDouble(record.getTotalCarbohydrateValuePer100g()) * factor), safeUnit(record.getTotalCarbohydrateUnit(), "g"))));
                nutrients.add(new FoodNutrient(TOTAL_FAT, new Quantity(round(safeDouble(record.getTotalFatValuePer100g()) * factor), safeUnit(record.getTotalFatUnit(), "g"))));
                nutrients.add(new FoodNutrient(DIETARY_FIBER, new Quantity(round(safeDouble(record.getDietaryFiberValuePer100g()) * factor), safeUnit(record.getDietaryFiberUnit(), "g"))));
                nutrients.add(new FoodNutrient(TOTAL_SUGARS, new Quantity(round(safeDouble(record.getTotalSugarsValuePer100g()) * factor), safeUnit(record.getTotalSugarsUnit(), "g"))));
                nutrients.add(new FoodNutrient(SODIUM, new Quantity(round(safeDouble(record.getSodiumValuePer100g()) * factor), safeUnit(record.getSodiumUnit(), "mg"))));

                foodItem.setNutrients(nutrients);
                foodItems.add(foodItem);
            }
            intakeResponse.setAnalyzedFoodItems(foodItems);
            recalculateTotalPlateNutrients(intakeResponse);
            return intakeResponse;
        } catch (Exception exception) {
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

    private Double safeGetNutrientValue(Map<String, Quantity> nutrientMap, String name) {
        Quantity q = nutrientMap.get(name);
        return (q != null) ? q.getValue() : null;
    }
    
    private String safeGetNutrientUnit(Map<String, Quantity> nutrientMap, String name) {
        Quantity q = nutrientMap.get(name);
        return (q != null) ? q.getUnit() : null;
    }

    private String safeUnit(String unit, String defaultUnit) {
        return (unit != null && !unit.trim().isEmpty()) ? unit : defaultUnit;
    }

}
