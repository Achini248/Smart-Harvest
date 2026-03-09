//order.dart
import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalPrice;
  final String status;
  final String? notes;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    double? totalPrice,
    String? status,
    String? notes,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, productId, productName, buyerId, buyerName,
        sellerId, sellerName, quantity, unit, pricePerUnit,
        totalPrice, status, notes, location, createdAt, updatedAt,
      ];
}

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.shipped:    return 'Shipped';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
