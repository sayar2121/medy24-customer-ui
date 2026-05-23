import 'package:flutter_riverpod/legacy.dart';

class HomeState {
  final bool isLoading;
  final String? error;

  HomeState({this.isLoading = false, this.error});

  HomeState copyWith({bool? isLoading, String? error}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());

  // Add home related logic here if needed
}
