class SaveIntakeOutput {
  int dailyIntakeId;

  SaveIntakeOutput({
    required this.dailyIntakeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyIntakeId': dailyIntakeId,
    };
  }

  factory SaveIntakeOutput.fromJson(Map<String, dynamic> json) {
    return SaveIntakeOutput(
      dailyIntakeId: json['dailyIntakeId'] as int,
    );
  }
}
