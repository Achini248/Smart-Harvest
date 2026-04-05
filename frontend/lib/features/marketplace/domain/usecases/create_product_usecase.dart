// lib/features/marketplace/domain/usecases/create_product_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seller.dart';
import '../repositories/marketplace_repository.dart';

class CreateProductParams {
  final ProductEntity product;
  const CreateProductParams({required this.product});
}

class CreateProductUseCase {
  final MarketplaceRepository repository;
  const CreateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(CreateProductParams params) =>
      repository.createProduct(params.product);
}
