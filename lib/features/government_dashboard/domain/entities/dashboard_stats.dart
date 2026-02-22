import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalFarmers;
  final int totalCrops;
  final int activeOrders;
  final double totalRevenue;
  final double surplusPercentage;
  final double shortagePercentage;

  const DashboardStats({
    required this.totalFarmers,
    required this.totalCrops,
    required this.activeOrders,
    required this.totalRevenue,
    required this.surplusPercentage,
    required this.shortagePercentage,
  });

  @override
  List<Object?> get props => [
    totalFarmers, totalCrops, activeOrders, totalRevenue,
    surplusPercentage, shortagePercentage
  ];
}
