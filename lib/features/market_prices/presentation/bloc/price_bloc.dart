import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/price.dart'; 
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
    on<SearchPricesEvent>(_onSearch);
  }

  Future<void> _onLoadDailyPrices(
    LoadDailyPricesEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await getDailyPrices();
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false, 
          errorMessage: 'Failed to load market prices'
        ));
      },
      (prices) {
        emit(state.copyWith(
          isLoading: false,
          allPrices: prices,
          filteredPrices: prices,
          errorMessage: prices.isEmpty ? 'No prices available today.' : null,
        ));
      },
    );
  }

  Future<void> _onLoadTrends(
    LoadPriceTrendsEvent event,
    Emitter<PriceState> emit,
  ) async {
    // Trend එක load වන බව පෙන්වීමට isLoading true කළ හැක
    final result = await getPriceTrends(event.productName);
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: 'Could not load trends for ${event.productName}'
        ));
      },
      (trendsMap) {
        emit(state.copyWith(
          trends: trendsMap,
          selectedProduct: event.productName,
        ));
      },
    );
  }

  void _onSearch(
    SearchPricesEvent event,
    Emitter<PriceState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    
    if (query.isEmpty) {
      emit(state.copyWith(filteredPrices: state.allPrices));
      return;
    }

    // List එක filter කිරීම
    final filtered = state.allPrices
        .where((PriceEntity p) => p.productName.toLowerCase().contains(query))
        .toList();
        
    emit(state.copyWith(filteredPrices: filtered));
  }
}