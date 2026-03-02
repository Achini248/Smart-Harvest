import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherForecast(String location);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  @override
  Future<WeatherModel> getWeatherForecast(String location) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return WeatherModel.fromJson({
      'location': location.isEmpty ? 'Colombo' : location,
      'temperatureC': 29.0,
      'condition': 'Partly Cloudy',
      'humidity': 75,
      'windSpeedKmh': 14.0,
      'forecast': const [
        {'day': 'Mon', 'highC': 31.0, 'lowC': 24.0, 'condition': 'Sunny'},
        {'day': 'Tue', 'highC': 28.0, 'lowC': 22.0, 'condition': 'Rainy'},
        {'day': 'Wed', 'highC': 30.0, 'lowC': 23.0, 'condition': 'Cloudy'},
        {'day': 'Thu', 'highC': 32.0, 'lowC': 25.0, 'condition': 'Sunny'},
        {'day': 'Fri', 'highC': 27.0, 'lowC': 21.0, 'condition': 'Rainy'},
      ],
    });
  }
}
