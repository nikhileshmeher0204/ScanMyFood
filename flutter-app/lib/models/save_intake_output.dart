import 'package:flutter/material.dart';

class SaveIntakeOutput {
  int dailyIntakeId;

  SaveIntakeOutput({
    required this.dailyIntakeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_intake_id': dailyIntakeId,
    };
  }

  factory SaveIntakeOutput.fromJson(Map<String, dynamic> json) {
    debugPrint('daily_intake_id: ${json['daily_intake_id'] as int}');
    return SaveIntakeOutput(
      dailyIntakeId: json['daily_intake_id'] as int,
    );
  }
}
