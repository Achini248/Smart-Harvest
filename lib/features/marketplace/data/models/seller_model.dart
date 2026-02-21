import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/seller.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.pricePerUnit,
    required super.unit,
    required super.availableQuantity,
    required super.sellerId,
    required super.sellerName,
    required super.location,
    required super.description,
    super.imageUrl,
    required super.isAvailable,
    required super.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? 'other',
      pricePerUnit: (d['pricePerUnit'] as num?)?.toDouble() ?? 0,
      unit: d['unit'] ?? 'kg',
      availableQuantity: (d['availableQuantity'] as num?)?.toDouble() ?? 0,
      sellerId: d['sellerId'] ?? '',
      sellerName: d['sellerName'] ?? '',
      location: d['location'] ?? '',
      description: d['description'] ?? '',
      imageUrl: d['imageUrl'],
      isAvailable: d['isAvailable'] ?? true,
      createdAt: _ts(d['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'category': category,
        'pricePerUnit': pricePerUnit,
        'unit': unit,
        'availableQuantity': availableQuantity,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'location': location,
        'description': description,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }
}
