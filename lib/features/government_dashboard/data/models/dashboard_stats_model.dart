import 'package:cloud_firestore/cloud_firestore.dart';
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
    super.cropDistribution,
  });

  factory DashboardStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DashboardStatsModel(
      totalFarmers: data['totalFarmers'] ?? 0,
      totalCrops: data['totalCrops'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      totalRevenue: (data['totalRevenue'] ?? 0.0).toDouble(),
      surplusRegions: data['surplusRegions'] ?? 0,
      shortageRegions: data['shortageRegions'] ?? 0,
      nationalSurplusIndex: (data['nationalSurplusIndex'] ?? 0.0).toDouble(),
      cropDistribution: Map<String, int>.from(data['cropDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'totalFarmers': totalFarmers,
        'totalCrops': totalCrops,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'surplusRegions': surplusRegions,
        'shortageRegions': shortageRegions,
        'nationalSurplusIndex': nationalSurplusIndex,
        'cropDistribution': cropDistribution,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
