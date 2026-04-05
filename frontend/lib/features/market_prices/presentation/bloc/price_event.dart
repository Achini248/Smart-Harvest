import 'package:equatable/equatable.dart';

abstract class PriceEvent extends Equatable {
  const PriceEvent();
  @override
  List<Object?> get props => [];
}

class LoadDailyPricesEvent extends PriceEvent {
  const LoadDailyPricesEvent();
}

class LoadSupplyStatusEvent extends PriceEvent {
  const LoadSupplyStatusEvent();
}

class LoadForecastEvent extends PriceEvent {
  final String cropName;
  const LoadForecastEvent(this.cropName);
  @override
  List<Object?> get props => [cropName];
}

class SearchPricesEvent extends PriceEvent {
  final String query;
  const SearchPricesEvent({required this.query});
  @override
  List<Object?> get props => [query];
}

class FilterByDistrictEvent extends PriceEvent {
  final String district;
  const FilterByDistrictEvent(this.district);
  @override
  List<Object?> get props => [district];
}

class RefreshAllPricesEvent extends PriceEvent {
  const RefreshAllPricesEvent();
}
