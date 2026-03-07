import '../entities/weather_forecast.dart';

abstract class WeatherRepository {
  Future<Weather> getWeatherForecast(String location);
}
