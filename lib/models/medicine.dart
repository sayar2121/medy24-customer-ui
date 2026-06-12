import 'dart:convert';

class MedicineModel {
  final String? medicineId;
  final String? medicineName;
  final String? medicineCategory;
  final String? medicineQuantity;
  final double? mrp;
  final double? discountPercent;
  final double? finalPrice;
  final String? medicineDescription;
what is what

  String toJson() => json.encode(toMap());

  factory MedicineModel.fromJson(String source) =>
      MedicineModel.fromMap(json.decode(source));
}
