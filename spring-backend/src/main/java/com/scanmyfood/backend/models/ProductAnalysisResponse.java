package com.scanmyfood.backend.models;

import java.util.List;

import lombok.Data;

@Data
public class ProductAnalysisResponse {
    private ProductInfo product;
    private NutritionAnalysis nutritionAnalysis;

    @Data
    public static class ProductInfo {
        private String name;
        private String category;
    }

    @Data
    public static class NutritionAnalysis {
        private Quantity totalQuantity;
        private Quantity servingSize;
        private List<Nutrient> nutrients;
        private List<PrimaryConcern> primaryConcerns;
    }

    @Data
    public static class Nutrient {
        private String name;
        private Quantity quantity;
        private String dailyValue;
        private String dvStatus;
        private String goal;
        private String healthImpact;
    }

    @Data
    public static class PrimaryConcern {
        private String issue;
        private String explanation;
        private List<Recommendation> recommendations;
    }

    @Data
    public static class Recommendation {
        private String food;
        private String quantity;
        private String reasoning;
    }

    @Data
    public static class Quantity {
        private double value;
        private String unit;
    }
}
