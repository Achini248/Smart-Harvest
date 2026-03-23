import 'package:equatable/equatable.dart';
import '../../domain/entities/price.dart';

class PriceState extends Equatable {
  final bool isLoadingPrices;
  final bool isLoadingAnalytics;
  final bool isLoadingForecast;
  final String? errorMessage;

  final List<PriceEntity> allPrices;
  final List<PriceEntity> filteredPrices;
  final SupplyAnalyticsEntity? supplyAnalytics;
  final ForecastEntity? forecast;
  final List<PriceHistoryPoint> priceHistory;

  final String searchQuery;
  final String selectedDistrict;

  const PriceState({
    this.isLoadingPrices    = false,
    this.isLoadingAnalytics = false,
    this.isLoadingForecast  = false,
    this.errorMessage,
    this.allPrices       = const [],
    this.filteredPrices  = const [],
    this.supplyAnalytics,
    this.forecast,
    this.priceHistory    = const [],
    this.searchQuery     = '',
    this.selectedDistrict = 'All',
  });

  factory PriceState.initial() => const PriceState();

  bool get isLoading => isLoadingPrices || isLoadingAnalytics;

  /// All unique districts from loaded prices.
  List<String> get districts {
    final set = <String>{'All'};
    for (final p in allPrices) {
      if (p.district.isNotEmpty) set.add(p.district);
    }
    return set.toList()..sort();
  }

  PriceState copyWith({
    bool?   isLoadingPrices,
    bool?   isLoadingAnalytics,
    bool?   isLoadingForecast,
    String? errorMessage,
    List<PriceEntity>?        allPrices,
    List<PriceEntity>?        filteredPrices,
    SupplyAnalyticsEntity?    supplyAnalytics,
    ForecastEntity?           forecast,
    List<PriceHistoryPoint>?  priceHistory,
    String? searchQuery,
    String? selectedDistrict,
    bool    clearError = false,
  }) {
    return PriceState(
      isLoadingPrices:    isLoadingPrices    ?? this.isLoadingPrices,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      isLoadingForecast:  isLoadingForecast  ?? this.isLoadingForecast,
      errorMessage:       clearError ? null : (errorMessage ?? this.errorMessage),
      allPrices:          allPrices          ?? this.allPrices,
      filteredPrices:     filteredPrices     ?? this.filteredPrices,
      supplyAnalytics:    supplyAnalytics    ?? this.supplyAnalytics,
      forecast:           forecast           ?? this.forecast,
      priceHistory:       priceHistory       ?? this.priceHistory,
      searchQuery:        searchQuery        ?? this.searchQuery,
      selectedDistrict:   selectedDistrict   ?? this.selectedDistrict,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingPrices, isLoadingAnalytics, isLoadingForecast,
        errorMessage, allPrices, filteredPrices,
        supplyAnalytics, forecast, priceHistory,
        searchQuery, selectedDistrict,
      ];
}
