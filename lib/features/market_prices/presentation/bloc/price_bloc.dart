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
    
    // වැදගත්: මෙහි 'return' keyword එක පාවිච්චි නොකරන්න. 
    // එය "Null Function" error එකට හේතු වේ.
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false, 
          errorMessage: 'Failed to load prices'
        ));
      },
      (pricesList) {
        emit(state.copyWith(
          isLoading: false,
          allPrices: pricesList,
          filteredPrices: pricesList,
          errorMessage: pricesList.isEmpty ? 'No prices available today.' : null,
        ));
      },
    );
  }

  Future<void> _onLoadTrends(
    LoadPriceTrendsEvent event,
    Emitter<PriceState> emit,
  ) async {
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

    final filtered = state.allPrices
        .where((PriceEntity p) => p.productName.toLowerCase().contains(query))
        .toList();
        
    emit(state.copyWith(filteredPrices: filtered));
  }
}