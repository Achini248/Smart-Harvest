import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class GetWeatherForecastUseCase {
  final WeatherRepository repository;
  GetWeatherForecastUseCase(this.repository);

  Future<Weather> call(String location) =>
      repository.getWeatherForecast(location);
}
