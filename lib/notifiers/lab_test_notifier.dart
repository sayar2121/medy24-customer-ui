import 'package:flutter_riverpod/legacy.dart';
import '../models/lab_test.dart';
import '../models/my_test_booking.dart';
import '../services/lab_test_services.dart';

class LabTestState {
  final List<LabTestInventoryModel> tests;
  final List<TestPackageModel> packages;
  final bool isLoading;
  final String? error;
  final LabTestInventoryModel? selectedTest;
  final TestPackageModel? selectedPackage;
  final List<BookingDetailResponse> myBookings;
  final bool isBookingsLoading;
  final String? bookingsError;

  LabTestState({
    this.tests = const [],
    this.packages = const [],
    this.isLoading = false,
    this.error,
    this.selectedTest,
    this.selectedPackage,
    this.myBookings = const [],
    this.isBookingsLoading = false,
    this.bookingsError,
  });

  LabTestState copyWith({
    List<LabTestInventoryModel>? tests,
    List<TestPackageModel>? packages,
    bool? isLoading,
    String? error,
    LabTestInventoryModel? selectedTest,
    TestPackageModel? selectedPackage,
    List<BookingDetailResponse>? myBookings,
    bool? isBookingsLoading,
    String? bookingsError,
  }) {
    return LabTestState(
      tests: tests ?? this.tests,
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTest: selectedTest ?? this.selectedTest,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      myBookings: myBookings ?? this.myBookings,
      isBookingsLoading: isBookingsLoading ?? this.isBookingsLoading,
      bookingsError: bookingsError,
    );
  }
}

class LabTestNotifier extends StateNotifier<LabTestState> {
  final LabTestService _service;

  LabTestNotifier(this._service) : super(LabTestState());

  Future<void> fetchAllTests({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getAllTests(page: page);
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final tests = data
            .map((t) => LabTestInventoryModel.fromJson(t))
            .toList();
        state = state.copyWith(tests: tests, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Failed to load tests");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchTestById(String testId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getTestById(testId);
      if (response.statusCode == 200) {
        final data = response.data;
        final testJson = data is Map<String, dynamic>
            ? (data['test'] as Map<String, dynamic>? ?? data)
            : null;
        if (testJson == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Invalid test details response',
          );
          return;
        }
        final test = LabTestInventoryModel.fromJson(testJson);
        state = state.copyWith(selectedTest: test, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load test details",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchTestsByLab(String labId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getTestsByLabId(labId);
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final tests = data
            .map((t) => LabTestInventoryModel.fromJson(t))
            .toList();
        state = state.copyWith(tests: tests, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load lab's tests",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Test Package Methods
  Future<void> fetchPackagesByLab(String labId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getPackagesByLabId(labId);
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final packages = data.map((p) => TestPackageModel.fromJson(p)).toList();
        state = state.copyWith(packages: packages, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load packages",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAllPackages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getAllPackages(limit: 100); // Respect FastAPI le=100 constraint
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final packages = data.map((p) => TestPackageModel.fromJson(p)).toList();
        state = state.copyWith(packages: packages, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load all packages",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchPackagesForLabs(List<String> labIds) async {
    state = state.copyWith(isLoading: true, error: null, packages: []);
    try {
      final futures = labIds.map((id) => _service.getPackagesByLabId(id));
      final responses = await Future.wait(futures);

      List<TestPackageModel> allPackages = [];
      for (var response in responses) {
        if (response.statusCode == 200) {
          final List data = response.data['data'] ?? [];
          allPackages.addAll(data.map((p) => TestPackageModel.fromJson(p)));
        }
      }
      state = state.copyWith(packages: allPackages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchPackageById(String packageId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getPackageById(packageId);
      if (response.statusCode == 200) {
        final data = response.data;
        final packageJson = data is Map<String, dynamic>
            ? (data['package'] as Map<String, dynamic>? ?? data)
            : null;
        if (packageJson == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Invalid package details response',
          );
          return;
        }
        final package = TestPackageModel.fromJson(packageJson);
        state = state.copyWith(selectedPackage: package, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load package details",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCustomerBookings(String customerId) async {
    state = state.copyWith(isBookingsLoading: true, bookingsError: null);
    try {
      final response = await _service.getCustomerBookings(customerId);
      if (response.statusCode == 200) {
        final List data = response.data['bookings'] ?? [];
        final bookings = data
            .map((b) => BookingDetailResponse.fromJson(b))
            .toList();
        state = state.copyWith(myBookings: bookings, isBookingsLoading: false);
      } else {
        state = state.copyWith(
          isBookingsLoading: false,
          bookingsError: "Failed to load bookings",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isBookingsLoading: false,
        bookingsError: e.toString(),
      );
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.updateBookingStatus(
        bookingId,
        "cancelled",
        cancellationReason: reason,
      );
      if (response.statusCode == 200) {
        final updatedBooking = BookingDetailResponse.fromJson(response.data);
        final updatedBookings = state.myBookings.map((b) {
          if (b.bookingId == bookingId) {
            return updatedBooking;
          }
          return b;
        }).toList();
        state = state.copyWith(myBookings: updatedBookings, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to cancel booking",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
