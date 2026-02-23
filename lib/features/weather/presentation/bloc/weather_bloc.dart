import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_weather_forecast_usecase.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherForecastUseCase getWeather;

  WeatherBloc({required this.getWeather}) : super(WeatherInitial()) {
    on<LoadWeatherEvent>(_onLoad);
  }

  Future<void> _onLoad(
      LoadWeatherEvent event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weather = await getWeather(event.location);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
