import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.buyerId,
    required super.buyerName,
    required super.sellerId,
    required super.sellerName,
    required super.quantity,
    required super.unit,
    required super.pricePerUnit,
    required super.totalPrice,
    required super.status,
    super.notes,
    required super.location,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      productId: d['productId'] ?? '',
      productName: d['productName'] ?? '',
      buyerId: d['buyerId'] ?? '',
      buyerName: d['buyerName'] ?? '',
      sellerId: d['sellerId'] ?? '',
      sellerName: d['sellerName'] ?? '',
      quantity: (d['quantity'] as num?)?.toDouble() ?? 0,
      unit: d['unit'] ?? 'kg',
      pricePerUnit: (d['pricePerUnit'] as num?)?.toDouble() ?? 0,
      totalPrice: (d['totalPrice'] as num?)?.toDouble() ?? 0,
      status: d['status'] ?? 'pending',
      notes: d['notes'],
      location: d['location'] ?? '',
      createdAt: _ts(d['createdAt']),
      updatedAt: _ts(d['updatedAt']),
    );
  }

  factory OrderModel.fromEntity(OrderEntity e) => OrderModel(
        id: e.id,
        productId: e.productId,
        productName: e.productName,
        buyerId: e.buyerId,
        buyerName: e.buyerName,
        sellerId: e.sellerId,
        sellerName: e.sellerName,
        quantity: e.quantity,
        unit: e.unit,
        pricePerUnit: e.pricePerUnit,
        totalPrice: e.totalPrice,
        status: e.status,
        notes: e.notes,
        location: e.location,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'productName': productName,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'totalPrice': totalPrice,
        'status': status,
        'notes': notes,
        'location': location,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }
}
