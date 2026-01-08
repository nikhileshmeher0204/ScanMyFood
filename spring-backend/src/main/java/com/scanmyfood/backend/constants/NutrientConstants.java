package com.scanmyfood.backend.constants;

public class NutrientConstants {

    public static final String DAILY_VALUES_REFERENCE = """
        Use these Daily Value (DV) references and the goal to consume in braces for accurate calculations:
        
        Energy: 2000kcal (Equal to)
        Added Sugars: 50g (Less than)
        Sugar: 50g (Less than)
        Biotin: 30mcg (At least)
        Calcium: 1300mg (At least)
        Chloride: 2300mg (At least)
        Choline: 550mg (At least)
        Cholesterol: 300mg (Less than)
        Chromium: 35mcg (At least)
        Copper: 0.9mg (At least)
        Fiber: 28g (At least)
        Fat: 78g (Less than)
        Folate/Folic Acid: 400mcg DFE (At least)
        Iodine: 150mcg (At least)
        Iron: 18mg (At least)
        Magnesium: 420mg (At least)
        Manganese: 2.3mg (At least)
        Molybdenum: 45mcg (At least)
        Niacin: 16mg NE (At least)
        Pantothenic Acid: 5mg (At least)
        Phosphorus: 1250mg (At least)
        Potassium: 4700mg (At least)
        Protein: 50g (At least)
        Riboflavin: 1.3mg (At least)
        Saturated Fat: 20g (Less than)
        Selenium: 55mcg (At least)
        Sodium: 2300mg (Less than)
        Thiamin: 1.2mg (At least)
        Carbohydrate: 275g (NA)
        Vitamin A: 900mcg RAE (At least)
        Vitamin B6: 1.7mg (At least)
        Vitamin B9: 400mcg (At least)
        Vitamin B12: 2.4mcg (At least)
        Vitamin C: 90mg (At least)
        Vitamin D: 20mcg (At least)
        Vitamin E: 15mg alpha-tocopherol (At least)
        Vitamin K: 120mcg (At least)
        Zinc: 11mg (At least)
        """;

    public static final String CALORIES = "calories";
    public static final String ENERGY = "energy";
    public static final String CHOLESTEROL = "cholesterol";
    public static final String PROTEIN = "protein";
    public static final String TOTAL_CARBOHYDRATE = "total_carbohydrate";
    public static final String TOTAL_FAT = "total_fat";
    public static final String SATURATED_FAT = "saturated_fat";
    public static final String TRANS_FAT = "trans_fat";
    public static final String DIETARY_FIBER = "dietary_fiber";
    public static final String TOTAL_SUGARS = "total_sugars";
    public static final String ADDED_SUGARS = "added_sugars";
    public static final String SODIUM = "sodium";
    public static final String IRON = "iron";
    public static final String CALCIUM = "calcium";
    public static final String POTASSIUM = "potassium";
    public static final String VITAMIN_D = "vitamin_d";
    public static final String VITAMIN_A = "vitamin_a";
    public static final String VITAMIN_C = "vitamin_c";
    public static final String VITAMIN_E = "vitamin_e";
    public static final String VITAMIN_K = "vitamin_k";
    public static final String VITAMIN_B6 = "vitamin_b6";
    public static final String VITAMIN_B12 = "vitamin_b12";
    public static final String MAGNESIUM = "magnesium";
    public static final String PHOSPHORUS = "phosphorus";
    public static final String ZINC = "zinc";
    public static final String FOLATE = "folate";

    public static final String ALL_NUTRIENT_NAMES = String.join(", ",
            ENERGY, PROTEIN, CHOLESTEROL,
            TOTAL_FAT, SATURATED_FAT, TRANS_FAT,
            TOTAL_CARBOHYDRATE, DIETARY_FIBER, TOTAL_SUGARS, ADDED_SUGARS,
            SODIUM, CALCIUM, IRON, POTASSIUM, MAGNESIUM, PHOSPHORUS, ZINC, FOLATE,
            VITAMIN_D, VITAMIN_A, VITAMIN_C, VITAMIN_B6, VITAMIN_B12, VITAMIN_E, VITAMIN_K
    );

}