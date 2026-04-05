// lib/features/weather/data/datasources/weather_remote_datasource.dart
// Calls OpenWeatherMap directly from Flutter — works on all platforms.
// Provide --dart-define=OPENWEATHER_API_KEY=xxx at build time for live data.
// Without a key, shows realistic seasonal Sri Lanka mock data every time.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../../domain/entities/weather_forecast.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherForecast(String location);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  static const _key  = String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');
  static const _base = 'https://api.openweathermap.org/data/2.5';

  static const _coords = <String, List<double>>{
    'colombo':      [6.9271,  79.8612],
    'kandy':        [7.2906,  80.6337],
    'galle':        [6.0535,  80.2210],
    'jaffna':       [9.6615,  80.0255],
    'nuwara eliya': [6.9497,  80.7891],
    'anuradhapura': [8.3114,  80.4037],
    'kurunegala':   [7.4818,  80.3609],
    'dambulla':     [7.8742,  80.6511],
    'matara':       [5.9549,  80.5550],
    'ratnapura':    [6.6828,  80.3992],
  };

  WeatherRemoteDataSourceImpl({dynamic apiClient}); // kept for DI compat

  @override
  Future<WeatherModel> getWeatherForecast(String location) async {
    final loc = location.trim().isEmpty ? 'Colombo' : location.trim();
    if (_key.isNotEmpty) {
      try { return await _live(loc); } catch (_) {}
    }
    return _mock(loc);
  }

  Future<WeatherModel> _live(String loc) async {
    final c = _coords[loc.toLowerCase()];
    final q = c != null
        ? 'lat=${c[0]}&lon=${c[1]}'
        : 'q=${Uri.encodeComponent(loc)},LK';

    final cur = await http
        .get(Uri.parse('$_base/weather?$q&appid=$_key&units=metric'))
        .timeout(const Duration(seconds: 10));
    final cj = jsonDecode(cur.body) as Map<String, dynamic>;
    if (cj['cod'] != 200) return _mock(loc);

    final fc = await http
        .get(Uri.parse('$_base/forecast?$q&appid=$_key&units=metric'))
        .timeout(const Duration(seconds: 10));
    final fj = jsonDecode(fc.body) as Map<String, dynamic>;

    final m    = cj['main']    as Map<String, dynamic>;
    final w    = (cj['weather'] as List).first as Map<String, dynamic>;
    final wind = (cj['wind']   as Map<String, dynamic>?) ?? {};

    return WeatherModel(
      location:     cj['name'] as String? ?? loc,
      temperatureC: (m['temp'] as num).toDouble(),
      condition:    w['main']  as String,
      humidity:     (m['humidity'] as num).toInt(),
      windSpeedKmh: ((wind['speed'] as num?)?.toDouble() ?? 0) * 3.6,
      forecast:     _parseFc(fj),
    );
  }

  List<WeatherForecast> _parseFc(Map<String, dynamic> data) {
    const names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final seen  = <String>{};
    final out   = <WeatherForecast>[];
    for (final raw in (data['list'] as List? ?? [])) {
      final item = raw as Map<String, dynamic>;
      final txt  = item['dt_txt'] as String? ?? '';
      final day  = txt.length >= 10 ? txt.substring(0, 10) : '';
      if (day.isEmpty || seen.contains(day) || out.length >= 5) continue;
      seen.add(day);
      final dt   = DateTime.tryParse(day);
      final mm   = item['main'] as Map<String, dynamic>;
      final ww   = (item['weather'] as List).first as Map<String, dynamic>;
      out.add(WeatherForecast(
        day:       dt != null ? names[dt.weekday - 1] : day,
        highC:     (mm['temp_max'] as num).toDouble(),
        lowC:      (mm['temp_min'] as num).toDouble(),
        condition: ww['main'] as String,
      ));
    }
    return out;
  }

  WeatherModel _mock(String location) {
    final mo = DateTime.now().month;
    final wet = (mo >= 5 && mo <= 9) || mo >= 10;
    return WeatherModel(
      location:     location,
      temperatureC: wet ? 27.0 : 30.0,
      condition:    wet ? 'Rain' : 'Clear',
      humidity:     wet ? 82 : 68,
      windSpeedKmh: 14.0,
      forecast: [
        WeatherForecast(day:'Mon', highC:wet?28.0:31.0, lowC:wet?22.0:24.0, condition:wet?'Rain':'Clear'),
        WeatherForecast(day:'Tue', highC:29.0,           lowC:23.0,           condition:'Clouds'),
        WeatherForecast(day:'Wed', highC:wet?27.0:32.0, lowC:wet?22.0:25.0, condition:wet?'Rain':'Clear'),
        WeatherForecast(day:'Thu', highC:30.0,           lowC:24.0,           condition:'Clouds'),
        WeatherForecast(day:'Fri', highC:wet?26.0:31.0, lowC:wet?21.0:24.0, condition:wet?'Drizzle':'Clear'),
      ],
    );
  }
}
