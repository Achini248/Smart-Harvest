import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/order_model.dart';
import '../models/seller_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category, String? searchQuery});
  Future<ProductModel> getProductById(String id);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getMyOrders(String buyerId);
  Future<List<OrderModel>> getIncomingOrders(String sellerId);
  Future<OrderModel> updateOrderStatus({required String orderId, required String status});
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final FirebaseFirestore _firestore;

  MarketplaceRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _products.where('isAvailable', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      List<ProductModel> products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Client-side search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        products = products
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.sellerName.toLowerCase().contains(q))
            .toList();
      }

      return products;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch products.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await _products.doc(id).get();
      if (!doc.exists) throw const ServerException(message: 'Product not found.');
      return ProductModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch product.');
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      final docRef = _orders.doc();
      final now = DateTime.now();
      final newOrder = OrderModel(
        id: docRef.id,
        productId: order.productId,
        productName: order.productName,
        buyerId: order.buyerId,
        buyerName: order.buyerName,
        sellerId: order.sellerId,
        sellerName: order.sellerName,
        quantity: order.quantity,
        unit: order.unit,
        pricePerUnit: order.pricePerUnit,
        totalPrice: order.quantity * order.pricePerUnit,
        status: 'pending',
        notes: order.notes,
        location: order.location,
        createdAt: now,
        updatedAt: now,
      );
      await docRef.set(newOrder.toFirestore());
      return newOrder;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to place order.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders(String buyerId) async {
    try {
      final snapshot = await _orders
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch orders.');
    }
  }

  @override
  Future<List<OrderModel>> getIncomingOrders(String sellerId) async {
    try {
      final snapshot = await _orders
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch incoming orders.');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _orders.doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      final doc = await _orders.doc(orderId).get();
      return OrderModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update order.');
    }
  }
}
