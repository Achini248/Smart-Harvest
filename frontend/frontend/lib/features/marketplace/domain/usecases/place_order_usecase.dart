import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order.dart';
import '../repositories/marketplace_repository.dart';

class PlaceOrderUseCase {
  final MarketplaceRepository repository;
  const PlaceOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) =>
      repository.placeOrder(params.order);
}

class PlaceOrderParams extends Equatable {
  final OrderEntity order;
  const PlaceOrderParams({required this.order});

  @override
  List<Object?> get props => [order];
}
