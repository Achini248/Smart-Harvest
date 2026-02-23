import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.location,
    required super.temperatureC,
    required super.condition,
    required super.humidity,
    required super.windSpeedKmh,
    required super.forecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: json['location'],
      temperatureC: (json['temperatureC'] as num).toDouble(),
      condition: json['condition'],
      humidity: json['humidity'],
      windSpeedKmh: (json['windSpeedKmh'] as num).toDouble(),
      forecast: (json['forecast'] as List)
          .map((f) => WeatherForecast(
                day: f['day'],
                highC: (f['highC'] as num).toDouble(),
                lowC: (f['lowC'] as num).toDouble(),
                condition: f['condition'],
              ))
          .toList(),
    );
  }
}
