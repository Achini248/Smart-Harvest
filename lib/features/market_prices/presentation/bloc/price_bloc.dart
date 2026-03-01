import 'package:flutter_bloc/flutter_bloc.dart';

// Import කරද්දී 'PriceEntity' අඩංගු price.dart නිවැරදිව ඇති බව සහතික කරගන්න
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
    try {
      // UseCase එක callable එකක් ලෙස පාවිච්චි කරනවා
      final prices = await getDailyPrices();
      emit(state.copyWith(
        isLoading: false,
        allPrices: prices,
        filteredPrices: prices,
        errorMessage: prices.isEmpty ? 'No prices available today.' : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load prices: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadTrends(
    LoadPriceTrendsEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final trends = await getPriceTrends(event.productName);
      emit(state.copyWith(
        isLoading: false,
        trends: trends,
        selectedProduct: event.productName,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load price trends: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSearch(
    SearchPricesEvent event,
    Emitter<PriceState> emit,
  ) async {
    // query එක null විය හැකි නම් null check එකක් එක් කළා
    final query = (event.query ?? "").trim().toLowerCase();
    
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