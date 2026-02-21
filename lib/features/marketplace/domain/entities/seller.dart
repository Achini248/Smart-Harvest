import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final double pricePerUnit;
  final String unit;
  final double availableQuantity;
  final String sellerId;
  final String sellerName;
  final String location;
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerUnit,
    required this.unit,
    required this.availableQuantity,
    required this.sellerId,
    required this.sellerName,
    required this.location,
    required this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, name, category, pricePerUnit, unit,
        availableQuantity, sellerId, sellerName,
        location, description, imageUrl, isAvailable, createdAt,
      ];
}

enum ProductCategory {
  vegetables, fruits, grains, legumes, herbs, dairy, other
}

extension ProductCategoryExtension on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.vegetables: return 'Vegetables';
      case ProductCategory.fruits:     return 'Fruits';
      case ProductCategory.grains:     return 'Grains';
      case ProductCategory.legumes:    return 'Legumes';
      case ProductCategory.herbs:      return 'Herbs';
      case ProductCategory.dairy:      return 'Dairy';
      case ProductCategory.other:      return 'Other';
    }
  }

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductCategory.other,
    );
  }
}
