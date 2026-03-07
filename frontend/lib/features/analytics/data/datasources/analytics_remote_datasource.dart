// lib/features/analytics/data/datasources/analytics_remote_datasource.dart
import 'dart:math';

import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsModel> getAnalytics();
}

class AnalyticsRemoteDataSourceImpl
    implements AnalyticsRemoteDataSource {
  final Random _random = Random();

  @override
  Future<AnalyticsModel> getAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final totalCrops = 10 + _random.nextInt(40);
    final totalOrders = 20 + _random.nextInt(80);
    final totalRevenue =
        (50000 + _random.nextInt(150000)).toDouble();

    final crops = <String, double>{
      'Tomato': 20 + _random.nextInt(40).toDouble(),
      'Potato': 10 + _random.nextInt(35).toDouble(),
      'Beans': 5 + _random.nextInt(20).toDouble(),
      'Carrot': 5 + _random.nextInt(15).toDouble(),
    };

    return AnalyticsModel(
      totalCrops: totalCrops,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      cropDistribution: crops,
    );
    }
}
