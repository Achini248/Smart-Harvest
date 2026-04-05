// lib/features/market_prices/data/models/price_model.dart
import '../../domain/entities/price.dart';

class PriceModel extends PriceEntity {
  const PriceModel({
    required super.id,
    required super.cropName,
    required super.marketName,
    required super.district,
    required super.category,
    required super.minPrice,
    required super.maxPrice,
    required super.avgPrice,
    super.predictedPrice,
    required super.totalSupply,
    required super.totalDemand,
    required super.isSurplus,
    required super.isShortage,
    super.date,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id:             json['id'] as String? ?? '',
      cropName:       json['cropName']   as String? ?? '',
      marketName:     json['marketName'] as String? ?? '',
      district:       json['district']   as String? ?? '',
      category:       json['category']   as String? ?? '',
      minPrice:       (json['minPrice']  as num?)?.toDouble() ?? 0.0,
      maxPrice:       (json['maxPrice']  as num?)?.toDouble() ?? 0.0,
      avgPrice:       (json['avgPrice']  as num?)?.toDouble() ?? 0.0,
      predictedPrice: (json['predictedPrice'] as num?)?.toDouble(),
      totalSupply:    (json['totalSupply'] as num?)?.toDouble() ?? 0.0,
      totalDemand:    (json['totalDemand'] as num?)?.toDouble() ?? 0.0,
      isSurplus:      json['isSurplus']  as bool? ?? false,
      isShortage:     json['isShortage'] as bool? ?? false,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
    );
  }
}

class PriceHistoryModel extends PriceHistoryPoint {
  const PriceHistoryModel({required super.date, required super.avgPrice});

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      date:     DateTime.parse(json['date'] as String),
      avgPrice: (json['avg_price'] as num).toDouble(),
    );
  }
}

class SupplyAnalyticsModel extends SupplyAnalyticsEntity {
  const SupplyAnalyticsModel({
    required super.totalSurplus,
    required super.totalShortage,
    required super.totalNormal,
    required super.total,
  });

  factory SupplyAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SupplyAnalyticsModel(
      totalSurplus:  (json['total_surplus']  as num).toInt(),
      totalShortage: (json['total_shortage'] as num).toInt(),
      totalNormal:   (json['total_normal']   as num).toInt(),
      total:         (json['total']          as num).toInt(),
    );
  }
}

class ForecastModel extends ForecastEntity {
  const ForecastModel({
    required super.cropName,
    required super.predictions,
    required super.percentageChange,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['next_7_days_predictions'] as List<dynamic>? ?? [];
    return ForecastModel(
      cropName:         json['crop_name'] as String? ?? '',
      percentageChange: (json['percentage_change'] as num?)?.toDouble() ?? 0.0,
      predictions: rawList
          .map((e) => ForecastDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ForecastDayModel extends ForecastDayEntity {
  const ForecastDayModel({required super.date, required super.predictedPrice});

  factory ForecastDayModel.fromJson(Map<String, dynamic> json) {
    return ForecastDayModel(
      date:           DateTime.parse(json['date'] as String),
      predictedPrice: (json['predicted_price'] as num).toDouble(),
    );
  }
}
