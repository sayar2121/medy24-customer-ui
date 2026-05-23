import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/medicine_notifier.dart';

final medicineProvider = StateNotifierProvider<MedicineNotifier, MedicineState>(
  (ref) {
    return MedicineNotifier();
  },
);
