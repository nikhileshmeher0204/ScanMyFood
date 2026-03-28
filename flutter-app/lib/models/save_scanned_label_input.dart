import 'package:read_the_label/models/product_analysis_response.dart';

class SaveScannedLabelInput {
  final String userId;
  final String sourceOfIntake;
  final ProductAnalysisResponse productAnalysisResponse;

  SaveScannedLabelInput({
    required this.userId,
    required this.sourceOfIntake,
    required this.productAnalysisResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'source_of_intake': sourceOfIntake,
      'product_analysis_response': productAnalysisResponse.toJson(),
    };
  }
}
