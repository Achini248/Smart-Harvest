// lib/features/marketplace/data/datasources/marketplace_remote_datasource.dart
// All reads AND writes go directly to Firestore — works on all platforms.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/order_model.dart';
import '../models/seller_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category, String? searchQuery});
  Future<ProductModel>       getProductById(String id);
  Future<OrderModel>         placeOrder(OrderModel order);
  Future<List<OrderModel>>   getMyOrders(String buyerId);
  Future<List<OrderModel>>   getIncomingOrders(String sellerId);
  Future<OrderModel>         updateOrderStatus({required String orderId, required String status});
  Future<ProductModel>       createProduct(ProductModel product);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final FirebaseFirestore _db;

  MarketplaceRemoteDataSourceImpl({
    dynamic apiClient,            // kept for DI compat — no longer used
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  // ── Products ──────────────────────────────────────────────────────────────

  @override
  Future<List<ProductModel>> getProducts({
    String? category, String? searchQuery,
  }) async {
    try {
      // NOTE: We intentionally do NOT chain .orderBy() here.
      // Combining .where('isAvailable') + .orderBy('createdAt') requires a
      // composite Firestore index that may not exist, causing a
      // [cloud_firestore/failed-precondition] error.
      // We fetch up to 200 docs and sort client-side instead.
      Query<Map<String, dynamic>> q = _db.collection('products')
          .where('isAvailable', isEqualTo: true)
          .limit(200);

      if (category != null && category.isNotEmpty) {
        q = q.where('category', isEqualTo: category.toLowerCase());
      }

      final snap = await q.get();

      List<ProductModel> products =
          snap.docs.map(ProductModel.fromFirestore).toList();

      // Sort by newest first (client-side — no composite index needed).
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Client-side full-text search (Firestore has no native full-text).
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final sq = searchQuery.toLowerCase();
        products = products.where((p) =>
            p.name.toLowerCase().contains(sq) ||
            p.description.toLowerCase().contains(sq) ||
            p.sellerName.toLowerCase().contains(sq) ||
            p.location.toLowerCase().contains(sq)).toList();
      }

      return products;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch products: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await _db.collection('products').doc(id).get();
      if (!doc.exists) throw const ServerException(message: 'Product not found.');
      return ProductModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch product: $e');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final ref = _db.collection('products').doc();
      final now = DateTime.now();
      final model = ProductModel(
        id: ref.id,
        name: product.name, category: product.category,
        pricePerUnit: product.pricePerUnit, unit: product.unit,
        availableQuantity: product.availableQuantity,
        sellerId: product.sellerId, sellerName: product.sellerName,
        location: product.location, description: product.description,
        imageUrl: product.imageUrl, isAvailable: true, createdAt: now,
      );
      await ref.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException(message: 'Failed to create product: $e');
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw const AuthException(message: 'Not authenticated.');

      final ref  = _db.collection('orders').doc();
      final now  = DateTime.now();
      final data = {
        'id':           ref.id,
        'productId':    order.productId,
        'productName':  order.productName,
        'buyerId':      order.buyerId,
        'buyerName':    order.buyerName,
        'sellerId':     order.sellerId,
        'sellerName':   order.sellerName,
        'quantity':     order.quantity,
        'unit':         order.unit,
        'pricePerUnit': order.pricePerUnit,
        'totalPrice':   order.totalPrice,
        'status':       'pending',
        'notes':        order.notes,
        'location':     order.location,
        'createdAt':    Timestamp.fromDate(now),
        'updatedAt':    Timestamp.fromDate(now),
      };
      await ref.set(data);
      return OrderModel(
        id: ref.id, productId: order.productId, productName: order.productName,
        buyerId: order.buyerId, buyerName: order.buyerName,
        sellerId: order.sellerId, sellerName: order.sellerName,
        quantity: order.quantity, unit: order.unit,
        pricePerUnit: order.pricePerUnit, totalPrice: order.totalPrice,
        status: 'pending', notes: order.notes, location: order.location,
        createdAt: now, updatedAt: now,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to place order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders(String buyerId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? buyerId;
      // No .orderBy() — avoid composite index requirement.
      final snap = await _db.collection('orders')
          .where('buyerId', isEqualTo: uid)
          .get();
      final orders = snap.docs.map(OrderModel.fromFirestore).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getIncomingOrders(String sellerId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? sellerId;
      // No .orderBy() — avoid composite index requirement.
      final snap = await _db.collection('orders')
          .where('sellerId', isEqualTo: uid)
          .get();
      final orders = snap.docs.map(OrderModel.fromFirestore).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch incoming orders: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId, required String status,
  }) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status':    status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final doc = await _db.collection('orders').doc(orderId).get();
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update order status: $e');
    }
  }
}
