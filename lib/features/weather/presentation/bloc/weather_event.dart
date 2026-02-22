import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWeatherEvent extends WeatherEvent {
  final String location;
  LoadWeatherEvent(this.location);

  @override
  List<Object?> get props => [location];
}
