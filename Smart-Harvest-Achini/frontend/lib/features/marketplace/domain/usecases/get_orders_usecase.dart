import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order.dart';
import '../repositories/marketplace_repository.dart';

class GetOrdersUseCase {
  final MarketplaceRepository repository;
  const GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call(GetOrdersParams params) {
    if (params.isSeller) {
      return repository.getIncomingOrders(params.userId);
    }
    return repository.getMyOrders(params.userId);
  }
}

class GetOrdersParams extends Equatable {
  final String userId;
  final bool isSeller;

  const GetOrdersParams({required this.userId, this.isSeller = false});

  @override
  List<Object?> get props => [userId, isSeller];
}
