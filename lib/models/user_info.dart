class UserInfo {
  final String name;
  final String gender;
  final int age;
  final double energy;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double fiber;

  UserInfo({
    required this.name,
    required this.gender,
    required this.age,
    required this.energy,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.fiber,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'age': age,
        'energy': energy,
        'protein': protein,
        'carbohydrate': carbohydrate,
        'fat': fat,
        'fiber': fiber,
      };

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        name: json['name'],
        gender: json['gender'],
        age: json['age'],
        energy: json['energy'].toDouble(),
        protein: json['protein'].toDouble(),
        carbohydrate: json['carbohydrate'].toDouble(),
        fat: json['fat'].toDouble(),
        fiber: json['fiber'].toDouble(),
      );
}