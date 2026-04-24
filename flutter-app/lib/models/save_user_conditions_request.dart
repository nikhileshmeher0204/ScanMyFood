class SaveUserConditionsRequest {
  final String firebaseUid;
  final List<String> conditionNames;

  SaveUserConditionsRequest({
    required this.firebaseUid,
    required this.conditionNames,
  });

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
      'condition_names': conditionNames,
    };
  }
}
