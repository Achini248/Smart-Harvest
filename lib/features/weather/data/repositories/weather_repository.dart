import 'package:smart_harvest_app/features/weather/domain/entities/weather_forecast.dart';

abstract class WeatherRepository {
  Future<WeatherForecast> getWeatherForecast(String city);
}
