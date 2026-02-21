import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order.dart';
import '../entities/seller.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, OrderEntity>> placeOrder(OrderEntity order);

  Future<Either<Failure, List<OrderEntity>>> getMyOrders(String buyerId);

  Future<Either<Failure, List<OrderEntity>>> getIncomingOrders(String sellerId);

  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
