import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/seller.dart';
import '../repositories/marketplace_repository.dart';

class BrowseProductsUseCase {
  final MarketplaceRepository repository;
  const BrowseProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call(
      BrowseProductsParams params) =>
      repository.getProducts(
        category: params.category,
        searchQuery: params.searchQuery,
      );
}

class BrowseProductsParams extends Equatable {
  final String? category;
  final String? searchQuery;

  const BrowseProductsParams({this.category, this.searchQuery});

  @override
  List<Object?> get props => [category, searchQuery];
}
