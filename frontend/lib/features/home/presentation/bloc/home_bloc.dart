// lib/features/home/presentation/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoad);
    on<RefreshHomeDataEvent>(_onRefresh);
  }

  Future<void> _onLoad(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetchAll(emit);
  }

  Future<void> _onRefresh(RefreshHomeDataEvent event, Emitter<HomeState> emit) async {
    await _fetchAll(emit);
  }

  Future<void> _fetchAll(Emitter<HomeState> emit) async {
    try {
      // Fire all requests concurrently — non-blocking parallel fetch
      final results = await Future.wait([
        _fetchNews(),
        _fetchTopPrices(),
        _fetchWeather(),
        _fetchSupply(),
      ]);

      final news       = results[0] as List<NewsItem>;
      final topPrices  = results[1] as List<TopPriceItem>;
      final weather    = results[2] as WeatherSummary?;
      final supply     = results[3] as Map<String, int>;

      emit(HomeLoaded(
        news:          news,
        topPrices:     topPrices,
        weather:       weather,
        surplusCount:  supply['surplus']  ?? 0,
        shortageCount: supply['shortage'] ?? 0,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // ── News ──────────────────────────────────────────────────────────────────
  Future<List<NewsItem>> _fetchNews() async {
    try {
      final data = await ApiClient.instance.get(
        ApiConstants.news,
        queryParams: {'limit': '5'},
      );
      final items = data['news'] as List<dynamic>? ?? [];
      return items
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Top 3 Prices ──────────────────────────────────────────────────────────
  Future<List<TopPriceItem>> _fetchTopPrices() async {
    try {
      final data = await ApiClient.instance.get(
        ApiConstants.currentPrices,
      );
      final items = (data is List ? data : []) as List<dynamic>;
      return items
          .take(3)
          .map((e) => TopPriceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Weather ───────────────────────────────────────────────────────────────
  Future<WeatherSummary?> _fetchWeather() async {
    try {
      final data = await ApiClient.instance.get(
        ApiConstants.weather,
        queryParams: {'location': 'Colombo'},
      );
      return WeatherSummary.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Supply summary ────────────────────────────────────────────────────────
  Future<Map<String, int>> _fetchSupply() async {
    try {
      final data = await ApiClient.instance.get(ApiConstants.supplyStatus);
      return {
        'surplus':  (data['total_surplus']  as num? ?? 0).toInt(),
        'shortage': (data['total_shortage'] as num? ?? 0).toInt(),
      };
    } catch (_) {
      return {'surplus': 0, 'shortage': 0};
    }
  }
}
