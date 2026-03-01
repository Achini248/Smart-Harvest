import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double pricePerUnit;
  final String unit;
  final String imageUrl;
  final String sellerId;
  final String sellerName;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.unit,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pricePerUnit,
        unit,
        imageUrl,
        sellerId,
        sellerName,
      ];
}
