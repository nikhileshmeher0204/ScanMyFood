class HealthCondition {
  final String name;
  final String? description;

  HealthCondition({
    required this.name,
    this.description,
  });

  factory HealthCondition.fromJson(Map<String, dynamic> json) {
    return HealthCondition(
      name: json['name'],
      description: json['description'],
    );
  }
}
