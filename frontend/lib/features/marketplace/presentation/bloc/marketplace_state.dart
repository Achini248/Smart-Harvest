import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/seller.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitialState extends MarketplaceState {
  const MarketplaceInitialState();
}

class MarketplaceLoadingState extends MarketplaceState {
  const MarketplaceLoadingState();
}

class ProductsLoadedState extends MarketplaceState {
  final List<ProductEntity> products;
  final String? activeCategory;
  final String? activeSearch;

  const ProductsLoadedState({
    required this.products,
    this.activeCategory,
    this.activeSearch,
  });

  @override
  List<Object?> get props => [products, activeCategory, activeSearch];
}

class ProductSelectedState extends MarketplaceState {
  final ProductEntity product;
  const ProductSelectedState({required this.product});

  @override
  List<Object?> get props => [product];
}

class OrderPlacedState extends MarketplaceState {
  final OrderEntity order;
  const OrderPlacedState({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrdersLoadedState extends MarketplaceState {
  final List<OrderEntity> orders;
  final bool isSeller;

  const OrdersLoadedState({required this.orders, required this.isSeller});

  @override
  List<Object?> get props => [orders, isSeller];
}

class OrderStatusUpdatedState extends MarketplaceState {
  final OrderEntity order;
  const OrderStatusUpdatedState({required this.order});

  @override
  List<Object?> get props => [order];
}

class MarketplaceOperationLoadingState extends MarketplaceState {
  const MarketplaceOperationLoadingState();
}

class MarketplaceEmptyState extends MarketplaceState {
  final String message;
  const MarketplaceEmptyState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MarketplaceErrorState extends MarketplaceState {
  final String message;
  const MarketplaceErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
