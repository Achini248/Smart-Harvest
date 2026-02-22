import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalFarmers,
    required super.totalCrops,
    required super.totalOrders,
    required super.totalRevenue,
    required super.surplusRegions,
    required super.shortageRegions,
    required super.nationalSurplusIndex,
    required super.cropDistribution,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalFarmers: json['totalFarmers'] ?? 0,
      totalCrops: json['totalCrops'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      surplusRegions: json['surplusRegions'] ?? 0,
      shortageRegions: json['shortageRegions'] ?? 0,
      nationalSurplusIndex: (json['nationalSurplusIndex'] ?? 0).toDouble(),
      cropDistribution: json['cropDistribution'] ?? {},
    );
  }
}
