class UserInfo {
  final String name;
  final String gender;
  final int age;
  final Map<String, double> dailyTarget;

  UserInfo({
    required this.name,
    required this.gender,
    required this.age,
    required this.dailyTarget,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'age': age,
        'dailyTarget': dailyTarget,
      };

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        name: json['name'],
        gender: json['gender'],
        age: json['age'],
        dailyTarget: Map<String, double>.from(json['dailyTarget']),
      );
}