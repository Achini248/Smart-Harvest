// lib/features/home/presentation/bloc/home_bloc.dart
// All data comes from Firestore directly — works on real devices without Flask.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _db;

  HomeBloc({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance,
        super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoad);
    on<RefreshHomeDataEvent>(_onRefresh);
  }

  Future<void> _onLoad(LoadHomeDataEvent e, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetchAll(emit);
  }

  Future<void> _onRefresh(RefreshHomeDataEvent e, Emitter<HomeState> emit) async {
    await _fetchAll(emit);
  }

  Future<void> _fetchAll(Emitter<HomeState> emit) async {
    final results = await Future.wait([
      _fetchTopPrices(),
      _fetchWeather(),
      _fetchSupply(),
      _fetchNews(),
    ]);

    emit(HomeLoaded(
      topPrices:     results[0] as List<TopPriceItem>,
      weather:       results[1] as WeatherSummary?,
      surplusCount:  (results[2] as Map<String, int>)['surplus']  ?? 0,
      shortageCount: (results[2] as Map<String, int>)['shortage'] ?? 0,
      news:          results[3] as List<NewsItem>,
    ));
  }

  // ── Top prices from Firestore ─────────────────────────────────────────────
  Future<List<TopPriceItem>> _fetchTopPrices() async {
    try {
      final today = DateTime.now();
      String? date;
      for (var i = 0; i < 30; i++) {
        final d = today.subtract(Duration(days: i));
        final s = '${d.year}-'
            '${d.month.toString().padLeft(2,'0')}-'
            '${d.day.toString().padLeft(2,'0')}';
        final probe = await _db.collection('daily_prices')
            .where('date', isEqualTo: s).limit(1).get();
        if (probe.docs.isNotEmpty) { date = s; break; }
      }
      if (date == null) return [];

      final snap = await _db.collection('daily_prices')
          .where('date', isEqualTo: date)
          .limit(6).get();

      return snap.docs.map((doc) {
        final d = doc.data();
        // Seed uses snake_case keys; support both snake_case and camelCase
        final supply  = (d['total_supply'] as num?)?.toDouble() ?? (d['totalSupply'] as num?)?.toDouble() ?? 0;
        final demand  = (d['total_demand'] as num?)?.toDouble() ?? (d['totalDemand'] as num?)?.toDouble() ?? 0;
        return TopPriceItem(
          cropName:       d['crop_name']  as String? ?? d['cropName']  as String? ?? '',
          avgPrice:       (d['avg_price'] as num?)?.toDouble() ?? (d['avgPrice'] as num?)?.toDouble() ?? 0,
          predictedPrice: (d['predictedPrice'] as num?)?.toDouble(),
          isSurplus:      d['isSurplus']  as bool? ?? (supply > demand * 1.1),
          isShortage:     d['isShortage'] as bool? ?? (demand > supply * 1.1),
        );
      }).take(3).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Weather: OWM direct, then mock ───────────────────────────────────────
  Future<WeatherSummary?> _fetchWeather() async {
    try {
      const key = String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');
      if (key.isNotEmpty) {
        final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather'
          '?lat=6.9271&lon=79.8612&appid=$key&units=metric',
        )).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final j = jsonDecode(res.body) as Map<String, dynamic>;
          final m = j['main'] as Map<String, dynamic>;
          final w = (j['weather'] as List).first as Map<String, dynamic>;
          return WeatherSummary(
            location:      j['name'] as String? ?? 'Colombo',
            temperature:   (m['temp'] as num).toDouble(),
            condition:     w['main']  as String,
            iconCode:      w['icon']  as String? ?? '',
            farmingAdvice: _advice(w['main'] as String),
          );
        }
      }
      // No key or OWM failed → show seasonal mock for Colombo
      final mo  = DateTime.now().month;
      final wet = (mo >= 5 && mo <= 9) || mo >= 10;
      return WeatherSummary(
        location:      'Colombo',
        temperature:   wet ? 27.0 : 30.0,
        condition:     wet ? 'Rain' : 'Clear',
        iconCode:      wet ? '10d' : '01d',
        farmingAdvice: wet
            ? 'Good moisture — watch for fungal diseases'
            : 'Dry conditions — ensure adequate irrigation',
      );
    } catch (_) {
      return null;
    }
  }

  String _advice(String cond) {
    final c = cond.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle'))
      return 'Good moisture — watch for fungal diseases';
    if (c.contains('storm') || c.contains('thunder'))
      return 'Severe weather — protect crops and avoid fieldwork';
    if (c.contains('cloud'))
      return 'Overcast conditions — good for transplanting';
    if (c.contains('clear') || c.contains('sun'))
      return 'Sunny and dry — ideal for harvesting and drying';
    return 'Check local conditions before fieldwork';
  }

  // ── Supply summary from Firestore ────────────────────────────────────────
  Future<Map<String, int>> _fetchSupply() async {
    try {
      final today = DateTime.now();
      String? date;
      for (var i = 0; i < 30; i++) {
        final d = today.subtract(Duration(days: i));
        final s = '${d.year}-'
            '${d.month.toString().padLeft(2,'0')}-'
            '${d.day.toString().padLeft(2,'0')}';
        final probe = await _db.collection('daily_prices')
            .where('date', isEqualTo: s).limit(1).get();
        if (probe.docs.isNotEmpty) { date = s; break; }
      }
      if (date == null) return {'surplus': 0, 'shortage': 0};

      final snap = await _db.collection('daily_prices')
          .where('date', isEqualTo: date).get();
      int surplus = 0, shortage = 0;
      for (final doc in snap.docs) {
        final data   = doc.data();
        final supply = (data['total_supply'] as num?)?.toDouble() ?? (data['totalSupply'] as num?)?.toDouble() ?? 0;
        final demand = (data['total_demand'] as num?)?.toDouble() ?? (data['totalDemand'] as num?)?.toDouble() ?? 0;
        if (data['isSurplus']  as bool? ?? (supply > demand * 1.1)) surplus++;
        if (data['isShortage'] as bool? ?? (demand > supply * 1.1)) shortage++;
      }
      return {'surplus': surplus, 'shortage': shortage};
    } catch (_) {
      return {'surplus': 0, 'shortage': 0};
    }
  }

  // ── News: try Firestore news collection, then empty gracefully ───────────
  Future<List<NewsItem>> _fetchNews() async {
    try {
      final snap = await _db.collection('news')
          .orderBy('publishedAt', descending: true)
          .limit(5)
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) {
          final d = doc.data();
          return NewsItem(
            id:          doc.id,
            title:       d['title']       as String? ?? '',
            description: d['description'] as String? ?? '',
            imageUrl:    d['imageUrl']    as String? ?? '',
            publishedAt: d['publishedAt'] as String? ?? '',
            source:      d['source']      as String? ?? 'Smart Harvest',
            category:    d['category']    as String? ?? 'Agriculture',
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}