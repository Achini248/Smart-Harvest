// lib/features/market_prices/domain/entities/price.dart
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class PriceEntity extends Equatable {
  final String id;
  final String cropName;
  final String marketName;
  final String district;
  final String category;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final double? predictedPrice;
  final double totalSupply;
  final double totalDemand;
  final bool isSurplus;
  final bool isShortage;
  final DateTime? date;

  const PriceEntity({
    required this.id,
    required this.cropName,
    required this.marketName,
    required this.district,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    this.predictedPrice,
    required this.totalSupply,
    required this.totalDemand,
    required this.isSurplus,
    required this.isShortage,
    this.date,
  });

  bool get isNormal => !isSurplus && !isShortage;

  double? get priceTrendPercent {
    if (predictedPrice == null || avgPrice == 0) return null;
    return ((predictedPrice! - avgPrice) / avgPrice) * 100;
  }

  bool get isTrendingUp => (priceTrendPercent ?? 0) > 0;

  String get trendLabel {
    final p = priceTrendPercent;
    if (p == null) return '—';
    final sign = p >= 0 ? '▲ +' : '▼ ';
    return '$sign${p.abs().toStringAsFixed(1)}%';
  }

  String get statusLabel {
    if (isSurplus)  return 'Surplus';
    if (isShortage) return 'Shortage';
    return 'Normal';
  }

  String get formattedAvgPrice =>
      'Rs. ${NumberFormat('#,##0').format(avgPrice)}';

  String get formattedPredictedPrice => predictedPrice != null
      ? 'Rs. ${NumberFormat('#,##0').format(predictedPrice)}'
      : 'N/A';

  @override
  List<Object?> get props => [
        id, cropName, marketName, district, category,
        minPrice, maxPrice, avgPrice, predictedPrice,
        totalSupply, totalDemand, isSurplus, isShortage, date,
      ];
}

class PriceHistoryPoint extends Equatable {
  final DateTime date;
  final double avgPrice;

  const PriceHistoryPoint({required this.date, required this.avgPrice});

  String get dayLabel  => DateFormat('EEE').format(date);
  String get shortDate => DateFormat('dd MMM').format(date);

  @override
  List<Object?> get props => [date, avgPrice];
}

class SupplyAnalyticsEntity extends Equatable {
  final int totalSurplus;
  final int totalShortage;
  final int totalNormal;
  final int total;

  const SupplyAnalyticsEntity({
    required this.totalSurplus,
    required this.totalShortage,
    required this.totalNormal,
    required this.total,
  });

  double get surplusPct  => total > 0 ? totalSurplus  / total * 100 : 0;
  double get shortagePct => total > 0 ? totalShortage / total * 100 : 0;
  double get normalPct   => total > 0 ? totalNormal   / total * 100 : 0;

  @override
  List<Object?> get props => [totalSurplus, totalShortage, totalNormal, total];
}

class ForecastEntity extends Equatable {
  final String cropName;
  final List<ForecastDayEntity> predictions;
  final double percentageChange;

  const ForecastEntity({
    required this.cropName,
    required this.predictions,
    required this.percentageChange,
  });

  bool get isPriceRising => percentageChange > 0;

  String get changeSummary {
    final sign = isPriceRising ? '▲ +' : '▼ ';
    return '$sign${percentageChange.abs().toStringAsFixed(1)}%';
  }

  @override
  List<Object?> get props => [cropName, predictions, percentageChange];
}

class ForecastDayEntity extends Equatable {
  final DateTime date;
  final double predictedPrice;

  const ForecastDayEntity({required this.date, required this.predictedPrice});

  String get dayLabel  => DateFormat('EEE').format(date);
  String get shortDate => DateFormat('dd MMM').format(date);
  String get priceLabel =>
      'Rs. ${NumberFormat('#,##0').format(predictedPrice)}';

  @override
  List<Object?> get props => [date, predictedPrice];
}
