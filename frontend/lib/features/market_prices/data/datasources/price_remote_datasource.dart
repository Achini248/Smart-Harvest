// lib/features/market_prices/data/datasources/price_remote_datasource.dart
import 'dart:math';

import '../models/price_model.dart';

abstract class PriceRemoteDataSource {
  /// Get mock daily prices for today.
  Future<List<PriceModel>> getDailyPrices();

  /// Get mock price history for the last few days (for trend).
  Future<Map<DateTime, double>> getPriceTrends(String productName);
}

class PriceRemoteDataSourceImpl implements PriceRemoteDataSource {
  final Random _random = Random();

  // Simple in‑memory list of products
  final List<String> _products = const [
    'Tomato',
    'Potato',
    'Beans',
    'Carrot',
    'Cabbage',
    'Leeks',
  ];

  @override
  Future<List<PriceModel>> getDailyPrices() async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate latency

    final today = DateTime.now();
    final List<PriceModel> list = [];

    for (int i = 0; i < _products.length; i++) {
      final basePrice = 150 + _random.nextInt(300); // 150 – 450
      final change = _random.nextInt(15) - 7; // -7% .. +7%

      list.add(
        PriceModel(
          id: 'price_${today.toIso8601String()}_$i',
          productName: _products[i],
          pricePerUnit: basePrice.toDouble(),
          unit: 'kg',
          changePercent: change.toDouble(),
          date: DateTime(today.year, today.month, today.day),
        ),
      );
    }

    return list;
  }

  @override
  Future<Map<DateTime, double>> getPriceTrends(String productName) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final today = DateTime.now();
    final Map<DateTime, double> data = {};
    double base = 200.0 + _random.nextInt(200); // start


    for (int i = 5; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day - i);
      final delta = _random.nextInt(30) - 15; // change -15..+15
      base = (base + delta).clamp(120, 450);
      data[day] = base;
    }

    return data;
  }
}
