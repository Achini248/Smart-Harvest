// lib/features/market_prices/data/models/price_model.dart
import '../../domain/entities/price.dart';

class PriceModel extends Price {
  const PriceModel({
    required super.id,
    required super.productName,
    required super.pricePerUnit,
    required super.unit,
    required super.changePercent,
    required super.date,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      unit: json['unit'] as String,
      changePercent: (json['changePercent'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'changePercent': changePercent,
      'date': date.toIso8601String(),
    };
  }

  factory PriceModel.fromEntity(Price price) {
    return PriceModel(
      id: price.id,
      productName: price.productName,
      pricePerUnit: price.pricePerUnit,
      unit: price.unit,
      changePercent: price.changePercent,
      date: price.date,
    );
  }
}
