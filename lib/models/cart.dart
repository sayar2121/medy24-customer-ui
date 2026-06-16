import 'medicine.dart';

class CartItem {
  final MedicineModel medicine;
  final int quantity;

  CartItem({
    required this.medicine,
    required this.quantity,
  });

  CartItem copyWith({
    MedicineModel? medicine,
    int? quantity,
  }) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final priceVal = json['price_per_unit'] ?? json['price'];
    final parsedPrice = priceVal != null ? double.tryParse(priceVal.toString()) : null;

    return CartItem(
      medicine: MedicineModel(
        medicineId: json['medicine_id']?.toString(),
        medicineName: (json['medicine_name'] ?? json['name'])?.toString(),
        finalPrice: parsedPrice,
        mrp: parsedPrice, // API only gives price_per_unit, or shop sends price
        medicinePhoto: json['medicine_photo']?.toString(),
      ),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartSummary {
  final double totalItemAmount;
  final double totalDiscount;
  final double platformCharges;
  final double deliveryFees;
  final double taxes;
  final double totalAmountToBePaid;
  final double totalSaved;
  final double orderValueDiscount;

  CartSummary({
    required this.totalItemAmount,
    required this.totalDiscount,
    required this.orderValueDiscount,
    required this.platformCharges,
    required this.deliveryFees,
    required this.taxes,
    required this.totalAmountToBePaid,
    required this.totalSaved,
  });
}
