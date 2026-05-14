import 'dart:convert';

class MedicineModel {
  final String? inventoryMedicineId;
  final String? medicineId;
  final String? shopId;
  final double? discountPercent;
  final double? finalPrice;
  final String? status;
  final MedicineDetails? medicineDetails;
  final ShopDetails? shopDetails;

  MedicineModel({
    this.inventoryMedicineId,
    this.medicineId,
    this.shopId,
    this.discountPercent,
    this.finalPrice,
    this.status,
    this.medicineDetails,
    this.shopDetails,
  });

  MedicineModel copyWith({
    String? inventoryMedicineId,
    String? medicineId,
    String? shopId,
    double? discountPercent,
    double? finalPrice,
    String? status,
    MedicineDetails? medicineDetails,
    ShopDetails? shopDetails,
  }) {
    return MedicineModel(
      inventoryMedicineId: inventoryMedicineId ?? this.inventoryMedicineId,
      medicineId: medicineId ?? this.medicineId,
      shopId: shopId ?? this.shopId,
      discountPercent: discountPercent ?? this.discountPercent,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      medicineDetails: medicineDetails ?? this.medicineDetails,
      shopDetails: shopDetails ?? this.shopDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventory_medicine_id': inventoryMedicineId,
      'medicine_id': medicineId,
      'shop_id': shopId,
      'discount_percent': discountPercent,
      'final_price': finalPrice,
      'status': status,
      'medicine_details': medicineDetails?.toMap(),
      'shop_details': shopDetails?.toMap(),
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      inventoryMedicineId: map['inventory_medicine_id'],
      medicineId: map['medicine_id'],
      shopId: map['shop_id'],
      discountPercent: (map['discount_percent'] as num?)?.toDouble(),
      finalPrice: (map['final_price'] as num?)?.toDouble(),
      status: map['status'],
      medicineDetails: map['medicine_details'] != null
          ? MedicineDetails.fromMap(map['medicine_details'])
          : null,
      shopDetails: map['shop_details'] != null
          ? ShopDetails.fromMap(map['shop_details'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicineModel.fromJson(String source) =>
      MedicineModel.fromMap(json.decode(source));
}

class MedicineDetails {
  final String? medicineName;
  final String? medicineCategory;
  final String? medicinePhoto;
  final String? medicineQuantity;
  final String? medicineDescription;
  final String? medicineComposition;
  final List<dynamic>? precautions;
  final double? mrp;

  MedicineDetails({
    this.medicineName,
    this.medicineCategory,
    this.medicinePhoto,
    this.medicineQuantity,
    this.medicineDescription,
    this.medicineComposition,
    this.precautions,
    this.mrp,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicine_name': medicineName,
      'medicine_category': medicineCategory,
      'medicine_photo': medicinePhoto,
      'medicine_quantity': medicineQuantity,
      'medicine_description': medicineDescription,
      'medicine_composition': medicineComposition,
      'precautions': precautions,
      'mrp': mrp,
    };
  }

  factory MedicineDetails.fromMap(Map<String, dynamic> map) {
    return MedicineDetails(
      medicineName: map['medicine_name'],
      medicineCategory: map['medicine_category'],
      medicinePhoto: map['medicine_photo'],
      medicineQuantity: map['medicine_quantity'],
      medicineDescription: map['medicine_description'],
      medicineComposition: map['medicine_composition'],
      precautions: map['precautions'],
      mrp: (map['mrp'] as num?)?.toDouble(),
    );
  }
}

class ShopDetails {
  final String? shopId;
  final String? shopName;
  final String? shopEmail;
  final String? shopPhoneNo;
  final String? shopAddress;
  final String? shopPhoto;

  ShopDetails({
    this.shopId,
    this.shopName,
    this.shopEmail,
    this.shopPhoneNo,
    this.shopAddress,
    this.shopPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_id': shopId,
      'shop_name': shopName,
      'shop_email': shopEmail,
      'shop_phone_no': shopPhoneNo,
      'shop_address': shopAddress,
      'shop_photo': shopPhoto,
    };
  }

  factory ShopDetails.fromMap(Map<String, dynamic> map) {
    return ShopDetails(
      shopId: map['shop_id'],
      shopName: map['shop_name'],
      shopEmail: map['shop_email'],
      shopPhoneNo: map['shop_phone_no'],
      shopAddress: map['shop_address'],
      shopPhoto: map['shop_photo'],
    );
  }
}
