// lib/features/analytics/presentation/bloc/analytics_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsUseCase getAnalytics;

  AnalyticsBloc({required this.getAnalytics})
      : super(AnalyticsState.initial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
      LoadAnalyticsEvent event, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await getAnalytics();
      emit(state.copyWith(
        isLoading: false,
        analytics: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load analytics: $e',
      ));
    }
  }
}
