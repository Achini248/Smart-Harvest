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

  // ---------- Computed Helpers ----------
  double get temperatureF => (temperatureC * 9 / 5) + 32;

  // ---------- JSON ----------
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['location'] ?? '',
      temperatureC: (json['temperatureC'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      humidity: json['humidity'] ?? 0,
      windSpeedKmh: (json['windSpeedKmh'] ?? 0).toDouble(),
      forecast: (json['forecast'] as List<dynamic>? ?? [])
          .map((e) => WeatherForecast.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperatureC': temperatureC,
      'condition': condition,
      'humidity': humidity,
      'windSpeedKmh': windSpeedKmh,
      'forecast': forecast.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [location, temperatureC, condition, humidity, windSpeedKmh, forecast];
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

  // ---------- Computed Helpers ----------
  double get highF => (highC * 9 / 5) + 32;
  double get lowF => (lowC * 9 / 5) + 32;

  // ---------- JSON ----------
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      day: json['day'] ?? '',
      highC: (json['highC'] ?? 0).toDouble(),
      lowC: (json['lowC'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'highC': highC,
      'lowC': lowC,
      'condition': condition,
    };
  }

  @override
  List<Object?> get props => [day, highC, lowC, condition];
}
