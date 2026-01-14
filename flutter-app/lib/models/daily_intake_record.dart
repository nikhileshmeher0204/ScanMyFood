class DailyIntakeRecord {
  final int? id;
  final String? userId;
  final String? intakeName;
  final String? sourceOfIntake;
  final String? imageUrl;

  final double caloriesValue;
  final String caloriesUnit;
  final double energyValue;
  final String energyUnit;
  final double proteinValue;
  final String proteinUnit;
  final double cholesterolValue;
  final String cholesterolUnit;
  final double totalCarbohydrateValue;
  final String totalCarbohydrateUnit;
  final double dietaryFiberValue;
  final String dietaryFiberUnit;
  final double totalSugarsValue;
  final String totalSugarsUnit;
  final double addedSugarsValue;
  final String addedSugarsUnit;
  final double totalFatValue;
  final String totalFatUnit;
  final double saturatedFatValue;
  final String saturatedFatUnit;
  final double transFatValue;
  final String transFatUnit;
  final double sodiumValue;
  final String sodiumUnit;
  final double calciumValue;
  final String calciumUnit;
  final double ironValue;
  final String ironUnit;
  final double potassiumValue;
  final String potassiumUnit;
  final double magnesiumValue;
  final String magnesiumUnit;
  final double phosphorusValue;
  final String phosphorusUnit;
  final double zincValue;
  final String zincUnit;
  final double folateValue;
  final String folateUnit;
  final double vitaminDValue;
  final String vitaminDUnit;
  final double vitaminAValue;
  final String vitaminAUnit;
  final double vitaminCValue;
  final String vitaminCUnit;
  final double vitaminB6Value;
  final String vitaminB6Unit;
  final double vitaminB12Value;
  final String vitaminB12Unit;
  final double vitaminEValue;
  final String vitaminEUnit;
  final double vitaminKValue;
  final String vitaminKUnit;
  final DateTime? createdAt;

  DailyIntakeRecord({
    this.id,
    this.userId,
    this.intakeName,
    this.sourceOfIntake,
    this.imageUrl,
    this.caloriesValue = 0.0,
    this.caloriesUnit = 'kcal',
    this.energyValue = 0.0,
    this.energyUnit = 'kcal',
    this.proteinValue = 0.0,
    this.proteinUnit = 'g',
    this.cholesterolValue = 0.0,
    this.cholesterolUnit = 'mg',
    this.totalCarbohydrateValue = 0.0,
    this.totalCarbohydrateUnit = 'g',
    this.dietaryFiberValue = 0.0,
    this.dietaryFiberUnit = 'g',
    this.totalSugarsValue = 0.0,
    this.totalSugarsUnit = 'g',
    this.addedSugarsValue = 0.0,
    this.addedSugarsUnit = 'g',
    this.totalFatValue = 0.0,
    this.totalFatUnit = 'g',
    this.saturatedFatValue = 0.0,
    this.saturatedFatUnit = 'g',
    this.transFatValue = 0.0,
    this.transFatUnit = 'g',
    this.sodiumValue = 0.0,
    this.sodiumUnit = 'mg',
    this.calciumValue = 0.0,
    this.calciumUnit = 'mg',
    this.ironValue = 0.0,
    this.ironUnit = 'mg',
    this.potassiumValue = 0.0,
    this.potassiumUnit = 'mg',
    this.magnesiumValue = 0.0,
    this.magnesiumUnit = 'mg',
    this.phosphorusValue = 0.0,
    this.phosphorusUnit = 'mg',
    this.zincValue = 0.0,
    this.zincUnit = 'mg',
    this.folateValue = 0.0,
    this.folateUnit = 'mcg',
    this.vitaminDValue = 0.0,
    this.vitaminDUnit = 'mcg',
    this.vitaminAValue = 0.0,
    this.vitaminAUnit = 'mcg',
    this.vitaminCValue = 0.0,
    this.vitaminCUnit = 'mg',
    this.vitaminB6Value = 0.0,
    this.vitaminB6Unit = 'mg',
    this.vitaminB12Value = 0.0,
    this.vitaminB12Unit = 'mcg',
    this.vitaminEValue = 0.0,
    this.vitaminEUnit = 'mg',
    this.vitaminKValue = 0.0,
    this.vitaminKUnit = 'mcg',
    this.createdAt,
  });

  factory DailyIntakeRecord.fromJson(Map<String, dynamic> json) {
    return DailyIntakeRecord(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      intakeName: json['intake_name'] as String?,
      sourceOfIntake: json['source_of_intake'] as String?,
      imageUrl: json['image_url'] as String?,
      caloriesValue: (json['calories_value'] as num?)?.toDouble() ?? 0.0,
      caloriesUnit: json['calories_unit'] as String? ?? 'kcal',
      energyValue: (json['energy_value'] as num?)?.toDouble() ?? 0.0,
      energyUnit: json['energy_unit'] as String? ?? 'kcal',
      proteinValue: (json['protein_value'] as num?)?.toDouble() ?? 0.0,
      proteinUnit: json['protein_unit'] as String? ?? 'g',
      cholesterolValue: (json['cholesterol_value'] as num?)?.toDouble() ?? 0.0,
      cholesterolUnit: json['cholesterol_unit'] as String? ?? 'mg',
      totalCarbohydrateValue:
          (json['total_carbohydrate_value'] as num?)?.toDouble() ?? 0.0,
      totalCarbohydrateUnit: json['total_carbohydrate_unit'] as String? ?? 'g',
      dietaryFiberValue:
          (json['dietary_fiber_value'] as num?)?.toDouble() ?? 0.0,
      dietaryFiberUnit: json['dietary_fiber_unit'] as String? ?? 'g',
      totalSugarsValue: (json['total_sugars_value'] as num?)?.toDouble() ?? 0.0,
      totalSugarsUnit: json['total_sugars_unit'] as String? ?? 'g',
      addedSugarsValue: (json['added_sugars_value'] as num?)?.toDouble() ?? 0.0,
      addedSugarsUnit: json['added_sugars_unit'] as String? ?? 'g',
      totalFatValue: (json['total_fat_value'] as num?)?.toDouble() ?? 0.0,
      totalFatUnit: json['total_fat_unit'] as String? ?? 'g',
      saturatedFatValue:
          (json['saturated_fat_value'] as num?)?.toDouble() ?? 0.0,
      saturatedFatUnit: json['saturated_fat_unit'] as String? ?? 'g',
      transFatValue: (json['trans_fat_value'] as num?)?.toDouble() ?? 0.0,
      transFatUnit: json['trans_fat_unit'] as String? ?? 'g',
      sodiumValue: (json['sodium_value'] as num?)?.toDouble() ?? 0.0,
      sodiumUnit: json['sodium_unit'] as String? ?? 'mg',
      calciumValue: (json['calcium_value'] as num?)?.toDouble() ?? 0.0,
      calciumUnit: json['calcium_unit'] as String? ?? 'mg',
      ironValue: (json['iron_value'] as num?)?.toDouble() ?? 0.0,
      ironUnit: json['iron_unit'] as String? ?? 'mg',
      potassiumValue: (json['potassium_value'] as num?)?.toDouble() ?? 0.0,
      potassiumUnit: json['potassium_unit'] as String? ?? 'mg',
      magnesiumValue: (json['magnesium_value'] as num?)?.toDouble() ?? 0.0,
      magnesiumUnit: json['magnesium_unit'] as String? ?? 'mg',
      phosphorusValue: (json['phosphorus_value'] as num?)?.toDouble() ?? 0.0,
      phosphorusUnit: json['phosphorus_unit'] as String? ?? 'mg',
      zincValue: (json['zinc_value'] as num?)?.toDouble() ?? 0.0,
      zincUnit: json['zinc_unit'] as String? ?? 'mg',
      folateValue: (json['folate_value'] as num?)?.toDouble() ?? 0.0,
      folateUnit: json['folate_unit'] as String? ?? 'mcg',
      vitaminDValue: (json['vitamin_d_value'] as num?)?.toDouble() ?? 0.0,
      vitaminDUnit: json['vitamin_d_unit'] as String? ?? 'mcg',
      vitaminAValue: (json['vitamin_a_value'] as num?)?.toDouble() ?? 0.0,
      vitaminAUnit: json['vitamin_a_unit'] as String? ?? 'mcg',
      vitaminCValue: (json['vitamin_c_value'] as num?)?.toDouble() ?? 0.0,
      vitaminCUnit: json['vitamin_c_unit'] as String? ?? 'mg',
      vitaminB6Value: (json['vitamin_b6_value'] as num?)?.toDouble() ?? 0.0,
      vitaminB6Unit: json['vitamin_b6_unit'] as String? ?? 'mg',
      vitaminB12Value: (json['vitamin_b12_value'] as num?)?.toDouble() ?? 0.0,
      vitaminB12Unit: json['vitamin_b12_unit'] as String? ?? 'mcg',
      vitaminEValue: (json['vitamin_e_value'] as num?)?.toDouble() ?? 0.0,
      vitaminEUnit: json['vitamin_e_unit'] as String? ?? 'mg',
      vitaminKValue: (json['vitamin_k_value'] as num?)?.toDouble() ?? 0.0,
      vitaminKUnit: json['vitamin_k_unit'] as String? ?? 'mcg',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'intake_name': intakeName,
      'source_of_intake': sourceOfIntake,
      'image_url': imageUrl,
      'calories_value': caloriesValue,
      'calories_unit': caloriesUnit,
      'energy_value': energyValue,
      'energy_unit': energyUnit,
      'protein_value': proteinValue,
      'protein_unit': proteinUnit,
      'cholesterol_value': cholesterolValue,
      'cholesterol_unit': cholesterolUnit,
      'total_carbohydrate_value': totalCarbohydrateValue,
      'total_carbohydrate_unit': totalCarbohydrateUnit,
      'dietary_fiber_value': dietaryFiberValue,
      'dietary_fiber_unit': dietaryFiberUnit,
      'total_sugars_value': totalSugarsValue,
      'total_sugars_unit': totalSugarsUnit,
      'added_sugars_value': addedSugarsValue,
      'added_sugars_unit': addedSugarsUnit,
      'total_fat_value': totalFatValue,
      'total_fat_unit': totalFatUnit,
      'saturated_fat_value': saturatedFatValue,
      'saturated_fat_unit': saturatedFatUnit,
      'trans_fat_value': transFatValue,
      'trans_fat_unit': transFatUnit,
      'sodium_value': sodiumValue,
      'sodium_unit': sodiumUnit,
      'calcium_value': calciumValue,
      'calcium_unit': calciumUnit,
      'iron_value': ironValue,
      'iron_unit': ironUnit,
      'potassium_value': potassiumValue,
      'potassium_unit': potassiumUnit,
      'magnesium_value': magnesiumValue,
      'magnesium_unit': magnesiumUnit,
      'phosphorus_value': phosphorusValue,
      'phosphorus_unit': phosphorusUnit,
      'zinc_value': zincValue,
      'zinc_unit': zincUnit,
      'folate_value': folateValue,
      'folate_unit': folateUnit,
      'vitamin_d_value': vitaminDValue,
      'vitamin_d_unit': vitaminDUnit,
      'vitamin_a_value': vitaminAValue,
      'vitamin_a_unit': vitaminAUnit,
      'vitamin_c_value': vitaminCValue,
      'vitamin_c_unit': vitaminCUnit,
      'vitamin_b6_value': vitaminB6Value,
      'vitamin_b6_unit': vitaminB6Unit,
      'vitamin_b12_value': vitaminB12Value,
      'vitamin_b12_unit': vitaminB12Unit,
      'vitamin_e_value': vitaminEValue,
      'vitamin_e_unit': vitaminEUnit,
      'vitamin_k_value': vitaminKValue,
      'vitamin_k_unit': vitaminKUnit,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
