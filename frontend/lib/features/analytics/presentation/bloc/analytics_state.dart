// lib/features/analytics/presentation/bloc/analytics_state.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics.dart';

class AnalyticsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final Analytics? analytics;

  const AnalyticsState({
    required this.isLoading,
    this.errorMessage,
    this.analytics,
  });

  factory AnalyticsState.initial() {
    return const AnalyticsState(isLoading: false);
  }

  AnalyticsState copyWith({
    bool? isLoading,
    String? errorMessage,
    Analytics? analytics,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      analytics: analytics ?? this.analytics,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, analytics];
}
