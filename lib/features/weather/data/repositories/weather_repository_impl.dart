import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remote;
  WeatherRepositoryImpl({required this.remote});

  @override
  Future<Weather> getWeatherForecast(String location) =>
      remote.getWeatherForecast(location);
}
