// lib/features/market_prices/presentation/bloc/price_event.dart
import 'package:equatable/equatable.dart';

abstract class PriceEvent extends Equatable {
  const PriceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyPricesEvent extends PriceEvent {
  const LoadDailyPricesEvent();
}

class LoadPriceTrendsEvent extends PriceEvent {
  final String productName;

  const LoadPriceTrendsEvent(this.productName);

  @override
  List<Object?> get props => [productName];
}
