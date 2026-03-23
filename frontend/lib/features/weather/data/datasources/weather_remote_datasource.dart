// lib/features/weather/data/datasources/weather_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherForecast(String location);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient _api;

  WeatherRemoteDataSourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  @override
  Future<WeatherModel> getWeatherForecast(String location) async {
    final data = await _api.get(
      ApiConstants.weather,
      queryParams: {'location': location.isEmpty ? 'Colombo' : location},
    );
    return WeatherModel.fromJson(data as Map<String, dynamic>);
  }
}
