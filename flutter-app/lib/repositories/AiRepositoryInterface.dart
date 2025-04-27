import 'dart:io';

abstract class AiRepositoryInterface {
  Future<Map<String, dynamic>> analyzeProductImages(
      File frontImage, File labelImage);
  Future<Map<String, dynamic>> analyzeFoodImage(File imageFile);
  Future<Map<String, dynamic>> analyzeFoodDescription(String description);
}
