import 'package:equatable/equatable.dart';

abstract class PriceEvent extends Equatable {
  const PriceEvent();
  @override
  List<Object?> get props => [];
}

class LoadDailyPricesEvent extends PriceEvent {}

class LoadPriceTrendsEvent extends PriceEvent {
  final String productName;
  const LoadPriceTrendsEvent(this.productName);
  @override
  List<Object?> get props => [productName];
}

// මේ කොටස අනිවාර්යයෙන්ම තියෙන්න ඕනේ
class SearchPricesEvent extends PriceEvent {
  final String query;
  const SearchPricesEvent({required this.query});
  @override
  List<Object?> get props => [query];
}