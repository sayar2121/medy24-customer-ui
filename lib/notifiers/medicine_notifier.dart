import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../services/medicine_services.dart';

class MedicineState {
  final List<MedicineModel> medicines;
  final List<MedicineModel> searchResults;
  final MedicineModel? selectedMedicine;
  final bool isLoading;
  final String? error;

  MedicineState({
    this.medicines = const [],
    this.searchResults = const [],
    this.selectedMedicine,
    this.isLoading = false,
    this.error,
  });

  MedicineState copyWith({
    List<MedicineModel>? medicines,
    List<MedicineModel>? searchResults,
    MedicineModel? selectedMedicine,
    bool? isLoading,
    String? error,
  }) {
    return MedicineState(
      medicines: medicines ?? this.medicines,
      searchResults: searchResults ?? this.searchResults,
      selectedMedicine: selectedMedicine ?? this.selectedMedicine,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  final MedicineService _service = MedicineService();

  MedicineNotifier() : super(MedicineState());

  Future<void> fetchAllMedicines() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getAllMedicines();
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final medicines = data.map((m) => MedicineModel.fromMap(m)).toList();
        state = state.copyWith(medicines: medicines, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Failed to load medicines");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMedicineById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getMedicineById(id);
      if (response.statusCode == 200) {
        final medicine = MedicineModel.fromMap(response.data['data']);
        state = state.copyWith(selectedMedicine: medicine, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Failed to load medicine details");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchMedicines(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.searchMedicines(query);
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final results = data.map((m) => MedicineModel.fromMap(m)).toList();
        state = state.copyWith(searchResults: results, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Search failed");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }

  void selectMedicine(MedicineModel medicine) {
    state = state.copyWith(selectedMedicine: medicine);
  }
}
