// lib/features/market_prices/presentation/bloc/price_state.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/price.dart';

class PriceState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Price> prices;
  final Map<DateTime, double> trends;
  final String? selectedProduct;

  const PriceState({
    required this.isLoading,
    required this.prices,
    required this.trends,
    this.errorMessage,
    this.selectedProduct,
  });

  factory PriceState.initial() {
    return const PriceState(
      isLoading: false,
      prices: [],
      trends: {},
      errorMessage: null,
      selectedProduct: null,
    );
  }

  PriceState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Price>? prices,
    Map<DateTime, double>? trends,
    String? selectedProduct,
  }) {
    return PriceState(
      isLoading: isLoading ?? this.isLoading,
      prices: prices ?? this.prices,
      trends: trends ?? this.trends,
      errorMessage: errorMessage,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, errorMessage, prices, trends, selectedProduct];
}
