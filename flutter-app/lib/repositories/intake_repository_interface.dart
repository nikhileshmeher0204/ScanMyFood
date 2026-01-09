import 'dart:io';

import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/user_intake_output.dart';

abstract class IntakeRepositoryInterface {
  Future<void> saveScannedFood(
      String userId, File? frontImage, FoodAnalysisResponse? foodAnalysis);

  Future<void> saveScannedLabel(String userId, File? frontImage,
      ProductAnalysisResponse? productAnalysis);

  Future<UserIntakeOutput> getDailyIntake(String userId, DateTime date);
}
