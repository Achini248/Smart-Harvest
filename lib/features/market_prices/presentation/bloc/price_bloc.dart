import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
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

  // UseCase එකෙන් කෙලින්ම List<PriceEntity> එකක් එන නිසා try-catch පාවිච්චි කරයි
  Future<void> _onLoadDailyPrices(
    LoadDailyPricesEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    try {
      final List<PriceEntity> pricesList = await getDailyPrices();
      
      emit(state.copyWith(
        isLoading: false,
        allPrices: pricesList,
        filteredPrices: pricesList,
        errorMessage: pricesList.isEmpty ? 'අද දින මිල ගණන් දත්ත නොමැත.' : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'දත්ත ලබාගැනීමේදී දෝෂයක් සිදුවිය: ${e.toString()}',
      ));
    }
  }

  // UseCase එකෙන් Either<Failure, Map> එකක් එන නිසා fold පාවිච්චි කරයි
  Future<void> _onLoadTrends(
    LoadPriceTrendsEvent event,
    Emitter<PriceState> emit,
  ) async {
    final result = await getPriceTrends(event.productName);
    
    result.fold(
      (Failure f) {
        emit(state.copyWith(
          errorMessage: 'මිල ප්‍රවණතා ලබාගත නොහැක: ${f.message}'
        ));
      },
      (Map<DateTime, double> trendsMap) {
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