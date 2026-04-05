// lib/features/market_prices/data/datasources/price_remote_datasource.dart
// Reads directly from Firestore — works on all platforms, no Flask server needed.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_model.dart';
import '../../domain/entities/price.dart';

abstract class PriceRemoteDataSource {
  Future<List<PriceModel>>        getDailyPrices({String? district});
  Future<List<PriceHistoryModel>> getPriceHistory(String cropName, {int days = 30});
  Future<SupplyAnalyticsModel>    getSupplyStatus();
  Future<ForecastModel>           getForecast(String cropName);
}

class PriceRemoteDataSourceImpl implements PriceRemoteDataSource {
  final FirebaseFirestore _db;

  PriceRemoteDataSourceImpl({
    dynamic apiClient,          // kept for DI compat — no longer used
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  // Walk back up to 30 days to find the latest date that has price data
  Future<String> _latestDate() async {
    final today = DateTime.now();
    for (var i = 0; i < 30; i++) {
      final d = today.subtract(Duration(days: i));
      final s = '${d.year}-'
          '${d.month.toString().padLeft(2,'0')}-'
          '${d.day.toString().padLeft(2,'0')}';
      final probe = await _db.collection('daily_prices')
          .where('date', isEqualTo: s).limit(1).get();
      if (probe.docs.isNotEmpty) return s;
    }
    return today.toIso8601String().substring(0, 10);
  }

  @override
  Future<List<PriceModel>> getDailyPrices({String? district}) async {
    final date = await _latestDate();

    // Load forecast prices for today to enrich each row
    final fcSnap = await _db.collection('price_forecasts')
        .where('forecast_date', isEqualTo: date).get();
    final forecasts = <String, double>{};
    for (final d in fcSnap.docs) {
      final data = d.data();
      forecasts[data['crop_name'] as String? ?? ''] =
          (data['predicted_price'] as num?)?.toDouble() ?? 0;
    }

    Query<Map<String, dynamic>> q =
        _db.collection('daily_prices').where('date', isEqualTo: date);
    if (district != null && district.isNotEmpty && district != 'All') {
      q = q.where('district', isEqualTo: district);
    }
    final snap = await q.limit(200).get();

    return snap.docs.map((doc) {
      final d = doc.data();
      // Seed uses snake_case keys; support both snake_case and camelCase
      final cropName    = d['crop_name']   as String? ?? d['cropName']   as String? ?? '';
      final supply      = (d['total_supply'] as num?)?.toDouble() ?? (d['totalSupply'] as num?)?.toDouble() ?? 0;
      final demand      = (d['total_demand'] as num?)?.toDouble() ?? (d['totalDemand'] as num?)?.toDouble() ?? 0;
      // isSurplus/isShortage may not be stored — compute from supply vs demand
      final isSurplus   = d['isSurplus']  as bool? ?? (supply > demand * 1.1);
      final isShortage  = d['isShortage'] as bool? ?? (demand > supply * 1.1);
      return PriceModel(
        id:             doc.id,
        cropName:       cropName,
        marketName:     d['market_name']  as String? ?? d['marketName']  as String? ?? '',
        district:       d['district']     as String? ?? '',
        category:       d['category']     as String? ?? '',
        minPrice:       (d['min_price']   as num?)?.toDouble() ?? (d['minPrice']  as num?)?.toDouble() ?? 0,
        maxPrice:       (d['max_price']   as num?)?.toDouble() ?? (d['maxPrice']  as num?)?.toDouble() ?? 0,
        avgPrice:       (d['avg_price']   as num?)?.toDouble() ?? (d['avgPrice']  as num?)?.toDouble() ?? 0,
        predictedPrice: forecasts[cropName],
        totalSupply:    supply,
        totalDemand:    demand,
        isSurplus:      isSurplus,
        isShortage:     isShortage,
        date: d['date'] != null ? DateTime.tryParse(d['date'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<List<PriceHistoryModel>> getPriceHistory(String cropName,
      {int days = 30}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceStr = '${since.year}-'
        '${since.month.toString().padLeft(2,'0')}-'
        '${since.day.toString().padLeft(2,'0')}';

    final snap = await _db.collection('daily_prices')
        .where('crop_name', isEqualTo: cropName)
        .where('date', isGreaterThanOrEqualTo: sinceStr)
        .orderBy('date')
        .get();

    final byDate = <String, List<double>>{};
    for (final doc in snap.docs) {
      final d    = doc.data();
      final date = d['date'] as String? ?? '';
      final avg  = (d['avg_price'] as num?)?.toDouble() ?? (d['avgPrice'] as num?)?.toDouble() ?? 0;
      byDate.putIfAbsent(date, () => []).add(avg);
    }

    return byDate.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return PriceHistoryModel(
        date:     DateTime.tryParse(e.key) ?? DateTime.now(),
        avgPrice: avg,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<SupplyAnalyticsModel> getSupplyStatus() async {
    final date = await _latestDate();
    final snap = await _db.collection('daily_prices')
        .where('date', isEqualTo: date).get();

    int surplus = 0, shortage = 0, normal = 0;
    for (final doc in snap.docs) {
      final d = doc.data();
      final supply  = (d['total_supply'] as num?)?.toDouble() ?? (d['totalSupply'] as num?)?.toDouble() ?? 0;
      final demand  = (d['total_demand'] as num?)?.toDouble() ?? (d['totalDemand'] as num?)?.toDouble() ?? 0;
      final isSurp  = d['isSurplus']  as bool? ?? (supply > demand * 1.1);
      final isShort = d['isShortage'] as bool? ?? (demand > supply * 1.1);
      if (isSurp)       surplus++;
      else if (isShort) shortage++;
      else              normal++;
    }
    return SupplyAnalyticsModel(
      totalSurplus:  surplus,
      totalShortage: shortage,
      totalNormal:   normal,
      total:         snap.docs.length,
    );
  }

  @override
  Future<ForecastModel> getForecast(String cropName) async {
    final snap = await _db.collection('price_forecasts')
        .where('crop_name', isEqualTo: cropName)
        .orderBy('forecast_date')
        .limit(14)
        .get();

    if (snap.docs.isEmpty) {
      return ForecastModel(
        cropName: cropName, predictions: const [], percentageChange: 0,
      );
    }

    final predictions = snap.docs.map((doc) {
      final d = doc.data();
      return ForecastDayModel(
        date: DateTime.tryParse(d['forecast_date'] as String? ?? '') ?? DateTime.now(),
        predictedPrice: (d['predicted_price'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    final pct = predictions.length >= 2
        ? ((predictions.last.predictedPrice - predictions.first.predictedPrice) /
              predictions.first.predictedPrice) * 100
        : 0.0;

    return ForecastModel(
      cropName: cropName, predictions: predictions, percentageChange: pct,
    );
  }
}