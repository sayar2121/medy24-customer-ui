enum BookingItemType { labTest, package }

class BookingPatientDetails {
  final String fullName;
  final String phoneNumber;
  final String gender;
  final int age;
  final String relation;

  const BookingPatientDetails({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.relation,
  });

  BookingPatientDetails copyWith({
    String? fullName,
    String? phoneNumber,
    String? gender,
    int? age,
    String? relation,
  }) {
    return BookingPatientDetails(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      relation: relation ?? this.relation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      'age': age,
      'relation': relation,
    };
  }
}

class BookingCollectionAddress {
  final String addressLine1;
  final String streetAddress;
  final double? latitude;
  final double? longitude;
  final int? savedAddressId;

  const BookingCollectionAddress({
    required this.addressLine1,
    required this.streetAddress,
    this.latitude,
    this.longitude,
    this.savedAddressId,
  });

  String get displayAddress => '$addressLine1, $streetAddress';

  BookingCollectionAddress copyWith({
    String? addressLine1,
    String? streetAddress,
    double? latitude,
    double? longitude,
    int? savedAddressId,
  }) {
    return BookingCollectionAddress(
      addressLine1: addressLine1 ?? this.addressLine1,
      streetAddress: streetAddress ?? this.streetAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      savedAddressId: savedAddressId ?? this.savedAddressId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_1': addressLine1,
      'street_address': streetAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (savedAddressId != null) 'saved_address_id': savedAddressId,
    };
  }
}

class BookingPriceSummary {
  final double subtotal;
  final double discount;
  final double platformFee;
  final double taxCharges;
  final double totalAmount;

  const BookingPriceSummary({
    required this.subtotal,
    required this.discount,
    required this.platformFee,
    required this.taxCharges,
    required this.totalAmount,
  });

  double get itemTotal => subtotal - discount;
}

class TestPackageBooking {
  final BookingItemType itemType;
  final String itemId;
  final String labId;
  final String itemName;
  final String? itemSubtitle;
  final bool isBookingForSelf;
  final BookingPatientDetails patient;
  final BookingCollectionAddress? collectionAddress;
  final BookingPriceSummary priceSummary;
  final String? customerId;

  const TestPackageBooking({
    required this.itemType,
    required this.itemId,
    required this.labId,
    required this.itemName,
    this.itemSubtitle,
    required this.isBookingForSelf,
    required this.patient,
    this.collectionAddress,
    required this.priceSummary,
    this.customerId,
  });

  TestPackageBooking copyWith({
    BookingItemType? itemType,
    String? itemId,
    String? labId,
    String? itemName,
    String? itemSubtitle,
    bool? isBookingForSelf,
    BookingPatientDetails? patient,
    BookingCollectionAddress? collectionAddress,
    BookingPriceSummary? priceSummary,
    String? customerId,
  }) {
    return TestPackageBooking(
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      labId: labId ?? this.labId,
      itemName: itemName ?? this.itemName,
      itemSubtitle: itemSubtitle ?? this.itemSubtitle,
      isBookingForSelf: isBookingForSelf ?? this.isBookingForSelf,
      patient: patient ?? this.patient,
      collectionAddress: collectionAddress ?? this.collectionAddress,
      priceSummary: priceSummary ?? this.priceSummary,
      customerId: customerId ?? this.customerId,
    );
  }

}

class CreateBookingRequest {
  final String customerId;
  final String labId;
  final String bookingType;
  final List<Map<String, dynamic>> bookedItems;
  final List<Map<String, dynamic>> patientDetails;
  final Map<String, dynamic> sampleCollectionAddress;
  final double subTotalAmount;
  final double totalDiscountAmount;
  final double platformFee;
  final double taxAmount;
  final double totalAmountToBePaid;
  final String paymentMode;
  final String? transactionId;
  final String? transactionHash;
  final String? customerNote;

  CreateBookingRequest({
    required this.customerId,
    required this.labId,
    required this.bookingType,
    required this.bookedItems,
    required this.patientDetails,
    required this.sampleCollectionAddress,
    required this.subTotalAmount,
    required this.totalDiscountAmount,
    required this.platformFee,
    required this.taxAmount,
    required this.totalAmountToBePaid,
    required this.paymentMode,
    this.transactionId,
    this.transactionHash,
    this.customerNote,
  });

  factory CreateBookingRequest.fromTestPackageBooking(
    TestPackageBooking booking, {
    required String paymentMode,
    String? transactionId,
    String? transactionHash,
  }) {
    if (booking.customerId == null || booking.customerId!.isEmpty) {
      throw 'Customer ID is required to place a booking';
    }
    if (booking.collectionAddress == null) {
      throw 'Sample collection address is required';
    }

    return CreateBookingRequest(
      customerId: booking.customerId!,
      labId: booking.labId,
      bookingType: booking.itemType == BookingItemType.labTest
          ? 'single_test'
          : 'package',
      bookedItems: [
        {
          'item_id': booking.itemId,
          'item_name': booking.itemName,
          if (booking.itemSubtitle != null) 'item_subtitle': booking.itemSubtitle,
        },
      ],
      patientDetails: [booking.patient.toJson()],
      sampleCollectionAddress: booking.collectionAddress!.toJson(),
      subTotalAmount: booking.priceSummary.subtotal,
      totalDiscountAmount: booking.priceSummary.discount,
      platformFee: booking.priceSummary.platformFee,
      taxAmount: booking.priceSummary.taxCharges,
      totalAmountToBePaid: booking.priceSummary.totalAmount,
      paymentMode: paymentMode,
      transactionId: transactionId,
      transactionHash: transactionHash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'lab_id': labId,
      'booking_type': bookingType,
      'booked_items': bookedItems,
      'patient_details': patientDetails,
      'sample_collection_address': sampleCollectionAddress,
      'sub_total_amount': subTotalAmount,
      'total_discount_amount': totalDiscountAmount,
      'platform_fee': platformFee,
      'tax_amount': taxAmount,
      'total_amount_to_be_paid': totalAmountToBePaid,
      'payment_mode': paymentMode,
      if (transactionId != null) 'transaction_id': transactionId,
      if (transactionHash != null) 'transaction_hash': transactionHash,
      if (customerNote != null) 'customer_note': customerNote,
    };
  }
}

class BookingResponse {
  final String bookingId;
  final String customerId;
  final String labId;
  final String bookingStatus;
  final double totalAmountToBePaid;
  final String paymentMode;
  final String? transactionId;
  final String transactionStatus;

  BookingResponse({
    required this.bookingId,
    required this.customerId,
    required this.labId,
    required this.bookingStatus,
    required this.totalAmountToBePaid,
    required this.paymentMode,
    this.transactionId,
    required this.transactionStatus,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      bookingId: json['booking_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      labId: json['lab_id']?.toString() ?? '',
      bookingStatus: json['booking_status']?.toString() ?? 'pending',
      totalAmountToBePaid:
          _toDouble(json['total_amount_to_be_paid']),
      paymentMode: json['payment_mode']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString(),
      transactionStatus: json['transaction_status']?.toString() ?? 'pending',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
