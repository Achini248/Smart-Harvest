import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String location;
  final double temperatureC;
  final String condition;
  final int humidity;
  final double windSpeedKmh;
  final List<WeatherForecast> forecast;

  const Weather({
    required this.location,
    required this.temperatureC,
    required this.condition,
    required this.humidity,
    required this.windSpeedKmh,
    required this.forecast,
  });

  @override
  List<Object?> get props => [location, temperatureC, condition, humidity, windSpeedKmh, forecast];
}

class WeatherForecast extends Equatable {
  final String day;
  final double highC;
  final double lowC;
  final String condition;

  const WeatherForecast({
    required this.day,
    required this.highC,
    required this.lowC,
    required this.condition,
  });

  @override
  List<Object?> get props => [day, highC, lowC, condition];
}

