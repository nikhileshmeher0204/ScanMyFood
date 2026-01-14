class IntakeDescriptionRequest {
  final String description;
  final int? dailyIntakeId;

  IntakeDescriptionRequest({
    required this.description,
    this.dailyIntakeId,
  });

  factory IntakeDescriptionRequest.fromJson(Map<String, dynamic> json) {
    return IntakeDescriptionRequest(
      description: json['description'] as String,
      dailyIntakeId: json['daily_intake_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'daily_intake_id': dailyIntakeId,
    };
  }
}
