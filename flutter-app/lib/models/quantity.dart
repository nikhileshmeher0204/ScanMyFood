class Quantity {
  final double value;
  final String unit;

  Quantity({required this.value, required this.unit});

  factory Quantity.fromJson(Map<String, dynamic> json) {
    return Quantity(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'g',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}
