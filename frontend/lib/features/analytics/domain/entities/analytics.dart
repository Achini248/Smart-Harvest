// lib/features/analytics/domain/entities/analytics.dart
import 'package:equatable/equatable.dart';

class Analytics extends Equatable {
  final int totalCrops;
  final int totalOrders;
  final double totalRevenue;
  final Map<String, double> cropDistribution; // cropName -> amount

  const Analytics({
    required this.totalCrops,
    required this.totalOrders,
    required this.totalRevenue,
    required this.cropDistribution,
  });

  @override
  List<Object?> get props =>
      [totalCrops, totalOrders, totalRevenue, cropDistribution];
}
