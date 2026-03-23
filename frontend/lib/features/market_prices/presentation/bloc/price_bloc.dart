// lib/features/market_prices/presentation/bloc/price_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/price.dart';
import '../../domain/usecases/get_daily_prices_usecase.dart';
import '../../domain/usecases/get_price_trends_usecase.dart';
import '../../domain/usecases/get_supply_status_usecase.dart';
import '../../domain/usecases/get_forecast_usecase.dart';
import 'price_event.dart';
import 'price_state.dart';

class PriceBloc extends Bloc<PriceEvent, PriceState> {
  final GetDailyPricesUseCase   getDailyPrices;
  final GetPriceHistoryUseCase  getPriceHistory;
  final GetSupplyStatusUseCase  getSupplyStatus;
  final GetForecastUseCase      getForecast;

  PriceBloc({
    required this.getDailyPrices,
    required this.getPriceHistory,
    required this.getSupplyStatus,
    required this.getForecast,
  }) : super(PriceState.initial()) {
    on<LoadDailyPricesEvent>(_onLoadPrices);
    on<LoadSupplyStatusEvent>(_onLoadSupply);
    on<LoadForecastEvent>(_onLoadForecast);
    on<SearchPricesEvent>(_onSearch);
    on<FilterByDistrictEvent>(_onFilterDistrict);
    on<RefreshAllPricesEvent>(_onRefresh);
  }

  // ── Load today's prices ────────────────────────────────────────────────────
  Future<void> _onLoadPrices(
    LoadDailyPricesEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoadingPrices: true, clearError: true));
    try {
      final prices = await getDailyPrices();
      emit(state.copyWith(
        isLoadingPrices: false,
        allPrices:       prices,
        filteredPrices:  _applyFilters(prices, state.searchQuery, state.selectedDistrict),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingPrices: false,
        errorMessage:    'Failed to load prices: ${e.toString()}',
      ));
    }
  }

  // ── Load supply analytics ──────────────────────────────────────────────────
  Future<void> _onLoadSupply(
    LoadSupplyStatusEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoadingAnalytics: true));
    try {
      final analytics = await getSupplyStatus();
      emit(state.copyWith(isLoadingAnalytics: false, supplyAnalytics: analytics));
    } catch (e) {
      emit(state.copyWith(isLoadingAnalytics: false));
    }
  }

  // ── Load AI forecast ───────────────────────────────────────────────────────
  Future<void> _onLoadForecast(
    LoadForecastEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoadingForecast: true));
    try {
      final forecastResult = await getForecast(event.cropName);
      final history = await getPriceHistory(event.cropName);
      emit(state.copyWith(
        isLoadingForecast: false,
        forecast:     forecastResult,
        priceHistory: history,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingForecast: false));
    }
  }

  // ── Search filter ──────────────────────────────────────────────────────────
  void _onSearch(SearchPricesEvent event, Emitter<PriceState> emit) {
    final q = event.query.trim().toLowerCase();
    emit(state.copyWith(
      searchQuery:    event.query,
      filteredPrices: _applyFilters(state.allPrices, q, state.selectedDistrict),
    ));
  }

  // ── District filter ────────────────────────────────────────────────────────
  void _onFilterDistrict(FilterByDistrictEvent event, Emitter<PriceState> emit) {
    emit(state.copyWith(
      selectedDistrict: event.district,
      filteredPrices:   _applyFilters(state.allPrices, state.searchQuery, event.district),
    ));
  }

  // ── Refresh everything ─────────────────────────────────────────────────────
  Future<void> _onRefresh(
    RefreshAllPricesEvent event,
    Emitter<PriceState> emit,
  ) async {
    add(const LoadDailyPricesEvent());
    add(const LoadSupplyStatusEvent());
  }

  // ── Filter helper ──────────────────────────────────────────────────────────
  List<PriceEntity> _applyFilters(
      List<PriceEntity> prices, String query, String district) {
    return prices.where((p) {
      final matchQuery = query.isEmpty ||
          p.cropName.toLowerCase().contains(query) ||
          p.marketName.toLowerCase().contains(query) ||
          p.district.toLowerCase().contains(query);
      final matchDistrict = district == 'All' || p.district == district;
      return matchQuery && matchDistrict;
    }).toList();
  }
}
