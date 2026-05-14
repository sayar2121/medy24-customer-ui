import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/medicine_notifier.dart';

final medicineProvider = StateNotifierProvider<MedicineNotifier, MedicineState>((ref) {
  return MedicineNotifier();
});
