import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalFarmers,
    required super.totalCrops,
    required super.activeOrders,
    required super.totalRevenue,
    required super.surplusPercentage,
    required super.shortagePercentage,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalFarmers: json['totalFarmers'] ?? 0,
      totalCrops: json['totalCrops'] ?? 0,
      activeOrders: json['activeOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      surplusPercentage: (json['surplusPercentage'] ?? 0).toDouble(),
      shortagePercentage: (json['shortagePercentage'] ?? 0).toDouble(),
    );
  }
}
