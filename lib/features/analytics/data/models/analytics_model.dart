// lib/features/analytics/data/models/analytics_model.dart
import '../../domain/entities/analytics.dart';

class AnalyticsModel extends Analytics {
  const AnalyticsModel({
    required super.totalCrops,
    required super.totalOrders,
    required super.totalRevenue,
    required super.cropDistribution,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final rawMap =
        json['cropDistribution'] as Map<String, dynamic>? ?? {};
    final casted = rawMap.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return AnalyticsModel(
      totalCrops: json['totalCrops'] as int,
      totalOrders: json['totalOrders'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      cropDistribution: casted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCrops': totalCrops,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'cropDistribution': cropDistribution,
    };
  }

  factory AnalyticsModel.fromEntity(Analytics a) {
    return AnalyticsModel(
      totalCrops: a.totalCrops,
      totalOrders: a.totalOrders,
      totalRevenue: a.totalRevenue,
      cropDistribution: a.cropDistribution,
    );
  }
}
