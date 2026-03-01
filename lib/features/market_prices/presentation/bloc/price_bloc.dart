Future<void> _onLoadDailyPrices(
    LoadDailyPricesEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await getDailyPrices();
    
    // syntax එක curly braces {} සහිතව මෙසේ විය යුතුයි
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false, 
          errorMessage: 'Failed to load prices'
        ));
      },
      (prices) {
        emit(state.copyWith(
          isLoading: false,
          allPrices: prices,
          filteredPrices: prices,
          errorMessage: prices.isEmpty ? 'No prices available.' : null,
        ));
      },
    );
  }