// lib/features/market_prices/presentation/bloc/price_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_daily_prices_usecase.dart';
import '../../domain/usecases/get_price_trends_usecase.dart';
import 'price_event.dart';
import 'price_state.dart';

class PriceBloc extends Bloc<PriceEvent, PriceState> {
  final GetDailyPricesUseCase getDailyPrices;
  final GetPriceTrendsUseCase getPriceTrends;

  PriceBloc({
    required this.getDailyPrices,
    required this.getPriceTrends,
  }) : super(PriceState.initial()) {
    on<LoadDailyPricesEvent>(_onLoadDailyPrices);
    on<LoadPriceTrendsEvent>(_onLoadTrends);
  }

  Future<void> _onLoadDailyPrices(
      LoadDailyPricesEvent event, Emitter<PriceState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final list = await getDailyPrices();
      emit(state.copyWith(
        isLoading: false,
        prices: list,
        errorMessage: list.isEmpty ? 'No prices available today.' : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load prices: $e',
      ));
    }
  }

  Future<void> _onLoadTrends(
      LoadPriceTrendsEvent event, Emitter<PriceState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await getPriceTrends(event.productName);
      emit(state.copyWith(
        isLoading: false,
        trends: data,
        selectedProduct: event.productName,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load price trends: $e',
      ));
    }
  }
}
