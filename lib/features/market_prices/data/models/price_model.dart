import '../../domain/entities/price.dart';

class PriceModel extends PriceEntity {
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
      id: json['id'],
      productName: json['productName'],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      unit: json['unit'],
      changePercent: (json['changePercent'] as num).toDouble(),
      date: DateTime.parse(json['date']),
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
}