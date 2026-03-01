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
    
    // Either එක fold කරලා Failure (l) සහ Success (r) වෙන් කරගන්නවා
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false, 
        errorMessage: 'Failed to load prices'
      )),
      (prices) => emit(state.copyWith(
        isLoading: false,
        allPrices: prices,
        filteredPrices: prices,
      )),
    );
  }

  Future<void> _onLoadTrends(
    LoadPriceTrendsEvent event,
    Emitter<PriceState> emit,
  ) async {
    // trends load වෙද්දී මුළු screen එකම reload නොවෙන්න isLoading පරීක්ෂා කරන්න
    final result = await getPriceTrends(event.productName);
    
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: 'Failed to load trends')),
      (trendsMap) => emit(state.copyWith(
        trends: trendsMap,
        selectedProduct: event.productName,
      )),
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

    final filtered = state.allPrices
        .where((p) => p.productName.toLowerCase().contains(query))
        .toList();
        
    emit(state.copyWith(filteredPrices: filtered));
  }
}