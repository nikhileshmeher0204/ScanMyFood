package com.scanmyfood.backend.models;

import lombok.Data;
import java.util.List;

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
        private String servingSize;
        private List<Nutrient> nutrients;
        private List<PrimaryConcern> primaryConcerns;
    }

    @Data
    public static class Nutrient {
        private String name;
        private String quantity;
        private String dailyValue;
        private String status;
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
}
