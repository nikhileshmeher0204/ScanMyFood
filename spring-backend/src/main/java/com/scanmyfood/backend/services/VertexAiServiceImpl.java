package com.scanmyfood.backend.services;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.scanmyfood.backend.models.FoodAnalysisResponse;
import com.scanmyfood.backend.models.ProductAnalysisResponse;

import com.scanmyfood.backend.constants.NutrientConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.vertexai.VertexAI;
import com.google.cloud.vertexai.api.Content;
import com.google.cloud.vertexai.api.GenerateContentResponse;
import com.google.cloud.vertexai.generativeai.ContentMaker;
import com.google.cloud.vertexai.generativeai.GenerativeModel;
import com.google.cloud.vertexai.generativeai.PartMaker;
import com.google.protobuf.ByteString;

@Service
public class VertexAiServiceImpl implements AiService {

  private static final Logger logger = LoggerFactory.getLogger(VertexAiServiceImpl.class);

  @Autowired
  private ObjectMapper objectMapper;

  @Autowired
  private VertexAI vertexAI;

  @Autowired
  private GenerativeModel generativeModel;

  @Autowired
  private GenerativeModel imageGenerativeModel;

  @Override
  public ProductAnalysisResponse analyzeProductImages(MultipartFile frontImage, MultipartFile labelImage) {

    try {
      String frontMimeType = determineMimeType(frontImage);
      String labelMimeType = determineMimeType(labelImage);

      // Create prompt
      String prompt = """
          Analyze the food product, product name and its nutrition label. Provide response in this strict JSON format:
          {
            "product": {
              "name": "Product name from front image",
              "category": "Food category (e.g., snack, beverage, etc.)"
            },
            "nutrition_analysis": {
              "total_quantity": {"value": 0, "unit": "unit in packet"},
              "serving_size": {"value": 0, "unit": "unit in packet"},
              "nutrients": [
                {
                  "name": "nutrient name in snake_case from the list below",
                  "quantity": {"value": "Quantity of nutrient in per serving of food product", "unit": "unit in packet"},
                  "daily_value": 0,
                  "dv_status": "High/Moderate/Low based on calculated DV%%",
                  "goal": "Goal of consumption of a nutrient can be - 'At least' or 'Less than' based on recommended DV%%",
                  "health_impact": "Good/Moderate/Bad"
                }
              ],
              "primary_concerns": [
                {
                  "issue": "Primary nutritional concern",
                  "explanation": "Brief explanation of health impact",
                  "recommendations": [
                    {
                      "food": "Complementary food to add",
                      "quantity": "Recommended quantity to add",
                      "reasoning": "How this helps balance nutrition"
                    }
                  ]
                }
              ]
            }
          }

          Strictly follow these rules:
          1. MUST include ALL nutrients from this list: %s
          2. If a nutrient is not found on the label, set its value to 0.0 and use standard unit
          3. Extract total nutrient (e.g., Total Sugars, Total Fat) and its sub-nutrients (e.g., Added Sugars, Saturated Fat, Trans Fat) if mentioned in the label
          4. Calculate DV%% using these reference values:
             %s
             Formula: (nutrient_quantity_per_serving / daily_value_reference) × 100
          5. Return calculated DV%% in double, and not the ones found in label
          6. Do not include any extra characters or formatting outside of the JSON object
          7. Use accurate escape sequences for any special characters
          8. For primary_concerns, focus on major nutritional imbalances
          9. For recommendations:
             - Suggest foods that can be added to complement the product
             - Focus on practical additions
             - Explain how each addition helps balance nutrition
          10. Use %%DV guidelines:
             5%% DV or less is considered low dv_status
             20%% DV or more is considered high dv_status
             5%% < DV < 20%% is considered moderate dv_status
          11. For health_impact determination:
             "At least" nutrients (like fiber, protein):
               High dv_status → Good health_impact
               Moderate dv_status → Moderate health_impact
               Low dv_status → Bad health_impact
             "Less than" nutrients (like sodium, saturated fat, trans fat, sugar, cholesterol):
               Low dv_status → Good health_impact
               Moderate dv_status → Moderate health_impact
               High dv_status → Bad health_impact
          """
          .formatted(NutrientConstants.ALL_NUTRIENT_NAMES, NutrientConstants.DAILY_VALUES_REFERENCE);

      // Use ContentMaker and PartMaker
      Content content = ContentMaker.fromMultiModalData(
          prompt,
          PartMaker.fromMimeTypeAndData(frontMimeType, frontImage.getBytes()),
          PartMaker.fromMimeTypeAndData(labelMimeType, labelImage.getBytes()));
      // Generate content
      GenerateContentResponse response = generativeModel.generateContent(content);

      // Extract JSON and deserialize directly into ProductAnalysisResponse
      String responseText = response.getCandidates(0).getContent().getParts(0).getText();
      String jsonString = extractJsonString(responseText);
      return objectMapper.readValue(jsonString, ProductAnalysisResponse.class);

    } catch (Exception e) {
      logger.error("Error analyzing product images", e);
      throw new RuntimeException("Failed to analyze product images: " + e.getMessage());
    }
  }

  @Override
  public FoodAnalysisResponse analyzeFoodImage(MultipartFile imageFile) {
    try {
      String foodMimeType = determineMimeType(imageFile);

      // Create prompt
      String prompt = """
          Analyze this food image and break down each visible food item.
          Provide response in this strict JSON format:
          {
            "meal_name": "Name of the meal",
            "analyzed_food_items": [
              {
                "name": "Name of the food item",
                "quantity": {
                  "value": 0,
                  "unit": "g"
                },
                "nutrients": [
                  {"name": "calories", "quantity": {"value": 0, "unit": "kcal"}},
                  {"name": "protein", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "total_carbohydrate", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "total_fat", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "dietary_fiber", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "total_sugars", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "sodium", "quantity": {"value": 0, "unit": "mg"}}
                ]
              }
            ],
            "total_plate_nutrients": [
              {"name": "calories", "quantity": {"value": 0, "unit": "kcal"}},
              {"name": "protein", "quantity": {"value": 0, "unit": "g"}},
              {"name": "total_carbohydrate", "quantity": {"value": 0, "unit": "g"}},
              {"name": "total_fat", "quantity": {"value": 0, "unit": "g"}},
              {"name": "dietary_fiber", "quantity": {"value": 0, "unit": "g"}},
              {"name": "total_sugars", "quantity": {"value": 0, "unit": "g"}},
              {"name": "sodium", "quantity": {"value": 0, "unit": "mg"}}
            ]
          }

          Consider:
          1. Use visual cues to estimate portions (size relative to plate, height of food, etc.)
          2. Take a deeper look into the container size of food, don't consider a zoomed in container to be a big container
          3. Provide nutrients for the estimated total quantity of each food item
          4. Prioritize using values from the USDA FoodData Central database
          5. Consider common serving sizes and preparation methods
          6. Account for density and volume-to-weight conversions
          7. Use Atwater factors (Protein=4 kcal/g, Carb=4, Fat=9) for grams to kcal conversion

          """;

      // Use ContentMaker and PartMaker with the determined MIME type
      Content content = ContentMaker.fromMultiModalData(
          prompt,
          PartMaker.fromMimeTypeAndData(foodMimeType, imageFile.getBytes()));

      // Generate content
      GenerateContentResponse response = generativeModel.generateContent(content);

      // Extract JSON and deserialize directly into FoodAnalysisResponse
      String responseText = response.getCandidates(0).getContent().getParts(0).getText();
      String jsonString = extractJsonString(responseText);
      return objectMapper.readValue(jsonString, FoodAnalysisResponse.class);

    } catch (Exception e) {
      logger.error("Error analyzing food image", e);
      throw new RuntimeException("Failed to analyze food image: " + e.getMessage());
    }
  }

  @Override
  public FoodAnalysisResponse analyzeFoodDescription(String description) {
    try {
      // Create prompt
      String prompt = """
          You are a highly qualified and experienced nutritionist specializing in providing accurate nutritional information.
          Analyze these food items (always consider items in cooked form whenever applicable) and their quantities:

          %s

          Generate nutritional info for each of the mentioned food items and their respective quantities and respond using this JSON schema:
          {
            "meal_name": "Name of the food item/meal",
            "analyzed_food_items": [
              {
                "name": "Name of the food item",
                "quantity": {
                  "value": 0,
                  "unit": "g"
                },
                "nutrients": [
                  {"name": "calories", "quantity": {"value": 0, "unit": "kcal"}},
                  {"name": "protein", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "total_carbohydrate", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "total_fat", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "dietary_fiber", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "total_sugars", "quantity": {"value": 0, "unit": "g"}},
                  {"name": "sodium", "quantity": {"value": 0, "unit": "mg"}}
                ]
              }
            ],
            "total_plate_nutrients": [
              {"name": "calories", "quantity": {"value": 0, "unit": "kcal"}},
              {"name": "protein", "quantity": {"value": 0, "unit": "g"}},
              {"name": "total_carbohydrate", "quantity": {"value": 0, "unit": "g"}},
              {"name": "total_fat", "quantity": {"value": 0, "unit": "g"}},
              {"name": "dietary_fiber", "quantity": {"value": 0, "unit": "g"}},
              {"name": "total_sugars", "quantity": {"value": 0, "unit": "g"}},
              {"name": "sodium", "quantity": {"value": 0, "unit": "mg"}}
            ]
          }


              Important considerations:
              1. Analyze the provided food items and their quantities in the meal description.
              2. Generate nutritional information for each food item and the total meal, adhering to the provided JSON schema.
              3. Prioritize using values from the USDA FoodData Central database. If data is unavailable in the USDA database, use other reputable sources like the EFSA (European Food Safety Authority) Comprehensive Food Consumption Database or national food composition databases, ensuring data reliability and scientific validity.
              4. Account for common preparation methods (e.g., boiled, fried, baked) when calculating nutritional values. If the preparation method is not specified, assume the most common method for that food item.
              5. Convert all measurements to grams (g) or milliliters (ml) as appropriate. If only volume is provided, use standard density values to convert to weight.  If a unit is not specified, assume grams (g).
              6. Consider regional variations in portion sizes when interpreting quantities. If the description is ambiguous, use standard serving sizes.
              7. Round all nutritional values to one decimal place.
              8. Account for density and volume-to-weight conversions

              Provide accurate nutritional data based on the most reliable food databases and scientific sources.
              """
          .formatted(description);

      // Use ContentMaker (text-only in this case)
      Content content = ContentMaker.fromString(prompt);

      // Generate content
      GenerateContentResponse response = generativeModel.generateContent(content);

      // Extract JSON and deserialize directly into FoodAnalysisResponse
      String responseText = response.getCandidates(0).getContent().getParts(0).getText();
      String jsonString = extractJsonString(responseText);
      return objectMapper.readValue(jsonString, FoodAnalysisResponse.class);

    } catch (Exception e) {
      logger.error("Error analyzing food description", e);
      throw new RuntimeException("Failed to analyze food description: " + e.getMessage());
    }
  }

  @Override
  public byte[] generateFoodImage(String foodDescription) {
    try {
      // Build optimized prompt for realistic food photography
      String prompt = String.format(
          "Generate a professional food photography image of %s. " +
              "Requirements: " +
              "- Position the primary food item and its plating in the top 50%% of the frame, leaving the lower 50%% as a clean, minimalist table surface to allow for UI overlays "
              +
              "- Serve on appropriate cutlery and dinnerware based on the food type " +
              "- Proper plating with accurate portion sizes matching the description " +
              "- Arrange appetizingly on a clean table setting (white or wooden) " +
              "- Natural soft daylight lighting from the side " +
              "- Shot from a 45-degree angle in landscape format (16:9 aspect ratio) " +
              "- Shallow depth of field, Canon EOS R5 photography style " +
              "- 8K resolution, photorealistic, restaurant quality presentation " +
              "- Professional food styling with vibrant colors and fresh ingredients " +
              "- Slightly blurred background with warm neutral tones " +
              "- No hands, people, or text visible - focus entirely on the food " +
              "- Add steam if it's a hot dish for realism",
          foodDescription);

      logger.info("Generating food image with Gemini 2.5 Flash Image for: {}", foodDescription);
      logger.debug("Image generation prompt: {}", prompt);

      // Create content with image generation request
      Content content = ContentMaker.fromString(prompt);

      // Generate image using injected image generation model
      GenerateContentResponse response = imageGenerativeModel.generateContent(content);

      logger.info("Received response from Gemini, candidates: {}", response.getCandidatesCount());

      if (response.getCandidatesCount() == 0) {
        logger.error("No candidates in response. Response: {}", response);
        throw new RuntimeException("No image generated - response has no candidates");
      }

      var candidate = response.getCandidates(0);
      logger.info("Candidate parts count: {}", candidate.getContent().getPartsCount());

      if (candidate.getContent().getPartsCount() == 0) {
        logger.error("No parts in candidate content. Candidate: {}", candidate);
        throw new RuntimeException("No image generated - candidate has no parts");
      }

      // Iterate through all parts to find the one with inline data (the image)
      ByteString imageData = null;
      for (int i = 0; i < candidate.getContent().getPartsCount(); i++) {
        var part = candidate.getContent().getParts(i);

        if (part.hasInlineData()) {
          logger.info("Found inline data in part {}", i);
          imageData = part.getInlineData().getData();
          break;
        } else if (part.hasText()) {
          logger.info("Part {} contains text: {}", i, part.getText());
        }
      }

      if (imageData == null) {
        logger.error("No inline data found in any part");
        throw new RuntimeException("No image generated - no part contains inline data");
      }

      // Extract image bytes from response
      byte[] imageBytes = imageData.toByteArray();

      logger.info("Successfully generated food image, size: {} bytes", imageBytes.length);

      if (imageBytes.length == 0) {
        throw new RuntimeException("Image data is empty");
      }

      return imageBytes;

    } catch (Exception e) {
      logger.error("Error generating food image with Gemini 2.5 Flash Image", e);
      throw new RuntimeException("Failed to generate food image: " + e.getMessage(), e);
    }
  }

  /**
   * Determines appropriate MIME type for an image file
   */
  private String determineMimeType(MultipartFile file) {
    String mimeType = file.getContentType();
    if (mimeType == null || mimeType.equals("application/octet-stream")) {
      String filename = file.getOriginalFilename();
      if (filename != null) {
        if (filename.toLowerCase().endsWith(".png")) {
          return "image/png";
        } else if (filename.toLowerCase().endsWith(".jpg") ||
            filename.toLowerCase().endsWith(".jpeg")) {
          return "image/jpeg";
        }
      }
      // Default to JPEG if can't determine
      return "image/jpeg";
    }
    return mimeType;
  }

  private String extractJsonString(String responseText) throws IOException {
    Pattern pattern = Pattern.compile("\\{.*\\}", Pattern.DOTALL);
    Matcher matcher = pattern.matcher(responseText);
    if (matcher.find()) {
      return matcher.group(0);
    } else {
      throw new IOException("No valid JSON found in the response");
    }
  }

}