class SaveUserConditionsRequest {
  final String userId;
  final List<String> conditionNames;

  SaveUserConditionsRequest({
    required this.userId,
    required this.conditionNames,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'condition_names': conditionNames,
    };
  }
}
