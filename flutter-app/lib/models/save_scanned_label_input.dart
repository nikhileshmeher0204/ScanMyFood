import 'package:read_the_label/models/product_analysis_response.dart';

class SaveScannedLabelInput {
  final String userId;
  final ProductAnalysisResponse productAnalysisResponse;

  SaveScannedLabelInput({
    required this.userId,
    required this.productAnalysisResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_analysis_response': productAnalysisResponse.toJson(),
    };
  }
}
