import 'package:equatable/equatable.dart';

abstract class PriceEvent extends Equatable {
  const PriceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyPricesEvent extends PriceEvent {
  // මෙතන 'const' Constructor එක අනිවාර්යයෙන්ම තිබිය යුතුයි
  const LoadDailyPricesEvent(); 
}

class LoadPriceTrendsEvent extends PriceEvent {
  final String productName;
  const LoadPriceTrendsEvent(this.productName);

  @override
  List<Object?> get props => [productName];
}

class SearchPricesEvent extends PriceEvent {
  final String query;
  const SearchPricesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}