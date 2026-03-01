import '../../domain/entities/price.dart';

class PriceModel extends PriceEntity { // 'Price' වෙනුවට 'PriceEntity'
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
}