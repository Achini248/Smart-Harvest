// lib/features/market_prices/domain/entities/price.dart
import 'package:equatable/equatable.dart';

class Price extends Equatable {
  final String id;
  final String productName;
  final double pricePerUnit;
  final String unit;
  final double changePercent; // compared to yesterday
  final DateTime date;

  const Price({
    required this.id,
    required this.productName,
    required this.pricePerUnit,
    required this.unit,
    required this.changePercent,
    required this.date,
  });

  @override
  List<Object?> get props => [
        id,
        productName,
        pricePerUnit,
        unit,
        changePercent,
        date,
      ];
}
