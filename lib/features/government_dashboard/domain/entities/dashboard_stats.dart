import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalFarmers;
  final int totalCrops;
  final int totalOrders;
  final double totalRevenue;
  final int surplusRegions;
  final int shortageRegions;
  final double nationalSurplusIndex;
  final Map<String, dynamic> cropDistribution;

  const DashboardStats({
    required this.totalFarmers,
    required this.totalCrops,
    required this.totalOrders,
    required this.totalRevenue,
    required this.surplusRegions,
    required this.shortageRegions,
    required this.nationalSurplusIndex,
    this.cropDistribution = const {},
  });

  @override
  List<Object?> get props => [
        totalFarmers,
        totalCrops,
        totalOrders,
        totalRevenue,
        surplusRegions,
        shortageRegions,
        nationalSurplusIndex,
        cropDistribution,
      ];
}

